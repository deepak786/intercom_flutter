import 'dart:convert';
import 'dart:io';

const _androidReleaseUrl = 'https://api.github.com/repos/intercom/intercom-android/releases/latest';
const _iosReleaseUrl = 'https://api.github.com/repos/intercom/intercom-ios/releases/latest';

const _androidReleasePage = 'https://github.com/intercom/intercom-android/releases';
const _iosReleasePage = 'https://github.com/intercom/intercom-ios/releases';

Future<String> _fetchLatestVersion(Uri url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    request.headers.set(HttpHeaders.userAgentHeader, 'intercom-flutter-sdk-check');
    request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    final response = await request.close();
    if (response.statusCode != 200) {
      final body = await response.transform(utf8.decoder).join();
      throw StateError('GitHub API error ${response.statusCode}: $body');
    }
    final body = await response.transform(utf8.decoder).join();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final tag = (data['tag_name'] ?? data['name'] ?? '').toString();
    final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(tag);
    if (match == null) {
      throw StateError('Unable to parse version from $tag');
    }
    return match.group(1)!;
  } finally {
    client.close();
  }
}

int _compareVersions(String left, String right) {
  final leftParts = left.split('.').map(int.parse).toList();
  final rightParts = right.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    final diff = leftParts[i].compareTo(rightParts[i]);
    if (diff != 0) {
      return diff;
    }
  }
  return 0;
}

String _joinPath(String root, String relative) {
  final separator = Platform.pathSeparator;
  final normalizedRelative = relative.replaceAll('/', separator);
  if (root.endsWith(separator)) {
    return root + normalizedRelative;
  }
  return root + separator + normalizedRelative;
}

String _readFile(String path) => File(path).readAsStringSync();

void _writeFile(String path, String contents) {
  File(path).writeAsStringSync(contents);
}

void _writeGithubOutputs(Map<String, String> outputs) {
  final outputPath = Platform.environment['GITHUB_OUTPUT'];
  if (outputPath == null || outputPath.isEmpty) {
    return;
  }
  final buffer = StringBuffer();
  outputs.forEach((key, value) {
    buffer.writeln('$key=$value');
  });
  File(outputPath).writeAsStringSync(buffer.toString(), mode: FileMode.append);
}

String _updateBuildGradle(String contents, String version) {
  var updated = contents.replaceAllMapped(
    RegExp(r'(io\.intercom\.android:intercom-sdk:)(\d+\.\d+\.\d+)'),
    (match) => '${match.group(1)}$version',
  );
  updated = updated.replaceAllMapped(
    RegExp(r'(io\.intercom\.android:intercom-sdk-ui:)(\d+\.\d+\.\d+)'),
    (match) => '${match.group(1)}$version',
  );
  return updated;
}

String _updatePackageSwift(String contents, String version) {
  return contents.replaceAllMapped(
    RegExp(r'(exact:\s*")(\d+\.\d+\.\d+)(")'),
    (match) => '${match.group(1)}$version${match.group(3)}',
  );
}

String _updateReadme(String contents, String androidVersion, String iosVersion) {
  var updated = contents.replaceAll(
    RegExp(r'Uses Intercom Android SDK Version `[^`]+`\.'),
    'Uses Intercom Android SDK Version `$androidVersion`.',
  );
  updated = updated.replaceAll(
    RegExp(r'Uses Intercom iOS SDK Version `[^`]+`\.'),
    'Uses Intercom iOS SDK Version `$iosVersion`.',
  );
  return updated;
}

String _bumpPatchVersion(String version) {
  final parts = version.split('.').map(int.parse).toList();
  if (parts.length != 3) {
    throw StateError('Unexpected version format: $version');
  }
  parts[2] += 1;
  return '${parts[0]}.${parts[1]}.${parts[2]}';
}

String _updatePubspec(String contents, String newVersion) {
  return contents.replaceAllMapped(
    RegExp(r'^(version:\s*)(\d+\.\d+\.\d+)(\s*)$', multiLine: true),
    (match) => '${match.group(1)}$newVersion${match.group(3)}',
  );
}

String _updateChangelog(String contents, String version, List<String> entries) {
  final newEntries = entries.where((entry) => !contents.contains(entry)).toList();
  if (newEntries.isEmpty) {
    return contents;
  }

  if (contents.contains('## $version')) {
    return contents;
  }

  final lines = contents.split('\n');
  final insertIndex = lines.indexWhere((line) => line.trim() == '# Changelog');
  if (insertIndex == -1) {
    throw StateError('Unable to find changelog header');
  }

  final updatedLines = <String>[];
  updatedLines.addAll(lines.take(insertIndex + 1));
  updatedLines.add('');
  updatedLines.add('## $version');
  updatedLines.add('');
  updatedLines.addAll(newEntries);
  updatedLines.add('');
  updatedLines.addAll(lines.skip(insertIndex + 1));
  return updatedLines.join('\n');
}

Future<void> main(List<String> args) async {
  var repoRoot = Directory.current.path;
  for (final arg in args) {
    if (arg.startsWith('--repo=')) {
      repoRoot = arg.substring('--repo='.length);
    }
  }

  final buildGradlePath = _joinPath(repoRoot, 'intercom_flutter/android/build.gradle');
  final packageSwiftPath = _joinPath(repoRoot, 'intercom_flutter/ios/intercom_flutter/Package.swift');
  final readmePath = _joinPath(repoRoot, 'intercom_flutter/README.md');
  final changelogPath = _joinPath(repoRoot, 'intercom_flutter/CHANGELOG.md');
  final pubspecPath = _joinPath(repoRoot, 'intercom_flutter/pubspec.yaml');

  final buildGradle = _readFile(buildGradlePath);
  final packageSwift = _readFile(packageSwiftPath);
  final readme = _readFile(readmePath);
  final changelog = _readFile(changelogPath);
  final pubspec = _readFile(pubspecPath);

  final androidMatch =
      RegExp(r'io\.intercom\.android:intercom-sdk:(\d+\.\d+\.\d+)').firstMatch(buildGradle);
  final iosMatch = RegExp(r'exact:\s*"(\d+\.\d+\.\d+)"').firstMatch(packageSwift);

  if (androidMatch == null || iosMatch == null) {
    throw StateError('Unable to detect current Intercom SDK versions.');
  }

  final currentAndroid = androidMatch.group(1)!;
  final currentIos = iosMatch.group(1)!;
  final versionMatch =
      RegExp(r'^(version:\s*)(\d+\.\d+\.\d+)(\s*)$', multiLine: true).firstMatch(pubspec);

  if (versionMatch == null) {
    throw StateError('Unable to detect current plugin version.');
  }

  final currentPluginVersion = versionMatch.group(2)!;

  stdout.writeln('Current Android SDK: $currentAndroid');
  stdout.writeln('Current iOS SDK: $currentIos');

  final latestAndroid = await _fetchLatestVersion(Uri.parse(_androidReleaseUrl));
  final latestIos = await _fetchLatestVersion(Uri.parse(_iosReleaseUrl));

  stdout.writeln('Latest Android SDK: $latestAndroid');
  stdout.writeln('Latest iOS SDK: $latestIos');

  final shouldUpdateAndroid = _compareVersions(latestAndroid, currentAndroid) > 0;
  final shouldUpdateIos = _compareVersions(latestIos, currentIos) > 0;
  final shouldUpdate = shouldUpdateAndroid || shouldUpdateIos;
  final nextPluginVersion = shouldUpdate
      ? _bumpPatchVersion(currentPluginVersion)
      : currentPluginVersion;

  _writeGithubOutputs({
    'android_version': latestAndroid,
    'ios_version': latestIos,
    'plugin_version': nextPluginVersion,
    'updates_available': shouldUpdate.toString(),
  });

  if (!shouldUpdate) {
    stdout.writeln('No updates found.');
    return;
  }

  var updatedBuildGradle = buildGradle;
  var updatedPackageSwift = packageSwift;
  var updatedReadme = readme;
  var updatedChangelog = changelog;
  var updatedPubspec = pubspec;

  if (shouldUpdateAndroid) {
    updatedBuildGradle = _updateBuildGradle(updatedBuildGradle, latestAndroid);
  }
  if (shouldUpdateIos) {
    updatedPackageSwift = _updatePackageSwift(updatedPackageSwift, latestIos);
  }

  updatedReadme = _updateReadme(
    updatedReadme,
    shouldUpdateAndroid ? latestAndroid : currentAndroid,
    shouldUpdateIos ? latestIos : currentIos,
  );

  final changelogEntries = <String>[];
  if (shouldUpdateAndroid) {
    changelogEntries.add(
      '* Bump Intercom Android SDK version to [$latestAndroid]($_androidReleasePage/tag/$latestAndroid)',
    );
  }
  if (shouldUpdateIos) {
    changelogEntries.add(
      '* Bump Intercom iOS SDK version to [$latestIos]($_iosReleasePage/tag/$latestIos)',
    );
  }

  updatedChangelog = _updateChangelog(updatedChangelog, nextPluginVersion, changelogEntries);
  updatedPubspec = _updatePubspec(updatedPubspec, nextPluginVersion);

  if (updatedBuildGradle != buildGradle) {
    _writeFile(buildGradlePath, updatedBuildGradle);
  }
  if (updatedPackageSwift != packageSwift) {
    _writeFile(packageSwiftPath, updatedPackageSwift);
  }
  if (updatedReadme != readme) {
    _writeFile(readmePath, updatedReadme);
  }
  if (updatedChangelog != changelog) {
    _writeFile(changelogPath, updatedChangelog);
  }
  if (updatedPubspec != pubspec) {
    _writeFile(pubspecPath, updatedPubspec);
  }

  stdout.writeln('Updates applied.');
}

#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

# Read Intercom SDK version from Package.swift (single source of truth)
package_swift = File.read(File.join(__dir__, 'intercom_flutter', 'Package.swift'))
intercom_version = package_swift.match(/exact:\s*"([^"]+)"/)[1]

Pod::Spec.new do |s|
  s.name             = 'intercom_flutter'
  s.version          = '9.0.0'
  s.summary          = 'Intercom integration for Flutter'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/ChangeFinance/intercom_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'xChange OÜ' => 'maido@getchange.com' }
  s.source           = { :path => '.' }
  s.source_files = 'intercom_flutter/Sources/intercom_flutter/**/*.{h,m}'
  s.public_header_files = 'intercom_flutter/Sources/intercom_flutter/include/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Intercom', intercom_version
  s.static_framework = true
  s.ios.deployment_target = '15.0'
end

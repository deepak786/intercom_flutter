package io.maido.intercom;

import android.util.Log;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import org.jetbrains.annotations.NotNull;

import java.util.Map;

import io.intercom.android.sdk.push.IntercomPushClient;

public class PushInterceptService extends FirebaseMessagingService {
  private static final String TAG = "PushInterceptService";
  private final IntercomPushClient intercomPushClient = new IntercomPushClient();

  @Override
  public void onMessageReceived(@NotNull RemoteMessage remoteMessage) {

    super.onMessageReceived(remoteMessage);

    Map<String, String> message = remoteMessage.getData();

    if (intercomPushClient.isIntercomPush(message)) {
      Log.d(TAG, "Intercom message received");
      intercomPushClient.handlePush(getApplication(), message);
    } else {
      Log.d(TAG, "Push message received, not for Intercom");
    }
  }

  @Override
  public void onNewToken(@NonNull @NotNull String s) {
    super.onNewToken(s);
  }
}

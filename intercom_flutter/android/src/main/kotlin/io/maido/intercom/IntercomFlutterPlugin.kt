package io.maido.intercom

import android.app.Application
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.intercom.android.sdk.Company
import io.intercom.android.sdk.Intercom
import io.intercom.android.sdk.UnreadConversationCountListener
import io.intercom.android.sdk.UserAttributes
import io.intercom.android.sdk.identity.Registration
import io.intercom.android.sdk.push.IntercomPushClient
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class IntercomFlutterPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
  companion object {
    @JvmStatic lateinit var application: Application

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "maido.io/intercom")
      application = registrar.context() as Application
      channel.setMethodCallHandler(IntercomFlutterPlugin())
      val unreadEventChannel = EventChannel(registrar.messenger(), "maido.io/intercom/unread")
      unreadEventChannel.setStreamHandler(IntercomFlutterPlugin())
    }
  }

  private val intercomPushClient = IntercomPushClient()
  private var unreadConversationCountListener: UnreadConversationCountListener? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "maido.io/intercom")
    channel.setMethodCallHandler(IntercomFlutterPlugin())
    val unreadEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "maido.io/intercom/unread")
    unreadEventChannel.setStreamHandler(IntercomFlutterPlugin())
    application = flutterPluginBinding.applicationContext as Application
  }

  // https://stackoverflow.com/a/62206235
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    application = binding.activity.application
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
        "initialize" -> {
          val apiKey = call.argument<String>("androidApiKey")
          val appId = call.argument<String>("appId")
          Intercom.initialize(application, apiKey, appId)
          result.success("Intercom initialized")
        }
        "setBottomPadding" -> {
          val padding = call.argument<Int>("bottomPadding")
          if(padding != null) {
            Intercom.client().setBottomPadding(padding)
            result.success("Bottom padding set")
          }
        }
        "setUserHash" -> {
          val userHash = call.argument<String>("userHash")
          if(userHash != null) {
            Intercom.client().setUserHash(userHash)
            result.success("User hash added")
          }
        }
        "registerIdentifiedUserWithUserId" -> {
          val userId = call.argument<String>("userId")
          if(userId != null) {
            var registration = Registration.create()
            registration = registration.withUserId(userId)
            Intercom.client().registerIdentifiedUser(registration)
            result.success("User created")
          }
        }
        "registerIdentifiedUserWithEmail" -> {
          val email = call.argument<String>("email")
          if(email != null) {
            var registration = Registration.create()
            registration = registration.withEmail(email)
            Intercom.client().registerIdentifiedUser(registration)
            result.success("User created")
          }
        }
        "registerUnidentifiedUser" -> {
          Intercom.client().registerUnidentifiedUser()
          result.success("User created")
        }
        "logout" -> {
          Intercom.client().logout()
          result.success("logout")
        }
        "setLauncherVisibility" -> {
          val visibility = call.argument<String>("visibility")
          if(visibility != null) {
            Intercom.client().setLauncherVisibility(Intercom.Visibility.valueOf(visibility))
            result.success("Showing launcher: $visibility")
          }
        }
        "displayMessenger" -> {
          Intercom.client().displayMessenger()
          result.success("Launched")
        }
        "hideMessenger" -> {
          Intercom.client().hideMessenger()
          result.success("Hidden")
        }
        "displayHelpCenter" -> {
          Intercom.client().displayHelpCenter()
          result.success("Launched")
        }
        "setInAppMessagesVisibility" -> {
          val visibility = call.argument<String>("visibility")
          if(visibility != null) {
            Intercom.client().setInAppMessageVisibility(Intercom.Visibility.valueOf(visibility))
            result.success("Showing in app messages: $visibility")
          } else {
            result.success("Launched")
          }
        }
        "unreadConversationCount" -> {
          val count = Intercom.client().unreadConversationCount
          result.success(count)
        }
        "updateUser" -> {
          Intercom.client().updateUser(getUserAttributes(call))
          result.success("User updated")
        }
        "logEvent" -> {
          val name = call.argument<String>("name")
          val metaData = call.argument<Map<String, Any>>("metaData")
          if(name != null) {
            Intercom.client().logEvent(name, metaData)
            result.success("Logged event")
          }
        }
        "sendTokenToIntercom" -> {
          val token = call.argument<String>("token")
          val metaData = call.argument<Map<String, Any>>("metaData")
          if(token != null) {
            intercomPushClient.sendTokenToIntercom(application, token)

            result.success("Token sent to Intercom")
          }
        }
        "handlePushMessage" -> {
          Intercom.client().handlePushMessage()
          result.success("Push message handled")
        }
        "displayMessageComposer" -> {
          if (call.hasArgument("message")) {
            Intercom.client().displayMessageComposer(call.argument("message"))
          } else {
            Intercom.client().displayMessageComposer()
          }
          result.success("Message composer displayed")
        }
        "isIntercomPush" -> {
          result.success(intercomPushClient.isIntercomPush(call.argument<Map<String, String>>("message")!!))
        }
        "handlePush" -> {
          intercomPushClient.handlePush(application, call.argument<Map<String, String>>("message")!!)
          result.success(null)
        }
        "displayArticle" -> {
          val articleId = call.argument<String>("articleId")
          if(articleId != null){
            Intercom.client().displayArticle(articleId)
            result.success("displaying article $articleId")
          }
        }
        "displayCarousel" -> {
          val carouselId = call.argument<String>("carouselId")
          if(carouselId != null){
            Intercom.client().displayCarousel(carouselId)
            result.success("displaying carousel $carouselId")
          }
        }
        else -> result.notImplemented()
    }
  }

  // generate the user attributes
  private fun getUserAttributes(call: MethodCall): UserAttributes {
    // user attributes
    val name = call.argument<String>("name")
    val email = call.argument<String>("email")
    val phone = call.argument<String>("phone")
    val userId = call.argument<String>("userId")
    val company = call.argument<String>("company")
    val companyId = call.argument<String>("companyId")
    val customAttributes = call.argument<Map<String, Any?>>("customAttributes")
    val signedUpAt = call.argument<Any?>("signedUpAt")
    val language = call.argument<String>("language")

    val userAttributes = UserAttributes.Builder()

    if (name != null) {
      userAttributes.withName(name)
    }

    if (email != null) {
      userAttributes.withEmail(email)
    }

    if (phone != null) {
      userAttributes.withPhone(phone)
    }

    if (userId != null) {
      userAttributes.withUserId(userId)
    }

    if (company != null && companyId != null) {
      val icmCompany = Company.Builder()
      icmCompany.withName(company)
      icmCompany.withCompanyId(companyId)
      userAttributes.withCompany(icmCompany.build())
    }

    if (customAttributes != null) {
      for ((key, value) in customAttributes) {
        userAttributes.withCustomAttribute(key, value)
      }
    }

    val seconds: Long? = signedUpAt?.toString()?.toLongOrNull()
    if (seconds != null)
      userAttributes.withSignedUpAt(seconds)
    
    if (language != null) {
      userAttributes.withLanguageOverride(language)
    }

    return userAttributes.build()
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    unreadConversationCountListener = UnreadConversationCountListener { count -> events?.success(count) }
        .also {
          Intercom.client().addUnreadConversationCountListener(it)
        }
  }

  override fun onCancel(arguments: Any?) {
    if (unreadConversationCountListener != null) {
      Intercom.client().removeUnreadConversationCountListener(unreadConversationCountListener)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    if (unreadConversationCountListener != null) {
      Intercom.client().removeUnreadConversationCountListener(unreadConversationCountListener)
    }
  }

  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }
}

package io.maido.intercom

import android.app.Application
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.intercom.android.sdk.*
import io.intercom.android.sdk.identity.Registration
import io.intercom.android.sdk.push.IntercomPushClient
import io.intercom.android.sdk.ui.theme.ThemeMode

class IntercomFlutterPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
  companion object {
    @JvmStatic
    lateinit var application: Application

    @JvmStatic
    fun initSdk(application: Application, appId: String, androidApiKey: String) {
      Intercom.initialize(application, apiKey = androidApiKey, appId = appId)
    }
  }

  private val intercomPushClient = IntercomPushClient()
  private var unreadConversationCountListener: UnreadConversationCountListener? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "maido.io/intercom")
    channel.setMethodCallHandler(IntercomFlutterPlugin())
    val unreadEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "maido.io/intercom/unread")
    unreadEventChannel.setStreamHandler(IntercomFlutterPlugin())
    val windowDidHideEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "maido.io/intercom/windowDidHide")
    windowDidHideEventChannel.setStreamHandler(IntercomFlutterPlugin())
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
        if (padding != null) {
          Intercom.client().setBottomPadding(padding)
          result.success("Bottom padding set")
        }
      }
      "setUserHash" -> {
        val userHash = call.argument<String>("userHash")
        if (userHash != null) {
          Intercom.client().setUserHash(userHash)
          result.success("User hash added")
        }
      }
      "loginIdentifiedUserWithUserId" -> {
        val userId = call.argument<String>("userId")
        if (userId != null) {
          var registration = Registration.create()
          registration = registration.withUserId(userId)
          Intercom.client().loginIdentifiedUser(registration, intercomStatusCallback = object : IntercomStatusCallback {
            override fun onFailure(intercomError: IntercomError) {
              // Handle failure
              result.error(intercomError.errorCode.toString(), intercomError.errorMessage, getIntercomError(
                  errorCode = intercomError.errorCode,
                  errorMessage = intercomError.errorMessage,
              ))
            }

            override fun onSuccess() {
              // Handle success
              result.success("User created")
            }
          })
        }
      }
      "loginIdentifiedUserWithEmail" -> {
        val email = call.argument<String>("email")
        if (email != null) {
          var registration = Registration.create()
          registration = registration.withEmail(email)
          Intercom.client().loginIdentifiedUser(registration, intercomStatusCallback = object : IntercomStatusCallback {
            override fun onFailure(intercomError: IntercomError) {
              // Handle failure
              result.error(intercomError.errorCode.toString(), intercomError.errorMessage, getIntercomError(
                  errorCode = intercomError.errorCode,
                  errorMessage = intercomError.errorMessage,
              ))
            }

            override fun onSuccess() {
              // Handle success
              result.success("User created")
            }
          })
        }
      }
      "loginUnidentifiedUser" -> {
        Intercom.client().loginUnidentifiedUser(intercomStatusCallback = object : IntercomStatusCallback {
          override fun onFailure(intercomError: IntercomError) {
            // Handle failure
            result.error(intercomError.errorCode.toString(), intercomError.errorMessage, getIntercomError(
                errorCode = intercomError.errorCode,
                errorMessage = intercomError.errorMessage,
            ))
          }

          override fun onSuccess() {
            // Handle success
            result.success("User created")
          }
        })
      }
      "logout" -> {
        Intercom.client().logout()
        result.success("logout")
      }
      "setLauncherVisibility" -> {
        val visibility = call.argument<String>("visibility")
        if (visibility != null) {
          Intercom.client().setLauncherVisibility(Intercom.Visibility.valueOf(visibility))
          result.success("Showing launcher: $visibility")
        }
      }
      "displayMessenger" -> {
        Intercom.client().present()
        result.success("Launched")
      }
      "hideMessenger" -> {
        Intercom.client().hideIntercom()
        result.success("Hidden")
      }
      "displayHelpCenter" -> {
        Intercom.client().present(IntercomSpace.HelpCenter)
        result.success("Launched")
      }
      "displayHelpCenterCollections" -> {
        val collectionIds = call.argument<ArrayList<String>>("collectionIds")
        Intercom.client().presentContent(
          content = IntercomContent.HelpCenterCollections(
            ids = collectionIds ?: emptyList()
          )
        )
        result.success("Launched")
      }
      "displayMessages" -> {
        Intercom.client().present(IntercomSpace.Messages)
        result.success("Launched")
      }
      "setInAppMessagesVisibility" -> {
        val visibility = call.argument<String>("visibility")
        if (visibility != null) {
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
        Intercom.client().updateUser(getUserAttributes(call), intercomStatusCallback = object : IntercomStatusCallback {
          override fun onFailure(intercomError: IntercomError) {
            // Handle failure
            result.error(intercomError.errorCode.toString(), intercomError.errorMessage, getIntercomError(
                errorCode = intercomError.errorCode,
                errorMessage = intercomError.errorMessage,
            ))
          }

          override fun onSuccess() {
            // Handle success
            result.success("User updated")
          }
        })
      }
      "logEvent" -> {
        val name = call.argument<String>("name")
        val metaData = call.argument<Map<String, *>>("metaData")
        if (name != null) {
          Intercom.client().logEvent(name, metaData)
          result.success("Logged event")
        }
      }
      "sendTokenToIntercom" -> {
        val token = call.argument<String>("token")
        if (token != null) {
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
        if (articleId != null) {
          Intercom.client().presentContent(IntercomContent.Article(articleId))
          result.success("displaying article $articleId")
        }
      }
      "displayCarousel" -> {
        val carouselId = call.argument<String>("carouselId")
        if (carouselId != null) {
          Intercom.client().presentContent(IntercomContent.Carousel(carouselId))
          result.success("displaying carousel $carouselId")
        }
      }
      "displaySurvey" -> {
        val surveyId = call.argument<String>("surveyId")
        if (surveyId != null) {
          Intercom.client().presentContent(IntercomContent.Survey(surveyId))
          result.success("displaying survey $surveyId")
        }
      }
      "displayConversation" -> {
        val conversationId = call.argument<String>("conversationId")
        if (conversationId != null) {
          Intercom.client().presentContent(IntercomContent.Conversation(conversationId))
          result.success("displaying conversation $conversationId")
        }
      }
      "displayTickets" -> {
        Intercom.client().present(IntercomSpace.Tickets)
        result.success("Launched Tickets space")
      }
      "displayHome" -> {
        Intercom.client().present(IntercomSpace.Home)
        result.success("Launched Home space")
      }
      "isUserLoggedIn" -> {
        result.success(Intercom.client().isUserLoggedIn())
      }
      "fetchLoggedInUserAttributes" -> {
        val reg = Intercom.client().fetchLoggedInUserAttributes()
        val map = reg?.attributes?.toMap() ?: mutableMapOf<String, Any>()
        if(reg != null){
          // put the user_id and email from registration
          map["user_id"] = reg.userId
          map["email"] = reg.email
        }
        result.success(map)
      }
      "setUserJwt" -> {
        val jwt = call.argument<String>("jwt")
        if (jwt != null) {
          Intercom.client().setUserJwt(jwt)
          result.success("Jwt added")
        }
      }
      "setAuthTokens" -> {
        val tokens = call.argument<Map<String, String>>("tokens")
        if (!tokens.isNullOrEmpty()) {
          val tokenList: List<AuthToken> = tokens.map { (key, value) ->
            AuthToken(key, value)
          }
          Intercom.client().setAuthTokens(tokenList, intercomStatusCallback = object : IntercomStatusCallback {
            override fun onFailure(intercomError: IntercomError) {
              // Handle failure
              result.error(intercomError.errorCode.toString(), intercomError.errorMessage, getIntercomError(
                errorCode = intercomError.errorCode,
                errorMessage = intercomError.errorMessage,
              ))
            }

            override fun onSuccess() {
              // Handle success
              result.success("Auth tokens added")
            }
          })
        }
      }
      "setThemeMode" -> {
        val theme = call.argument<String>("theme")
        when (theme) {
            "dark" -> {
              Intercom.client().setThemeMode(ThemeMode.DARK)
            }
            "light" -> {
              Intercom.client().setThemeMode(ThemeMode.LIGHT)
            }
            "system" -> {
              Intercom.client().setThemeMode(ThemeMode.SYSTEM)
            }
            else -> {
              Intercom.client().setThemeMode(null)
            }
        }
        result.success("Theme overridden")
      }
      else -> result.notImplemented()
    }
  }

  // generate a errorDetails object to pass
  private fun getIntercomError(errorCode: Int = -1, errorMessage: String = ""): Map<String, *> {
    return mapOf(
        "errorCode" to errorCode,
        "errorMessage" to errorMessage,
    )
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
    // Check if this is the unread stream or windowDidHide stream
    // For unread stream, we set up the listener
    // For windowDidHide stream, we don't set up anything since it's iOS-specific
    if (arguments == null || arguments.toString().contains("unread") || arguments.toString().isEmpty()) {
      // This is the unread stream
      unreadConversationCountListener = UnreadConversationCountListener { count ->
          val handler = android.os.Handler(android.os.Looper.getMainLooper())
          handler.post {
            events?.success(count)
          }
        }.also {
          Intercom.client().addUnreadConversationCountListener(it)
        }
    }
    // For windowDidHide stream, we don't need to do anything since it's iOS-specific
    // The stream will not emit any events on Android
  }

  override fun onCancel(arguments: Any?) {
    if (unreadConversationCountListener != null) {
      Intercom.client().removeUnreadConversationCountListener(unreadConversationCountListener)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
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

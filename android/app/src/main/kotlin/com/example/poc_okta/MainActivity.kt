package com.example.poc_okta

import android.content.ContentValues
import android.util.Log
import com.okta.idx.sdk.api.client.IDXAuthenticationWrapper
import com.okta.idx.sdk.api.model.AuthenticationOptions
import com.okta.idx.sdk.api.model.AuthenticationStatus
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.KeyData.CHANNEL
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.async
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    val CHANNEL = "com.okta_poc"
     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
        Log.i("is this working,","${ MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )}")
        try {
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            ).setMethodCallHandler { call, result ->
                if (call.method == "signin") {
                    getToken(result)
                } else {
                    Log.i("is this working,","saklkdjflasjdf")
                    result.notImplemented()
                }

            }
        }catch (e: Exception) {
            Log.i("EXX","${e.localizedMessage}")

        }

    }

    fun getToken(result: MethodChannel.Result) {

        GlobalScope.async {

            val authenticationWrapper = Network.authenticationWrapper()
            val response1 = authenticationWrapper.begin()
            val options =
                AuthenticationOptions("naty2work@gmail.com", "Nat123456".toCharArray())

            Log.d(
                ContentValues.TAG,
                "Context proceed is: Starting ---- ===${response1.proceedContext} "
            )
            val response = authenticationWrapper.authenticate(options, response1.proceedContext)
            if (response.tokenResponse != null) {
                Log.d(ContentValues.TAG, "Handle Response ===>>>>>>>: ${response}")

                val rootObject = JSONObject()
                rootObject.put("accessToken","${response.tokenResponse.accessToken}")
                rootObject.put("id","${response.tokenResponse.idToken}")
                rootObject.put("tokenType","${response.tokenResponse.tokenType}")
                rootObject.put("isRefreshing",false)
                rootObject.put("isValid",true)
                rootObject.put("isExpired",false)
                rootObject.put("refreshToken","${response.tokenResponse.refreshToken}")
                rootObject.put("deviceSecret","")
                rootObject.put("refreshToken","")

                result.success(rootObject.toString())
            }
            if (response.authenticationStatus == AuthenticationStatus.SKIP_COMPLETE) {
                Log.d(ContentValues.TAG, "Handle Response ===>>>>>>>: ${response.errors}")
            }
            if (response.errors.isNotEmpty()) {
                Log.d(ContentValues.TAG, "Handle Response ===>>>>>>>: ${response.errors}")
            }


            Log.d(
                ContentValues.TAG,
                "Handle Response ===>>>>>>>: ${response.authenticationStatus}"
            )

        }
    }
}


object Network {
    fun authenticationWrapper(): IDXAuthenticationWrapper {
        return IDXAuthenticationWrapper(
            "https://dev-08901952.okta.com/oauth2/default",
            "0oa6n8dw1yIMgQ5RE5d7",
            null, // Client secret should not be used on Android.
            setOf("openid", "email", "profile", "offline_access"),
            "com.embeddedauth://callback"
        )
    }
}

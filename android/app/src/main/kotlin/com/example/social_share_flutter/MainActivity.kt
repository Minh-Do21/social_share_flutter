package com.example.social_share_flutter

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
import android.util.Base64
import android.util.Log
import androidx.core.content.FileProvider
import com.facebook.CallbackManager
import com.facebook.FacebookCallback
import com.facebook.FacebookException
import com.facebook.FacebookSdk
import com.facebook.LoggingBehavior
import com.facebook.share.Sharer
import com.facebook.share.model.ShareLinkContent
import com.facebook.share.model.SharePhoto
import com.facebook.share.model.SharePhotoContent
import com.facebook.share.widget.ShareDialog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.social_share_flutter"
    private lateinit var callbackManager: CallbackManager


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)


        // Khởi tạo CallbackManager
        callbackManager = CallbackManager.Factory.create()


        FacebookSdk.setIsDebugEnabled(true)
        FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS)

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL).setMethodCallHandler { call, result ->
                if (call.method == "shareLinkOnFacebook") {
                    val args = call.arguments as Map<*, *>
                    val url = args["url"] as? String
                    val imagePath = args["imagePath"] as? String

                    shareImageAndLinkOnFacebook(url, imagePath, result)
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // Bắt kết quả từ ShareDialog
        callbackManager.onActivityResult(requestCode, resultCode, data)
    }

    private fun shareImageAndLinkOnFacebook(url: String?, imagePath: String?, result: MethodChannel.Result) {
        val shareDialog = ShareDialog(this)

        // Đăng ký callback cho ShareDialog
        shareDialog.registerCallback(callbackManager, object :
            FacebookCallback<Sharer.Result> {

            override fun onCancel() {
                result.error("ERROR", "Share Cancelled", null)
            }

            override fun onError(error: FacebookException) {
                result.error("ERROR", "Share Error: ${error?.message}", null)
            }

            override fun onSuccess(_result: Sharer.Result) {
                result.success("Link shared successfully")
            }
        })

        try {
            // Chia sẻ hình ảnh nếu có imagePath
            if (!imagePath.isNullOrEmpty()) {
                val imageFile = File(imagePath)
                if (!imageFile.exists()) {
                    Log.e("FacebookShare", "Image file does not exist at path: $imagePath")
                    result.error("FILE_NOT_FOUND", "Image file does not exist", null)
                    return
                }

                val bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
                    Log.e("FacebookShare", "Failed to decode bitmap from imagePath")
                    result.error("INVALID_IMAGE", "Failed to decode bitmap from imagePath", null)
                    return
                }

                val content = SharePhotoContent.Builder()
                    .addPhoto(SharePhoto.Builder().setBitmap(bitmap).build())
                    .build()

                if (shareDialog.canShow(content)) {
                    shareDialog.show(content)
                    Log.d("FacebookShare", "Showing SharePhotoContent")
                } else {
                    Log.e("FacebookShare", "Cannot show share dialog for image")
                    result.error("UNAVAILABLE", "Cannot show share dialog for image", null)
                }
            }
            // Chia sẻ URL nếu có url và không có imagePath
            else if (!url.isNullOrEmpty()) {
                val uri = Uri.parse(url)

                val content = ShareLinkContent.Builder()
                    .setContentUrl(uri)
                    .build()

                if (shareDialog.canShow(content)) {
                    shareDialog.show(content)
                } else {
                    result.error("UNAVAILABLE", "Cannot show share dialog for link", null)
                }
            } else {
                Log.e("FacebookShare", "Both imagePath and URL are null or empty")
                result.error("INVALID_INPUT", "Both imagePath and URL are null or empty", null)
            }
        } catch (e: Exception) {
            Log.e("FacebookShare", "Error sharing content: ${e.message}", e)
            result.error("ERROR", "Error sharing content: ${e.localizedMessage}", null)
        }
    }
}



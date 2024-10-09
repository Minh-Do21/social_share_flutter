package com.example.social_share_flutter

import android.R.attr.text
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Bundle
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


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.social_share_flutter"
    private lateinit var callbackManager: CallbackManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Khởi tạo CallbackManager
        callbackManager = CallbackManager.Factory.create()

        // Facebook SDK
        FacebookSdk.setIsDebugEnabled(true)
        FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS)

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareToFacebook" -> shareToFacebook(call.arguments as Map<*, *>, result)
                    "shareToInstagramFeed" -> shareToInstagramFeed(call.argument("imagePath"), result)
                    "shareToLine" -> shareToLine(call.argument("imagePath"), call.argument("url"), result)
                    "shareToPinterest" -> shareToPinterest(call.argument("url"), result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        callbackManager.onActivityResult(requestCode, resultCode, data)
    }

    private fun shareToFacebook(args: Map<*, *>, result: MethodChannel.Result) {
        val url = args["url"] as? String
        val imagePath = args["imagePath"] as? String

        val shareDialog = ShareDialog(this)
        shareDialog.registerCallback(callbackManager, object : FacebookCallback<Sharer.Result> {
            override fun onCancel() {
                result.error("ERROR", "Share Cancelled", null)
            }

            override fun onError(error: FacebookException) {
                result.error("ERROR", "Share Error: ${error.message}", null)
            }

            override fun onSuccess(_result: Sharer.Result) {
                result.success("Link shared successfully")
            }
        })

        try {
            // Chia sẻ hình ảnh nếu có imagePath
            if (!imagePath.isNullOrEmpty()) {
                shareFacebookImage(imagePath, shareDialog, result)
            } else if (!url.isNullOrEmpty()) {
                shareFacebookLink(url, shareDialog, result)
            } else {
                result.error("INVALID_INPUT", "Both imagePath and URL are null or empty", null)
            }
        } catch (e: Exception) {
            result.error("ERROR", "Error sharing content: ${e.localizedMessage}", null)
        }
    }

    private fun shareFacebookImage(imagePath: String, shareDialog: ShareDialog, result: MethodChannel.Result) {
        val imageFile = File(imagePath)
        if (!imageFile.exists()) {
            result.error("FILE_NOT_FOUND", "Image file does not exist", null)
            return
        }

        val bitmap = BitmapFactory.decodeFile(imagePath) ?: run {
            result.error("INVALID_IMAGE", "Failed to decode bitmap from imagePath", null)
            return
        }

        val content = SharePhotoContent.Builder()
            .addPhoto(SharePhoto.Builder().setBitmap(bitmap).build())
            .build()

        if (shareDialog.canShow(content)) {
            shareDialog.show(content)
        } else {
            result.error("UNAVAILABLE", "Cannot show share dialog for image", null)
        }
    }

    private fun shareFacebookLink(url: String, shareDialog: ShareDialog, result: MethodChannel.Result) {
        val uri = Uri.parse(url)

        val content = ShareLinkContent.Builder()
            .setContentUrl(uri)
            .build()

        if (shareDialog.canShow(content)) {
            shareDialog.show(content)
        } else {
            result.error("UNAVAILABLE", "Cannot show share dialog for link", null)
        }
    }

    private fun shareToInstagramFeed(imagePath: String?, result: MethodChannel.Result) {
        if (imagePath == null) {
            result.error("ERROR", "Image path is null", null)
            return
        }

        val imageFile = File(imagePath)
        if (imageFile.exists()) {
            val imageUri: Uri = FileProvider.getUriForFile(
                this, "$packageName.fileprovider", imageFile
            )

            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "image/*"
                putExtra(Intent.EXTRA_STREAM, imageUri)
                setPackage("com.instagram.android") // Chỉ định mở Instagram trực tiếp
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            try {
                startActivity(intent)
                result.success("Shared successfully")
            } catch (e: Exception) {
                result.error("UNAVAILABLE", "Instagram app is not installed", null)
            }
        } else {
            result.error("UNAVAILABLE", "Image file does not exist at path: $imagePath", null)
        }
    }

    private fun shareToLine(imagePath: String?, url: String?, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
        }

        // Kiểm tra nếu có đường dẫn ảnh
        if (!imagePath.isNullOrEmpty()) {
            val imageFile = File(imagePath)
            if (imageFile.exists()) {
                val imageUri: Uri = FileProvider.getUriForFile(
                    this, "$packageName.fileprovider", imageFile
                )
                intent.putExtra(Intent.EXTRA_STREAM, imageUri)
                intent.type = "image/*" // Cập nhật type cho ảnh
            } else {
                result.error("FILE_NOT_FOUND", "Image file does not exist", null)
                return
            }
        }

        // Kiểm tra nếu có URL
        if (!url.isNullOrEmpty()) {
            intent.putExtra(Intent.EXTRA_TEXT, url)
        }

        // Chỉ định ứng dụng Line
        intent.setPackage("jp.naver.line.android")

        try {
            startActivity(intent)
            result.success("Shared to Line successfully")
        } catch (e: ActivityNotFoundException) {
            result.error("UNAVAILABLE", "Line app is not installed", null)
        }
    }

    private fun shareToPinterest(url: String?, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_SEND)
        intent.type = "text/plain"
        intent.putExtra(Intent.EXTRA_TEXT, url)
        intent.setPackage("com.pinterest")

        try {
            startActivity(intent)
            result.success("Shared to Pinterest successfully")
        } catch (e: ActivityNotFoundException) {
            result.error("UNAVAILABLE", "Line Pinterest is not installed", null)
        }
    }
}



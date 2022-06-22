package com.atritechnocrat.flutter_multimedia_picker

import android.content.Context
import android.os.Handler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class FlutterMultiMediaPickerPlugin(private val context: Context) : MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "fullter_multimedia_picker")
      channel.setMethodCallHandler(FlutterMultiMediaPickerPlugin(registrar.context()))
    }
  }

  private val executor: ExecutorService = Executors.newFixedThreadPool(1)
  private val mainHandler by lazy { Handler(context.mainLooper) }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when {
      call.method == "getThumbnail" -> {
        val fileId = call.argument<String>("fileId")
        val type = call.argument<Int>("type")
        if (fileId == null || type == null) {
          result.error("INVALID_ARGUMENTS", "fileId or type must not be null", null)
          return
        }
        executor.execute {
          val thumbnail = FileFetcher.getThumbnail(
                  context,
                  fileId.toLong(),
                  MediaFile.MediaType.values()[type]
          )
          mainHandler.post {
            if (thumbnail != null)
              result.success(thumbnail)
            else
              result.error("NOT_FOUND", "Unable to get the thumbnail", null)
          }
        }
      }

      call.method == "getMediaFile" -> {
        val fileIdString = call.argument<String>("fileId")
        val type = call.argument<Int>("type")

        if (fileIdString == null || type == null ) {
          result.error("INVALID_ARGUMENTS", "fileId,  or type must not be null", null)
          return
        }

        val fileId = fileIdString.toLongOrNull()
        if (fileId == null) {
          result.error("NOT_FOUND", "Unable to find the file", null)
          return
        }

        executor.execute {
          val mediaFile = FileFetcher.getMediaFile(
                  context,
                  fileId,
                  MediaFile.MediaType.values()[type],
                  true)
          mainHandler.post {
            if (mediaFile != null)
              result.success(mediaFile.toJSONObject().toString())
            else
              result.error("NOT_FOUND", "Unable to find the file", null)
          }
        }
      }

      call.method == "getImage" -> {
        val image = FileFetcher.getImage(context)
        result.success(image.toString())
      }

      call.method == "getVideo" -> {
        val video = FileFetcher.getVideo(context)
        result.success(video.toString())
      }

      call.method == "getAll" -> {
        val video = FileFetcher.getAll(context)
        result.success(video.toString())
      }

      else -> result.notImplemented()

    }
  }
}

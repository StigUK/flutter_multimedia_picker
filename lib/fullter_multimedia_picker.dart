import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'data/MediaFile.dart';

class FlutterMultiMediaPicker {
  static const MethodChannel _channel =
      const MethodChannel('fullter_multimedia_picker');

  static Future<List<MediaFile>?> getAll() async {
    final String? json = await _channel.invokeMethod("getAll");
    if (json == null) return null;
    final encoded = jsonDecode(json);
    return encoded
        .map<MediaFile>((mediaFile) => MediaFile.fromJson(mediaFile))
        .toList();
  }

  static Future<List<MediaFile>?> getImage() async {
    final String? json = await _channel.invokeMethod("getImage");
    if (json == null) return null;
    final encoded = jsonDecode(json);
    return encoded
        .map<MediaFile>((mediaFile) => MediaFile.fromJson(mediaFile))
        .toList();
  }

  static Future<List<MediaFile>?> getVideo() async {
    final String? json = await _channel.invokeMethod("getVideo");
    if (json == null) return null;
    final encoded = jsonDecode(json);
    return encoded
        .map<MediaFile>((mediaFile) => MediaFile.fromJson(mediaFile))
        .toList();
  }

  static Future<MediaFile?> getMediaFile({
    required String fileId,
    required MediaType type,
  }) async {
    final String? json = await _channel.invokeMethod(
      'getMediaFile',
      {"fileId": fileId, "type": type.index},
    );
    if (json == null) return null;
    final encoded = jsonDecode(json);
    return MediaFile.fromJson(encoded);
  }

  static Future<String?> getThumbnail({
    required String fileId,
    required MediaType type,
  }) =>
      _channel.invokeMethod(
        'getThumbnail',
        {
          "fileId": fileId,
          "type": type.index,
        },
      );

  static int orientationToQuarterTurns(int orientationInDegrees) {
    switch (orientationInDegrees) {
      case 90:
        return 1;
      case 180:
        return 2;
      case 270:
        return 3;
      default:
        return 0;
    }
  }
}

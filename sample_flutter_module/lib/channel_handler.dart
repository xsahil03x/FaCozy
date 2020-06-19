import 'package:flutter/services.dart';

class ChannelHandler {
  static const _methodChannel = const MethodChannel('fa_cozy_method_channel');

  static void setMethodCallHandler(Future<dynamic> handler(MethodCall call)) {
    _methodChannel.setMethodCallHandler(handler);
  }

  static Future<T> invokeMethod<T>(String method, [dynamic arguments]) {
    return _methodChannel.invokeMethod(method, arguments);
  }
}

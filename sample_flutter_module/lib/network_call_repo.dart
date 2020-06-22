import 'package:dio/dio.dart';

class NetworkCallRepo {
  static final NetworkCallRepo _singleton = NetworkCallRepo._internal();

  factory NetworkCallRepo() {
    return _singleton;
  }

  NetworkCallRepo._internal();

  Future<String> getCurrentIpAddress() async {
    final data = await Dio().get("https://api.ipify.org/?format=json");
    return data.data["ip"];
  }
}

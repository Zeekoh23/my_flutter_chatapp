import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/http_exception.dart';
import '../helpers/url_helper.dart';

const appId = "4d0c85ee1d2d41b99c3e873f498f7c84";

class AgoraProvider with ChangeNotifier {
  var log = Logger();
  var baseurl = UrlHelper.shared;

  Future<String> agoraToken() async {
    try {
      late String token;
      var url =
          Uri.parse('${baseurl.baseUrl}/accesstoken?channelName=channelname');
      final headers = {"Content-type": "application/json"};
      final res = await http.get(url, headers: headers);
      final extractData = json.decode(res.body);
      token = extractData['token'];

      return token;
    } catch (err) {
      throw HttpException('agora token error is $err');
    }
  }
}

import 'dart:convert';

import 'package:chat_easy/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/message_model.dart';
import '../helpers/url_helper.dart';

import '../models/typing_model.dart';
import '../helpers/socket_helper.dart';

class MessageProvider with ChangeNotifier {
  var baseurl = UrlHelper.shared;
  List<Message> _messages = [];
  var log = Logger();
  var socket = SocketHelper.shared;
  List<TypingModel> type1 = [];
  List<Message> get items {
    return [..._messages];
  }

  List<Message> demeChatMessages = [];

  final String number;
  MessageProvider(this.number);

  Future<void> fetchMessages(String sender, String receiver) async {
    try {
      final url = Uri.parse("${baseurl.baseUrl}/api/v1/socket/fetchmessage");
      final headers = {"Content-type": "application/json"};

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'senderid': number,
          'receiverid': receiver,
        }),
      );
      final resData = json.decode(response.body);

      resData.forEach((msgId, msgData) {
        //using the globally declared variable in MsgController
        socket.msgController.loadMessages.add(Message(
            id: msgId,
            text: msgData['text'],
            isSender: msgData['isSender'],
            type1: msgData['type1'],
            time: msgData['time'],
            path: msgData['path'],
            videopath: msgData['videopath']));
      });
      log.i(resData);
      socket.msgController.messages1 = socket.msgController.loadMessages;
      notifyListeners();
    } catch (err) {
      throw HttpException('fetch message error is $err');
    }
  }
}

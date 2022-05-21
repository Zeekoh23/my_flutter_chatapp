import 'package:flutter/material.dart';

enum MessageType { text, audio, image, video }

enum MessageStatus { not_sent, not_view, viewed }

class Message with ChangeNotifier {
  final String? id;
  final String? text;
  final MessageType? messageType;
  final MessageStatus? messageStatus;
  final bool isSender;
  final String type1;
  final String? senderid;
  final String? receiverid;
  //final String sentByme;
  final String time;
  final String path;
  final String? videopath;

  Message(
      {this.id,
      this.text,
      this.messageType,
      required this.type1,
      this.messageStatus,
      this.senderid,
      this.receiverid,
      required this.isSender,
      //required this.sentByme,
      required this.time,
      required this.path,
      this.videopath});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        text: json['text'],
        messageType: json['messageType'],
        type1: json['type1'],
        isSender: json['isSender'],
        //sentByme: json['']
        time: json['time'],
        //time: DateTime.now().toString().substring(10, 16),
        path: json['path'],
        videopath: json['videopath']);
  }
}

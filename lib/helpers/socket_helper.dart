import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/message_model.dart';
import './url_helper.dart';
import '../controllers/msg_controller.dart';
import '../controllers/type_controller.dart';
import '../providers/user_provider.dart';
import './list_helper.dart';
import './get_it1.dart';
import '../models/typing_model.dart';
import '../widgets/notification_api.dart';

class SocketHelper {
  static final shared = SocketHelper();
  var baseurl = UrlHelper.shared;

  final cloudinary =
      CloudinaryPublic('cloud_name', 'upload_preset', cache: false);
  MsgController msgController = MsgController();

  TypeController typeController = TypeController();
  ScrollController scrollController = ScrollController();
  XFile? xfile;
  ImagePicker imagePicker = ImagePicker();
  int popUp = 0;
  int typing = 0;
  int? online;

  io.Socket? socket;
  var log = Logger();

  int connecteduser = 0;

  List<Message> message = [];
  List<TypingModel> typing1 = [];

  void connect(
    String source,
    BuildContext context,
  ) {
    var token = Provider.of<UserProvider>(context, listen: false).token;
    log.i(token);
    socket = io.io(
        '${baseurl.baseUrl}',
        io.OptionBuilder().setTransports(['websocket'])
            //.disableAutoConnect()
            .setExtraHeaders({'received': token}).build());
    //socket!.connect();
    socket!.on('connect', (data) {
      print(data);
      socket!.emit('chatid', {'id': source});
      setUpSocketListener();
      setUpTypingListener();
      socket!.on('onlineusers', (data) {
        var list = List<String>.from(data['users']);
        getIt<ListHelperState>().setOnlineUsers(list);
        print(getIt<ListHelperState>().onlineusers);
      });
      socket!.on('writinglistener', (data) {
        print(data);
        var list = List<String>.from(data['users']);
        getIt<ListHelperState>().setWritingUsers(list);
      });
    });
  }

  void sendMessage(String source, String destination, String text, String path,
      String type, String name) {
    var messageJson = {
      'text': text,
      "isSender": true,
      'type1': type,
      'time': DateTime.now().toString().substring(10, 16),
      'path': path,
      'videopath': ''
    };
    if (socket!.connected) {
      socket!.emit('sendmessage', {
        'text': text,
        'type1': type,
        'name': name,
        'senderid': source,
        'receiverid': destination,
        'time': DateTime.now().toString().substring(10, 16),
        'path': path,
        'videopath': ''
      });
    }
    msgController.messages1.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket!.on("receivemessage", (data) {
      print(data);
      msgController.typing.value = false;
      var text = data['text'].toString();
      var time = data['time'].toString();
      var path = data['path'].toString();
      var type = data['type1'].toString();
      var videopath = data['videopath'].toString();
      var name = data['name'].toString();

      NotificationApi.showNotification(
          title: name, body: text, payload: 'whatsup');

      var messageJson = {
        'text': text,
        'time': time,
        'path': path,
        'type1': type,
        'isSender': false,
        'videopath': videopath
      };
      msgController.messages1.add(Message.fromJson(messageJson));
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void sendTyping(
    String message,
    String source,
    String destination,
  ) {
    var typer = {'typing': 'typing', 'sender': source, 'receiver': destination};
    msgController.typing.value = true;
    if (socket!.connected) {
      socket!.emit('sendtyping',
          {'typing': 'typing', 'sender': source, 'receiver': destination});
    }

    typeController.typing.add(TypingModel.fromJson(typer));
  }

  void setUpTypingListener() {
    socket!.on('receivetyping', (data) {
      print(data);
      msgController.typing.value = true;
      var typing = data['typing'].toString();
      var source = data['sender'].toString();
      var destination = data['receiver'].toString();

      var typer = {'typing': typing, 'sender': source, 'receiver': destination};
      typeController.typing.add(TypingModel.fromJson(typer));
    });
  }

  void onImageSend(String source, String destination, String path,
      String message, BuildContext context) async {
    log.i('hey $path');
    log.i(message);
    for (int i = 0; i < msgController.popUp.value; i++) {
      Navigator.pop(context);
    }
    msgController.popUp.value = 0;

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(path, resourceType: CloudinaryResourceType.Image),
    );
    log.i(response.secureUrl);
    var messageJson = {
      'text': message,
      "isSender": true,
      'path': response.secureUrl,
      'videopath': '',
      'type1': 'image',
      'time': DateTime.now().toString().substring(10, 16),
    };
    if (socket!.connected) {
      socket!.emit('sendmessage', {
        'text': message,
        'type1': 'image',
        'senderid': source,
        'receiverid': destination,
        'videopath': '',
        'time': DateTime.now().toString().substring(10, 16),
        'path': response.secureUrl
      });
    }
    msgController.messages1.add(Message.fromJson(messageJson));
  }

  void onGalleryVideo(String source, String destination, String path,
      String message, BuildContext context) async {
    log.i('hey $path');
    log.i(message);
    for (int i = 0; i < msgController.popUp.value; i++) {
      Navigator.pop(context);
    }
    msgController.popUp.value = 0;

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(path, resourceType: CloudinaryResourceType.Video),
    );
    log.i(response.secureUrl);

    var messageJson = {
      'text': message,
      'isSender': true,
      'path': '',
      'videopath': response.secureUrl,
      'type1': 'vidGallery',
      'time': DateTime.now().toString().substring(10, 16),
    };
    if (socket!.connected) {
      socket!.emit('sendmessage', {
        'text': message,
        'type1': 'vidGallery',
        'senderid': source,
        'receiverid': destination,
        'time': DateTime.now().toString().substring(10, 16),
        'videopath': response.secureUrl,
        'path': '',
      });
    }
    msgController.messages1.add(Message.fromJson(messageJson));
  }

  void onVideoSend(String source, String destination, String path,
      String message, String imagepath, BuildContext context) async {
    log.i('hey $path');
    log.i(message);
    for (int i = 0; i < msgController.popUp.value; i++) {
      Navigator.pop(context);
    }
    msgController.popUp.value = 0;

    final response = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(path, resourceType: CloudinaryResourceType.Video),
    );
    log.i(response.secureUrl);

    final res = await cloudinary.uploadFile(
      CloudinaryFile.fromFile(imagepath,
          resourceType: CloudinaryResourceType.Image),
    );
    log.i(res.secureUrl);

    var messageJson = {
      'text': message,
      'isSender': true,
      'path': res.secureUrl,
      'videopath': response.secureUrl,
      'type1': 'video',
      'time': DateTime.now().toString().substring(10, 16),
    };
    if (socket!.connected) {
      socket!.emit('sendmessage', {
        'text': message,
        'type1': 'video',
        'senderid': source,
        'receiverid': destination,
        'time': DateTime.now().toString().substring(10, 16),
        'videopath': response.secureUrl,
        'path': res.secureUrl,
      });
    }
    msgController.messages1.add(Message.fromJson(messageJson));
  }
}

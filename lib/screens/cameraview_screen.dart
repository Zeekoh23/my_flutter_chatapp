import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../helpers/socket_helper.dart';
import '../providers/user_provider.dart';
import '../controllers/msg_controller.dart';
import '../providers/chat_provider.dart';
import '../widgets/zoom_image.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class CameraViewScreen extends StatefulWidget {
  CameraViewScreen(
      {Key? key, this.path, this.user, this.destination, this.chat})
      : super(key: key);

  final String? path;
  String? destination;
  Chat? chat;
  UserItem? user;

  static const routename = '/camera';

  @override
  _CameraViewScreenState createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen>
    with SingleTickerProviderStateMixin {
  static TextEditingController _controller = TextEditingController();
  MsgController msgController = MsgController();

  var socket = SocketHelper.shared;

  String get source {
    var number = Provider.of<UserProvider>(context, listen: false).number;
    return number;
  }

  @override
  Widget build(BuildContext context) {
    var chats = Provider.of<ChatProvider>(context, listen: false);
    return Scaffold(
      appBar:
          AppBar(title: const Text('Camera View Screen'), centerTitle: true),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: socket.msgController.isFile.value
                  ? ZoomImage(
                      child: Image.file(File(widget.path!), fit: BoxFit.cover),
                    )
                  : ZoomImage(
                      child: FadeInImage(
                        placeholder:
                            const AssetImage('assets/images/person.png'),
                        image: NetworkImage(widget.path!),
                      ),
                    )),
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: socket.msgController.isFile.value
                  ? TextFormField(
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      maxLines: 6,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Add a text...',
                        prefixIcon: const Icon(Icons.add_photo_alternate,
                            color: Colors.white, size: 27),
                        hintStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                        suffixIcon: InkWell(
                          onTap: () {
                            socket.scrollController.animateTo(
                                socket
                                    .scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut);

                            socket.onImageSend(source, widget.destination!,
                                widget.path!, _controller.text.trim(), context);
                            _controller.clear();
                            if (_controller.text == '') {
                              chats.updateChat(widget.chat!, 'image',
                                  DateTime.now().toString().substring(10, 16));

                              _controller.clear();
                            }
                            if (_controller.text == null) {
                              chats.createChat(
                                widget.user!,
                                'image',
                                DateTime.now().toString().substring(10, 16),
                              );
                              _controller.clear();
                            }
                            chats.createChat(
                              widget.user!,
                              _controller.text,
                              DateTime.now().toString().substring(10, 16),
                            );
                            chats.updateChat(widget.chat!, _controller.text,
                                DateTime.now().toString().substring(10, 16));
                            _controller.clear();
                          },
                          child: const CircleAvatar(
                            radius: 27,
                            backgroundColor: kPrimaryColor,
                            child: Icon(Icons.check,
                                color: Colors.white, size: 27),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ),
          ),
        ]),
      ),
    );
  }
}

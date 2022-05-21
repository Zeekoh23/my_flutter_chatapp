import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../constants.dart';
import '../helpers/socket_helper.dart';
import '../providers/user_provider.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import '../models/user_model.dart';

class VideoViewScreen extends StatefulWidget {
  VideoViewScreen(
      {Key? key,
      this.videoPath,
      this.user,
      this.destination,
      this.path,
      this.chat})
      : super(key: key);

  final String? videoPath;
  final String? destination;
  final String? path;
  Chat? chat;
  UserItem? user;

  @override
  _VideoViewScreenState createState() => _VideoViewScreenState();
}

class _VideoViewScreenState extends State<VideoViewScreen> {
  VideoPlayerController? _controller;
  var socket = SocketHelper.shared;
  TextEditingController _textcontroller = TextEditingController();

  String get source {
    var number = Provider.of<UserProvider>(context, listen: false).number;
    return number;
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.videoPath!)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    var chats = Provider.of<ChatProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video View'),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Container(),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: socket.msgController.isFile.value
                    ? TextFormField(
                        controller: _textcontroller,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17),
                        minLines: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Write a text',
                          prefixIcon: const Icon(
                            Icons.add_photo_alternate,
                            color: Colors.white,
                            size: 27,
                          ),
                          suffixIcon: CircleAvatar(
                            radius: 27,
                            backgroundColor: kPrimaryColor,
                            child: IconButton(
                              onPressed: () {
                                socket.scrollController.animateTo(
                                    socket.scrollController.position
                                        .maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut);

                                socket.msgController.isVideoGallery.value
                                    ? socket.onGalleryVideo(
                                        source,
                                        widget.destination!,
                                        widget.videoPath!,
                                        _textcontroller.text.trim(),
                                        context)
                                    : socket.onVideoSend(
                                        source,
                                        widget.destination!,
                                        widget.videoPath!,
                                        _textcontroller.text.trim(),
                                        widget.path!,
                                        context);

                                if (_textcontroller.text == '') {
                                  chats.updateChat(
                                      widget.chat!,
                                      'video',
                                      DateTime.now()
                                          .toString()
                                          .substring(10, 16));

                                  _textcontroller.clear();
                                }
                                if (_textcontroller.text == null) {
                                  chats.createChat(
                                    widget.user!,
                                    'video',
                                    DateTime.now().toString().substring(10, 16),
                                  );
                                  _textcontroller.clear();
                                }
                                chats.createChat(
                                  widget.user!,
                                  _textcontroller.text,
                                  DateTime.now().toString().substring(10, 16),
                                );
                                chats.updateChat(
                                    widget.chat!,
                                    _textcontroller.text,
                                    DateTime.now()
                                        .toString()
                                        .substring(10, 16));
                                _textcontroller.clear();
                              },
                              icon: const Icon(Icons.check,
                                  color: Colors.white, size: 27),
                            ),
                            //
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                        ),
                      )
                    : Container(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: CircleAvatar(
                  radius: 33,
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../constants.dart';
import '../models/user_model.dart';

import '../screens/cameraview_screen.dart';
import '../helpers/socket_helper.dart';
import '../screens/camera_screen.dart';
import '../screens/videoview_screen.dart';

import 'message_list.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart';

class UserIndividualCard extends StatefulWidget {
  UserIndividualCard({
    this.user,
    Key? key,
  }) : super(key: key);
  UserItem? user;

  @override
  _UserIndividualCardState createState() => _UserIndividualCardState();
}

class _UserIndividualCardState extends State<UserIndividualCard> {
  TextEditingController _textcontroller = TextEditingController();
  FocusNode focus = FocusNode();
  bool show = false;
  bool sendbutton = false;
  int typing = 0;
  var log = Logger();
  final cloudinary =
      CloudinaryPublic('isaac-eze', 'ml_default_23', cache: false);

  var socket = SocketHelper.shared;

  String get source {
    var number = Provider.of<UserProvider>(context, listen: false).number;
    return number;
  }

  String get sourcename {
    var name = Provider.of<UserProvider>(context, listen: false).name;
    return name;
  }

  @override
  void initState() {
    super.initState();
    //socket.connect(source, context);

    focus.addListener(() {
      if (focus.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final chats = Provider.of<ChatProvider>(context, listen: false);

    return WillPopScope(
        child: Column(children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
              ),
              child: Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  controller: socket.scrollController,
                  itemCount: socket.msgController.messages1.length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == socket.msgController.messages1.length) {
                      return Container(
                        height: 80,
                      );
                    }

                    return MessageList(
                      image: widget.user!.image,
                      messages: socket.msgController.messages1[i],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 32,
                  color: const Color(0xFF087949).withOpacity(0.08),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: orientation == Orientation.portrait
                    ? size.height - 507
                    : size.height,
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.sentiment_satisfied_alt_outlined,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color!
                                    .withOpacity(0.64),
                              ),
                              onPressed: () {
                                setState(() {
                                  show = !show;
                                });
                                focus.unfocus();
                                focus.canRequestFocus = true;
                              },
                            ),
                            const SizedBox(width: kDefaultPadding / 4),
                            Expanded(
                              child: TextFormField(
                                controller: _textcontroller,
                                focusNode: focus,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 1,
                                onChanged: (value) {
                                  if (value.length > 0) {
                                    setState(() {
                                      sendbutton = true;
                                    });

                                    socket.sendTyping(_textcontroller.text,
                                        source, widget.user!.number!);
                                  } else {
                                    setState(() {
                                      sendbutton = false;
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Type a message',
                                    border: InputBorder.none),
                              ),
                            ),
                            IconButton(
                                icon: Icon(
                                  sendbutton ? Icons.send : Icons.mic,
                                  color: kPrimaryColor,
                                ),
                                onPressed: () {
                                  if (sendbutton) {
                                    socket.scrollController.animateTo(
                                        socket.scrollController.position
                                            .maxScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOut);

                                    socket.sendMessage(
                                        source,
                                        widget.user!.number!,
                                        _textcontroller.text.trim(),
                                        '',
                                        'text',
                                        sourcename);
                                    chats.createChat(
                                      widget.user!,
                                      _textcontroller.text,
                                      DateTime.now()
                                          .toString()
                                          .substring(10, 16),
                                    );

                                    _textcontroller.clear();
                                    setState(() {
                                      sendbutton = false;
                                    });
                                  }
                                }),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.attach_file,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withOpacity(0.64),
                        ),
                        onPressed: () async {
                          socket.msgController.isFile.value = true;
                          socket.msgController.popUp.value = 1;

                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();
                          String? extMime =
                              lookupMimeType(result!.files.single.path!);
                          log.i(extMime);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => CameraViewScreen(
                                      path: result.files.single.path,
                                      destination: widget.user!.number,
                                      user: widget.user)));

                          if (extMime == 'video/mp4') {
                            socket.msgController.isVideoGallery.value = true;
                            socket.msgController.popUp.value = 2;

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => VideoViewScreen(
                                          videoPath: result.files.single.path,
                                          destination: widget.user!.number,
                                          user: widget.user,
                                        )));
                          }
                        }),
                    const SizedBox(
                      width: kDefaultPadding / 4,
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withOpacity(0.64),
                        ),
                        onPressed: () {
                          socket.msgController.popUp.value = 2;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => CameraScreen(
                                      destination: widget.user!.number,
                                      user: widget.user)));
                        }),
                  ],
                ),
              ),
            ),
          ),
          show ? emojiSelect() : Container(),
        ]),
        onWillPop: () {
          if (show) {
            setState(() {
              show = false;
            });
          } else {
            Navigator.pop(context);
          }
          return Future.value(false);
        });
  }

  Widget emojiSelect() {
    return SizedBox(
        height: 247,
        child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              print(emoji);
              setState(() {
                _textcontroller.text = _textcontroller.text + emoji.emoji;
              });
              sendbutton ? Icons.send : Icons.mic;
            },
            onBackspacePressed: () {
              _textcontroller.text = _textcontroller.text;
            },
            config: const Config(
                columns: 7,
                emojiSizeMax: 25.0,
                verticalSpacing: 0,
                horizontalSpacing: 0,
                initCategory: Category.RECENT,
                bgColor: Color(0xFFF2F2F2),
                indicatorColor: Color(0xFF075E54),
                iconColor: Colors.grey,
                iconColorSelected: Color(0xFF075E54),
                progressIndicatorColor: Color(0xFF075E54),
                backspaceColor: Color(0xFF075E54),
                skinToneDialogBgColor: Colors.white,
                skinToneIndicatorColor: Colors.grey,
                enableSkinTones: true,
                showRecentsTab: true,
                recentsLimit: 6,
                //noRecentsText: "No Recents",
                // noRecentsStyle: TextStyle(fontSize: 20, color: Colors.black26),
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL)));
  }
}

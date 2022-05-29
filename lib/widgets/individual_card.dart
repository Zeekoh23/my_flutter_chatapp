import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../constants.dart';
import '../screens/individual_screen.dart';
import '../widgets/notification_api.dart';
import '../helpers/socket_helper.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../screens/camera_screen.dart';
import '../screens/cameraview_screen.dart';
import '../screens/videoview_screen.dart';

import 'message_list.dart';
import '../models/chat_model.dart';
import '../providers/message_provider.dart';

class IndividualCard extends StatefulWidget {
  IndividualCard({Key? key, this.chat, this.image}) : super(key: key);
  Chat? chat;
  String? image;

  static final individual = IndividualCard();

  @override
  IndividualCardState createState() => IndividualCardState();
}

class IndividualCardState extends State<IndividualCard> {
  static final inCardState = IndividualCardState();
  TextEditingController _textcontroller = TextEditingController();
  FocusNode focus = FocusNode();
  bool show = false;
  bool sendbutton = false;
  var log = Logger();

  var socket = SocketHelper.shared;

  String get source {
    var number = Provider.of<UserProvider>(context, listen: false).number;
    return number;
  }

  String get sourcename {
    var name = Provider.of<UserProvider>(context, listen: false).name;
    return name;
  }

  Future<void> _fetchMessages(BuildContext context1) async {
    await Provider.of<MessageProvider>(context1, listen: false)
        .fetchMessages(source, widget.chat!.number!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchMessages(context);
  }

  /*@override
  void dispose() async {
    super.dispose();
    await Provider.of<MessageProvider>(context).demeChatMessages;
  }*/

  @override
  void initState() {
    super.initState();

    NotificationApi.init();

    listenNotifications();

    //Timer.run(() => _fetchMessages(context));

    //Future.delayed(Duration.zero, () => _fetchMessages());

    /*WidgetsBinding.instance
        .addPostFrameCallback((_) => _fetchMessages(context));*/

    focus.addListener(() {
      if (focus.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
  }

  void listenNotifications() =>
      NotificationApi.onNotification.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => IndividualScreen(
              chat: widget.chat, image: widget.image!, payload: payload)));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final chats = Provider.of<ChatProvider>(context, listen: false);

    return WillPopScope(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
                child: Consumer<MessageProvider>(
                  builder: (ctx, message, _) => Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      controller: message.socket.scrollController,
                      itemCount:
                          message.socket.msgController.messages1.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i ==
                            message.socket.msgController.messages1.length) {
                          return Container(height: 85);
                        }

                        return MessageList(
                          image: widget.chat!.image,
                          messages: message.socket.msgController.messages1[i],
                        );
                      },
                    ),
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
                                        source, widget.chat!.number!);
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
                                        widget.chat!.number!,
                                        _textcontroller.text.trim(),
                                        '',
                                        'text',
                                        sourcename);

                                    chats.updateChat(
                                        widget.chat!,
                                        _textcontroller.text,
                                        DateTime.now()
                                            .toString()
                                            .substring(10, 16));

                                    _textcontroller.clear();
                                    setState(() {
                                      sendbutton = false;
                                    });
                                  }
                                }),
                            //),

                            const SizedBox(
                              width: 2,
                            ),
                            const SizedBox(width: 0.05),
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
                          //if there is a file return true
                          socket.msgController.isFile.value = true;
                          //after submiting it returns back to individual screen once
                          socket.msgController.popUp.value = 1;

                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();
                          //checks for file path extension like jpg, video
                          String? extMime =
                              lookupMimeType(result!.files.single.path!);
                          log.i(extMime);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => CameraViewScreen(
                                      path: result.files.single.path,
                                      destination: widget.chat!.number,
                                      chat: widget.chat)));

                          if (extMime == 'video/mp4') {
                            socket.msgController.isVideoGallery.value = true;
                            //after submiting it returns back to individual screen twice
                            socket.msgController.popUp.value = 2;

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => VideoViewScreen(
                                        videoPath: result.files.single.path,
                                        destination: widget.chat!.number,
                                        chat: widget.chat)));
                          }
                        }),
                    const SizedBox(
                      width: 0.005,
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
                                    destination: widget.chat!.number,
                                    chat: widget.chat)));
                      },
                    ),
                  ],
                ),
              ),
            ),
            show ? emojiSelect() : Container(),
          ],
        ),
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

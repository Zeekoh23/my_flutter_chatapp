import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:video_player/video_player.dart';

import '../models/message_model.dart';

import '../screens/cameraview_screen.dart';
import '../screens/videoview_screen.dart';
import '../helpers/socket_helper.dart';
import '../constants.dart';

class MessageList extends StatefulWidget {
  MessageList({Key? key, this.image, this.messages}) : super(key: key);
  String? image;
  Message? messages;

  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  VideoPlayerController? _videocontroller;
  var socket = SocketHelper.shared;

  @override
  Widget build(BuildContext context) {
    Widget messageConstraint(Message message) {
      if (message.type1 == 'image') {
        return imageMessages(context);
      } else if (message.type1 == 'text') {
        return textmessage(context);
      } else if (message.type1 == 'video') {
        return videoMessages(context);
      } else if (message.type1 == 'vidGallery') {
        return videoGallery(context);
      } else if (message.type1 == 'audio') {
        return audioMessage(context);
      } else {
        return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: Row(
        mainAxisAlignment: widget.messages!.isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.messages!.isSender) ...[
            CircleAvatar(
              radius: 12,
              child: FadeInImage(
                placeholder: const AssetImage('assets/images/person.png'),
                image: NetworkImage(widget.image!),
              ),
            ),
            const SizedBox(width: kDefaultPadding / 2),
          ],
          messageConstraint(widget.messages!),
          if (widget.messages!.isSender)
            messageStatusDot(context, MessageStatus.viewed)
        ],
      ),
    );
  }

  Widget textmessage(BuildContext context) {
    return Align(
      alignment: widget.messages!.isSender
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding * 0.005,
            vertical: kDefaultPadding / 400),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 110,
          ),
          child: Card(
            elevation: 0.3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: kPrimaryColor.withOpacity(
              widget.messages!.isSender ? 0.3 : 0.1,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 45, top: 6, bottom: 21),
                  child: Text(
                    widget.messages!.text!,
                    style: TextStyle(
                        fontSize: 20,
                        color: widget.messages!.isSender
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyText1!.color),
                  ),
                ),
                Positioned(
                    bottom: 5,
                    right: 8,
                    child: Text(widget.messages!.time,
                        style: TextStyle(
                            fontSize: 14,
                            color: widget.messages!.isSender
                                ? Colors.white
                                : Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .color))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget audioMessage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.55,
      padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding * 0.75, vertical: kDefaultPadding / 2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: kPrimaryColor.withOpacity(widget.messages!.isSender ? 0.4 : 0.1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.play_arrow,
            color: widget.messages!.isSender ? Colors.white : kPrimaryColor,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding / 2,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: widget.messages!.isSender
                        ? Colors.white
                        : kPrimaryColor,
                  ),
                  Positioned(
                    left: 0,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: widget.messages!.isSender
                            ? Colors.white
                            : kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '0.37',
            style: TextStyle(
                fontSize: 12,
                color: widget.messages!.isSender ? Colors.white : null),
          ),
        ],
      ),
    );
  }

  Widget videoMessages(BuildContext context) {
    final cloudinaryImage = CloudinaryImage(widget.messages!.path);
    final String imagePath =
        cloudinaryImage.transform().width(610).height(400).generate();

    return Align(
      alignment: widget.messages!.isSender
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding * 0.005,
              vertical: kDefaultPadding / 100),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: kPrimaryColor
                  .withOpacity(widget.messages!.isSender ? 0.3 : 0.1),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 87,
              ),
              child: Card(
                margin: const EdgeInsets.all(3),
                color: kPrimaryColor.withOpacity(
                  widget.messages!.isSender ? 0.2 : 0.1,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    InkWell(
                        onTap: () {
                          socket.msgController.isFile.value = false;

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => VideoViewScreen(
                                      videoPath: widget.messages!.videopath)));
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.27,
                                child: FadeInImage(
                                  placeholder: const AssetImage(
                                      'assets/images/person.png'),
                                  image: NetworkImage(imagePath),
                                ),
                                decoration: BoxDecoration(
                                  color: widget.messages!.isSender
                                      ? kPrimaryColor.withOpacity(0.2)
                                      : Colors.white,
                                )),
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                size: 26,
                              ),
                            ),
                          ],
                        )),
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 11, top: 3, left: 6, right: 10),
                            child: Text(
                              widget.messages!.text!,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: widget.messages!.isSender
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0.05,
                          right: 5,
                          child: Text(
                            widget.messages!.time,
                            style: TextStyle(
                                fontSize: 14,
                                color: widget.messages!.isSender
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget videoGallery(BuildContext context) {
    return Align(
      alignment: widget.messages!.isSender
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding * 0.005,
              vertical: kDefaultPadding / 100),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: kPrimaryColor
                  .withOpacity(widget.messages!.isSender ? 0.3 : 0.1),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 87,
              ),
              child: Card(
                margin: const EdgeInsets.all(3),
                color: kPrimaryColor.withOpacity(
                  widget.messages!.isSender ? 0.2 : 0.1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(children: [
                  InkWell(
                      onTap: () {
                        socket.msgController.isFile.value = false;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => VideoViewScreen(
                                    videoPath: widget.messages!.videopath)));
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.27,
                            child: Image.asset('assets/images/gallery1.jpg'),
                            decoration: BoxDecoration(
                              color: widget.messages!.isSender
                                  ? kPrimaryColor.withOpacity(0.2)
                                  : Colors.white,
                            ),
                          ),
                          Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 26,
                            ),
                          ),
                        ],
                      )),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: 11, top: 3, left: 6, right: 10),
                          child: Text(
                            widget.messages!.text!,
                            style: TextStyle(
                                fontSize: 18,
                                color: widget.messages!.isSender
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0.05,
                        right: 5,
                        child: Text(
                          widget.messages!.time,
                          style: TextStyle(
                              fontSize: 14,
                              color: widget.messages!.isSender
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyText1!
                                      .color),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          )),
    );
  }

  Widget imageMessages(BuildContext context) {
    final cloudinaryImage = CloudinaryImage(widget.messages!.path);
    final String imagepath =
        cloudinaryImage.transform().width(610).height(400).generate();
    return Align(
        alignment: widget.messages!.isSender
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding * 0.005,
                vertical: kDefaultPadding / 100),
            child: Container(
                width: MediaQuery.of(context).size.width * 0.68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: kPrimaryColor
                      .withOpacity(widget.messages!.isSender ? 0.3 : 0.1),
                ),
                child: Card(
                  margin: const EdgeInsets.all(3),
                  color: kPrimaryColor
                      .withOpacity(widget.messages!.isSender ? 0.2 : 0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      GestureDetector(
                          onTap: () {
                            socket.msgController.isFile.value = false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) =>
                                        CameraViewScreen(path: imagepath)));
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.27,
                            child: FadeInImage(
                              placeholder:
                                  const AssetImage('assets/images/person.png'),
                              image: NetworkImage(imagepath),
                            ),
                            decoration: BoxDecoration(
                              color: widget.messages!.isSender
                                  ? kPrimaryColor.withOpacity(0.2)
                                  : Colors.white,
                            ),
                          )),
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 11, top: 3, left: 6, right: 10),
                              child: Text(
                                widget.messages!.text!,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: widget.messages!.isSender
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0.05,
                            right: 5,
                            child: Text(
                              widget.messages!.time,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: widget.messages!.isSender
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))));
  }

  Widget messageStatusDot(BuildContext context, MessageStatus status) {
    Color dotColor(MessageStatus status1) {
      switch (status) {
        case MessageStatus.not_sent:
          return kErrorColor;
        case MessageStatus.not_view:
          return Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.1);
        case MessageStatus.viewed:
          return kPrimaryColor.withOpacity(0.2);
        default:
          return Colors.transparent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(
        left: kDefaultPadding / 2,
      ),
      height: 18,
      width: 18,
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == MessageStatus.not_sent ? Icons.close : Icons.done,
        size: 15,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}

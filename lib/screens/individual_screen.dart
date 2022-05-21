import 'package:flutter/material.dart';

import '../helpers/socket_helper.dart';

import '../widgets/individual_card.dart';
import '../models/chat_model.dart';
import '../widgets/individualscreen_appbar.dart';

class IndividualScreen extends StatefulWidget {
  IndividualScreen({Key? key, this.chat, this.payload, this.image})
      : super(key: key);
  Chat? chat;
  String? image;
  String? payload;

  @override
  _IndividualScreenState createState() => _IndividualScreenState();
}

class _IndividualScreenState extends State<IndividualScreen> {
  var socket = SocketHelper.shared;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Prefer(
          context: context,
          name: widget.chat!.name!,
          about: widget.chat!.about!,
          image: widget.image!,
          number: widget.chat!.number!),
      body: IndividualCard(chat: widget.chat, image: widget.image),
    );
  }
}

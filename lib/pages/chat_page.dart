import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/body_chat.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: BodyChat(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: kPrimaryColor,
      automaticallyImplyLeading: false,
      title: const Text('Chats'),
      actions: [
        IconButton(
            icon: const Icon(
              Icons.search,
            ),
            onPressed: () {}),
      ],
    );
  }
}

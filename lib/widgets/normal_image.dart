import 'package:flutter/material.dart';

import '../screens/profilepicview_screen.dart';
import '../helpers/socket_helper.dart';
import '../constants.dart';

class NormalImage extends StatelessWidget {
  NormalImage({Key? key, required this.path}) : super(key: key);
  String path;

  var socket = SocketHelper.shared;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        socket.msgController.profilePage.value = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => ProfileViewPicScreen(path: path)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CircleAvatar(
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/person.png'),
              image: NetworkImage(path),
              fit: BoxFit.cover,
            ),
            radius: kDefaultPadding * 3.3),
      ),
    );
  }
}

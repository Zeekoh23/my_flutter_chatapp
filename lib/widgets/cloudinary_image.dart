import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../screens/profilepicview_screen.dart';
import '../helpers/socket_helper.dart';
import '../constants.dart';

class CloudinaryImage1 extends StatelessWidget {
  CloudinaryImage1({Key? key, required this.image}) : super(key: key);
  //String path;
  String image;

  var socket = SocketHelper.shared;

  @override
  Widget build(BuildContext context) {
    var cloudinaryImage = CloudinaryImage(image);

    final String imagePath =
        cloudinaryImage.transform().width(610).height(600).generate();
    return InkWell(
      onTap: () {
        socket.msgController.profilePage.value = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => ProfileViewPicScreen(path: imagePath)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CircleAvatar(
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/person.png'),
              image: NetworkImage(imagePath),
              fit: BoxFit.cover,
            ),
            radius: kDefaultPadding * 3.3),
      ),
    );
  }
}

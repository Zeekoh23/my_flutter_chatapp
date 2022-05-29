import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../constants.dart';
import '../providers/chat_provider.dart';
import '../helpers/socket_helper.dart';
import '../providers/user_provider.dart';

class ProfileViewPicScreen extends StatefulWidget {
  ProfileViewPicScreen({Key? key, this.path}) : super(key: key);
  final String? path;

  @override
  _ProfileViewPicScreenState createState() => _ProfileViewPicScreenState();
}

class _ProfileViewPicScreenState extends State<ProfileViewPicScreen> {
  var socket = SocketHelper.shared;
  final cloudinary = CloudinaryPublic(
    'zeekoh',
    'ml_default',
    cache: false,
  );

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false);
    var chats = Provider.of<ChatProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Picture'), centerTitle: true),
      body: Hero(
        tag: 'profile',
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: socket.msgController.profilePage.value
                  ? Image.file(File(widget.path!), fit: BoxFit.cover)
                  : FadeInImage(
                      placeholder: const AssetImage('assets/images/person.png'),
                      image: NetworkImage(widget.path!),
                    ),
            ),
            socket.msgController.profilePage.value
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.only(right: 10, bottom: 10),
                      child: InkWell(
                        onTap: () async {
                          final response = await cloudinary.uploadFile(
                            CloudinaryFile.fromFile(widget.path!,
                                resourceType: CloudinaryResourceType.Image),
                          );

                          user.updateProfilePic(response.secureUrl, context);
                          chats.updateChatImage(response.secureUrl);
                        },
                        child: const CircleAvatar(
                          radius: 27,
                          backgroundColor: kPrimaryColor,
                          child:
                              Icon(Icons.check, color: Colors.white, size: 27),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

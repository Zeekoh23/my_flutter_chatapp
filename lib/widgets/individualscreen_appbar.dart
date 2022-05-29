import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../screens/userprofile_screen.dart';
import '../screens/audiocall_screen.dart';
import '../screens/videocall_screen.dart';
import '../constants.dart';

import '../helpers/list_helper.dart';
import '../helpers/get_it1.dart';

//@override
PreferredSize Prefer(
    {required BuildContext context,
    required String name,
    required String image,
    required String number,
    required String about}) {
  final listhelper = getIt<ListHelperState>();
  return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: AppBar(
        automaticallyImplyLeading: false,
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => UserProfileScreen(
                      name: name, image: image, about: about, number: number)),
            );
          },
          child: Row(children: [
            const BackButton(),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CircleAvatar(
                child: FadeInImage(
                  placeholder: const AssetImage('assets/images/person.png'),
                  image: NetworkImage(image),
                ),
              ),
            ),
            const SizedBox(
              width: kDefaultPadding * 0.75,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 3,
                ),
                /*socket.msgController.typing.value
                      ? Text('typing', style: TextStyle(fontSize: 12))
                      : */
                Observer(
                  builder: (context) => Text(
                    listhelper.onlineusers.contains(number)
                        ? 'online'
                        : 'Last seen ${DateTime.now().toString().substring(10, 16)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            )
          ]),
        ),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.local_phone,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) =>
                            AudioCallScreen(name: name, image: image)));
              }),
          IconButton(
              icon: const Icon(
                Icons.videocam,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => VideoCallScreen(name: name),
                    ));
              }),
          const SizedBox(width: kDefaultPadding / 2),
        ],
      ));
}

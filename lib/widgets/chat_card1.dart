import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../models/user_model.dart';

import '../constants.dart';

import '../screens/user_individual_screen.dart';

class ChatCard1 extends StatefulWidget {
  ChatCard1({
    Key? key,
  }) : super(key: key);

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard1> {
  @override
  Widget build(BuildContext context) {
    final users = Provider.of<UserItem>(context, listen: false);

    var result = users.image!.substring(0, 22);
    if (result == 'https://res.cloudinary') {
      var cloudinaryImage = CloudinaryImage(users.image!);
      final String imagePath =
          cloudinaryImage.transform().width(300).height(300).generate();
      return pictureType(users, imagePath);
    } else {
      return pictureType(users, users.image!);
    }
  }

  Widget pictureType(UserItem users, String path) {
    return Column(children: [
      InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserIndividualScreen(user: users, image: path)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kDefaultPadding,
              vertical: kDefaultPadding * 0.75,
            ),
            child: Row(children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CircleAvatar(
                      radius: 24,
                      child: FadeInImage(
                          placeholder:
                              const AssetImage('assets/images/person.png'),
                          image: NetworkImage(path),
                          fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        users.name!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Opacity(
                        opacity: 0.64,
                        child: Text(
                          users.about!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ))
    ]);
  }
}

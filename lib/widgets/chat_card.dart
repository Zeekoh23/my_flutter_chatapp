import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../models/chat_model.dart';
import '../constants.dart';
import '../screens/individual_screen.dart';

import '../providers/chat_provider.dart';

class ChatCard extends StatefulWidget {
  ChatCard({
    Key? key,
  }) : super(key: key);

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<Chat>(context, listen: false);
    var cloudinaryImage = CloudinaryImage(chat.image!);
    final chatprovider = Provider.of<ChatProvider>(context, listen: false);
    final String imagePath =
        cloudinaryImage.transform().width(300).height(300).generate();

    var result = chat.image!.substring(0, 22);

    if (result == 'https://res.cloudinary') {
      return pictureType(
          chat: chat, chatprovider: chatprovider, path: imagePath);
    }
    return pictureType(
        chat: chat, chatprovider: chatprovider, path: chat.image!);
  }

  Widget pictureType({
    required Chat chat,
    required ChatProvider chatprovider,
    required String path,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    IndividualScreen(chat: chat, image: path)));

        chatprovider.updateChatQuantity(chat);
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
                      placeholder: const AssetImage('assets/images/person.png'),
                      image: NetworkImage(path)),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name!,
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
                      chat.lastMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (chat.quantity == 0)
            const SizedBox()
          else
            Opacity(
              opacity: 0.64,
              child: Text(
                chat.quantity.toString(),
                style: const TextStyle(color: kSecondaryColor, fontSize: 19),
              ),
            ),
          const SizedBox(width: 4),
          Opacity(
            opacity: 0.64,
            child: Text(chat.time!),
          ),
        ]),
      ),
    );
  }
}

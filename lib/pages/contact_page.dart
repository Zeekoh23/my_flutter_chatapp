import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/contact_card.dart';

class ContactPage extends StatelessWidget {
  ContactPage({
    Key? key,
  }) : super(key: key);
  static const routename = "/contacts";

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: buildAppBar(), body: ContactCard());
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: kPrimaryColor,
      //automaticallyImplyLeading: false,
      title: const Text('Contacts'),
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

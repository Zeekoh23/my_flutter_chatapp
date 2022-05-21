import 'package:flutter/material.dart';

import '../helpers/list_helper.dart';
import '../helpers/get_it1.dart';

import '../models/user_model.dart';

import '../widgets/individualscreen_appbar.dart';
import '../widgets/user_individual_card.dart';

class UserIndividualScreen extends StatefulWidget {
  UserIndividualScreen({
    Key? key,
    this.user,
    this.image,
  });
  UserItem? user;
  String? image;
  @override
  _UserIndividualScreenState createState() => _UserIndividualScreenState();
}

class _UserIndividualScreenState extends State<UserIndividualScreen> {
  final listhelper = getIt<ListHelperState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Prefer(
          context: context,
          name: widget.user!.name!,
          about: widget.user!.about!,
          image: widget.image!,
          number: widget.user!.number!),
      body: UserIndividualCard(
        user: widget.user,
      ),
    );
  }
}

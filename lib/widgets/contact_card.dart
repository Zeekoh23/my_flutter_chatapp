import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import './chat_body.dart';
import './chat_card1.dart';
import './card_skelton.dart';

class ContactCard extends StatefulWidget {
  ContactCard({
    Key? key,
  }) : super(key: key);

  @override
  _ContactCardState createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  var _isInit = true;
  late bool _isLoading;
  Future<void> _fetchUsers() async {
    await Provider.of<UserProvider>(context, listen: false).fetchUsers();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<UserProvider>(context).fetchUsers().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final users1 = Provider.of<UserProvider>(context).items;
    return ChatBody(
        isEmpty1: users1,
        refresh: () => _fetchUsers(),
        itemBuilder: (_, i) {
          return ChangeNotifierProvider.value(
            value: users1[i],
            child: ChatCard1(),
          );
        },
        isLoading: _isLoading,
        length: users1.length);
  }
}

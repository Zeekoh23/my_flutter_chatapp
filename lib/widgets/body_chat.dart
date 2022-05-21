import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './card_skelton.dart';
import '../providers/chat_provider.dart';
import './chat_card.dart';
import './chat_body.dart';

class BodyChat extends StatefulWidget {
  BodyChat({Key? key}) : super(key: key);

  @override
  _BodyChatState createState() => _BodyChatState();
}

class _BodyChatState extends State<BodyChat> {
  var _isInit = true;

  late bool _isLoading;

  Future<void> _fetchChats() async {
    await Provider.of<ChatProvider>(context, listen: false).fetchChats();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ChatProvider>(context).fetchChats().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final chats = Provider.of<ChatProvider>(context).items;
    return ChatBody(
        refresh: () => _fetchChats(),
        itemBuilder: (context, i) => ChangeNotifierProvider.value(
              value: chats[i],
              child: ChatCard(),
            ),
        isLoading: _isLoading,
        length: chats.length);
  }
}

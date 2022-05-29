import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../constants.dart';
import '../pages/chat_page.dart';
import '../helpers/socket_helper.dart';
import '../pages/contact_page.dart';
import '../models/push_notification.dart';
import '../pages/profile_page.dart';
import '../providers/user_provider.dart';
import '../widgets/notification_badge.dart';

class HomeScreen extends StatefulWidget {
  static const routename = '/chats';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  late List<Widget> listScreens;

  String get image {
    var image = Provider.of<UserProvider>(context, listen: false).image;
    return image;
  }

  var socket = SocketHelper.shared;

  late final FirebaseMessaging _messaging;
  late int _totalNotificationCounter;
  PushNotification? _notificationInfo;

  //register notification
  void registerNotification() async {
    _messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _messaging.requestPermission(
        alert: true, badge: true, provisional: true, sound: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted the permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
            title: message.notification!.title,
            body: message.notification!.body,
            dataTitle: message.data['title'],
            dataBody: message.data['body']);
        setState(() {
          _totalNotificationCounter++;
          _notificationInfo = notification;
        });

        showSimpleNotification(
          Text(_notificationInfo!.title!),
          leading: NotificationBadge(
            totalNotification: _totalNotificationCounter,
          ),
          subtitle: Text(_notificationInfo!.body!),
          background: kPrimaryColor,
          duration: const Duration(seconds: 10),
        );
      });
    } else {
      print('Permission declined by user');
    }
  }

  //check the initial message that we receive
  checkForInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification!.title,
        body: initialMessage.notification!.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    }
  }

  String get source {
    var number = Provider.of<UserProvider>(context, listen: false).number;
    return number;
  }

  @override
  void initState() {
    super.initState();

    socket.connect(source, context);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      print(msg);
      PushNotification notification = PushNotification(
          title: msg.notification!.title,
          body: msg.notification!.body,
          dataTitle: msg.data['title'],
          dataBody: msg.data['body']);
      setState(() {
        _totalNotificationCounter++;
        _notificationInfo = notification;
      });
    });

    //normal notification
    registerNotification();

    //when app is in terminated state
    checkForInitialMessage();

    _totalNotificationCounter = 0;

    listScreens = [
      ContactPage(),
      ChatPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listScreens[_selectedIndex],
      bottomNavigationBar: bottomNavigation(),
    );
  }

  BottomNavigationBar bottomNavigation() {
    var result = image.substring(0, 22);

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (value) {
        setState(() {
          _selectedIndex = value;
        });
      },
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
            ),
            label: 'Users'),
        const BottomNavigationBarItem(
            icon: Icon(Icons.messenger), label: 'Chats'),
        if (result == 'https://res.cloudinary')
          cloudinaryPicture()
        else
          profilePicture()
      ],
    );
  }

  BottomNavigationBarItem cloudinaryPicture() {
    var cloudinaryImage = CloudinaryImage(image);
    final String imagePath =
        cloudinaryImage.transform().width(200).height(200).generate();
    return BottomNavigationBarItem(
      icon: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CircleAvatar(
            radius: 14,
            child: FadeInImage(
                placeholder: const AssetImage('assets/images/person.png'),
                image: NetworkImage(imagePath))),
      ),
      label: 'Profile',
    );
  }

  BottomNavigationBarItem profilePicture() {
    return BottomNavigationBarItem(
      icon: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CircleAvatar(
            radius: 14,
            child: FadeInImage(
                placeholder: const AssetImage('assets/images/person.png'),
                image: NetworkImage(image))),
      ),
      label: 'Profile',
    );
  }

  PreferredSize buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text('Chats'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: IconButton(
                icon: const Icon(
                  Icons.search,
                ),
                onPressed: () {}),
          ),
        ],
      ),
    );
  }
}

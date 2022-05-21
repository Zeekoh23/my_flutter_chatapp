import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';

import './newscreens/welcome_screens.dart';
import './screens/camera_screen.dart';
import './theme.dart';
import './screens/splash_screen.dart';
import './helpers/get_it1.dart';
import './newscreens/signup_screen.dart';
import './providers/agora_provider.dart';
import './newscreens/login_screen.dart';
import './newscreens/home_screen.dart';
import './providers/chat_provider.dart';
import './models/chat_model.dart';
import './pages/profile_page.dart';
import './screens/editprofile_screen.dart';

import './providers/user_provider.dart';
import './providers/message_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cam = await availableCameras();

  XuGetIt.setup();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  String name = '';
  String userid = '';
  String email = '';
  String number = '';
  String image = '';
  String about = '';
  List<Chat> chat = [];
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (c) => UserProvider(),
              ),
              ChangeNotifierProvider(create: (c) => AgoraProvider()),
              ChangeNotifierProxyProvider<UserProvider, ChatProvider>(
                update: (ctx, user, previousChat) => ChatProvider(
                    user.userId,
                    user.name,
                    user.number,
                    user.email,
                    user.image,
                    user.about,
                    previousChat == null ? [] : previousChat.items),
                create: (ctx) => ChatProvider(
                    userid, name, number, email, image, about, chat),
              ),
              ChangeNotifierProxyProvider<UserProvider, MessageProvider>(
                update: (ctx, mess, previousMes) =>
                    MessageProvider(mess.number),
                create: (ctx) => MessageProvider(number),
              ),
            ],
            child: Consumer<UserProvider>(
              builder: (ctx, user, ch) => OverlaySupport(
                child: MaterialApp(
                    title: 'ChatEasy',
                    //by default theme mode is ThemeMode.system
                    theme: darkThemeData(context),
                    debugShowCheckedModeBanner: false,
                    home: user.isAuth
                        ? HomeScreen()
                        : FutureBuilder(
                            future: user.tryAutoLogin(),
                            builder: (ctx, userRes) =>
                                userRes.connectionState ==
                                        ConnectionState.waiting
                                    ? const SplashScreen()
                                    : WelcomeScreens(),
                          ),
                    routes: {
                      WelcomeScreens.routename: (ctx) => WelcomeScreens(),
                      HomeScreen.routename: (ctx) => HomeScreen(),
                      SignupScreen.routename: (ctx) => SignupScreen(),
                      LoginScreen.routename: (ctx) => LoginScreen(),
                      CameraScreen.routename: (ctx) => CameraScreen(),
                      EditProfileScreen.routename: (ctx) => EditProfileScreen(),
                      ProfilePage.routename: (ctx) => ProfilePage(),
                    }),
              ),
            ),
          );
        });
  }
}

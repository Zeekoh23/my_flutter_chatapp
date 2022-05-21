import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../screens/splash_screen.dart';
import 'home_screen.dart';
import '../widgets/signup_card.dart';
import '../providers/user_provider.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({Key? key}) : super(key: key);
  static const routename = '/signup';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, user, ch) => Scaffold(
        body: user.isAuth
            ? HomeScreen()
            : FutureBuilder(
                future: user.tryAutoLogin(),
                builder: (ctx, userResultSnapshot) =>
                    userResultSnapshot.connectionState ==
                            ConnectionState.waiting
                        ? SplashScreen()
                        : SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kDefaultPadding,
                              ),
                              child: SingleChildScrollView(
                                child: SignupCard(),
                              ),
                            ),
                          ),
              ),
      ),
    );
  }

  Widget fields(
    IconData icon,
    String hintText,
    Size size,
    TextEditingController controller,
  ) {
    return Container(
      height: size.height / 14,
      width: size.width / 1.1,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

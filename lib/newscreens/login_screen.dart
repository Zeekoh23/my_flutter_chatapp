import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../constants.dart';

import '../widgets/login_card.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routename = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<UserProvider>(
      builder: (ctx, user, ch) => Scaffold(
        body: user.isAuth
            ? HomeScreen()
            : FutureBuilder(
                future: user.tryAutoLogin(),
                builder: (ctx, userResultSnapshot) => SafeArea(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                      ),
                      child: LoginCard() //),
                      ),
                ),
              ),
      ),
    );
  }

  Widget fields(IconData icon, String hintText, Size size,
      TextEditingController controller) {
    return Container(
      height: size.height / 14,
      width: size.width / 1.1,
      child: TextField(
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

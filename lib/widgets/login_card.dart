import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/primary_button.dart';
import '../newscreens/signup_screen.dart';
import '../models/http_exception.dart';
import '../providers/user_provider.dart';
import '../newscreens/forgotpassword_screen.dart';
import '../constants.dart';

class LoginCard extends StatefulWidget {
  LoginCard({Key? key}) : super(key: key);

  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  void createAcount(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(SignupScreen.routename);
  }

  final TextEditingController _number = TextEditingController();
  final TextEditingController _password = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, String> _userData = {'number': '', 'password': ''};

  var _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          title: const Text('An error occurred!'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                }),
          ]),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .login(_userData['number']!, _userData['password']!);
    } on HttpException catch (error) {
      var errMsg = 'Authentication failed';
      if (error.toString().contains('Incorrect number or password')) {
        errMsg = 'Incorrect number or password';
      }
      _showErrorDialog(errMsg);
    } catch (error) {
      const errMsg = 'Could not authenticate you. Please try again later.';
      _showErrorDialog(errMsg);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(children: <Widget>[
      const SizedBox(
        height: kDefaultPadding * 2,
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          //width: size.width / 1.1,
          child: const Text(
            'Welcome',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          //width: size.width / 1.3,
          child: const Text(
            'Log in to continue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ]),
      SizedBox(
        height: size.height / 10,
      ),
      Form(
        key: _formKey,
        child: Column(children: [
          Container(
              height: size.height / 8,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                width: size.width / 1.1,
                child: TextFormField(
                  controller: _number,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _userData['number'] = value!;
                  },
                  validator: (value) {
                    value = value.toString();
                    if (value.isEmpty) {
                      return 'This is empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone),
                    hintText: 'number',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18.0,
            ),
            child: Container(
                height: size.height / 8,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  width: size.width / 1.1,
                  child: TextFormField(
                    controller: _password,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    validator: (value) {
                      value = value.toString();
                      if (value.isEmpty || value.length < 5) {
                        return 'Password is too short!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userData['password'] = value!;
                    },
                    onFieldSubmitted: (_) {
                      _submit();
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'password',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )),
          ),
        ]),
      ),
      const SizedBox(
        height: kDefaultPadding * 0.5,
      ),
      if (_isLoading)
        const CircularProgressIndicator()
      else
        PrimaryButton(text: 'Log In', press: _submit),
      SizedBox(
        height: size.height / 40,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              createAcount(context);
            },
            child: const Text(
              'Sign up',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen()));
              }),
        ],
      ),
    ]));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../widgets/primary_button.dart';
import '../newscreens/login_screen.dart';
import '../models/http_exception.dart';
import '../providers/user_provider.dart';

class SignupCard extends StatefulWidget {
  SignupCard({Key? key}) : super(key: key);

  _SignupCardState createState() => _SignupCardState();
}

class _SignupCardState extends State<SignupCard> {
  void loginScreen(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(LoginScreen.routename);
  }

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _about = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, String> _userData = {
    'name': '',
    'email': '',
    'number': '',
    'about': '',
    'password': '',
    'passwordConfirm': '',
  };

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
      await Provider.of<UserProvider>(context, listen: false).signup(
          _userData['name']!,
          _userData['email']!,
          _userData['number']!,
          _userData['password']!,
          _userData['passwordConfirm']!,
          _userData['about']!);
    } on HttpException catch (error) {
      var errorMsg = 'Authentication failed';
      if (error
          .toString()
          .contains('Duplicate field value. please use another value')) {
        errorMsg = 'This email address or number is already in use.';
      } else if (error
          .toString()
          .contains('Invalid input data. Please provide an email')) {
        errorMsg = 'Wrong email format';
      } else if (error
          .toString()
          .contains('Invalid input data. Path `password`')) {
        errorMsg = 'This password is too weak. Minimum of 8 character length';
      }
      _showErrorDialog(errorMsg);
    } catch (error) {
      const errorMsg =
          'Could not authenticate you, network issues. Please try again later.';
      _showErrorDialog(errorMsg);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        const SizedBox(
          height: kDefaultPadding,
        ),
        SizedBox(
          height: size.height / 100,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                'Sign in to continue',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        SizedBox(
          height: size.height / 20,
        ),
        Form(
          key: _formKey,
          child: Column(children: [
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
                      textInputAction: TextInputAction.next,
                      controller: _name,
                      keyboardType: TextInputType.name,
                      onSaved: (value) {
                        _userData['name'] = value!;
                      },
                      validator: (value) {
                        value = value.toString();
                        if (value.isEmpty) {
                          return 'Your Name is empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'name',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )),
            ),
            Container(
                height: size.height / 8,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  width: size.width / 1.1,
                  child: TextFormField(
                    controller: _email,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      value = value.toString();
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userData['email'] = value!;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      hintText: 'email',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
              ),
              child: Container(
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
                        if (value.isEmpty || value.length <= 10) {
                          return 'Your phone number is too short';
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
              ),
              child: Container(
                  height: size.height / 8,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    width: size.width / 1.1,
                    child: TextFormField(
                      controller: _about,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      onSaved: (value) {
                        _userData['about'] = value!;
                      },
                      validator: (value) {
                        value = value.toString();
                        if (value.isEmpty || value.length < 6) {
                          return 'This is short';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.account_box),
                        hintText: 'About',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 14.0,
              ),
              child: Container(
                  height: size.height / 8,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    width: size.width / 1.1,
                    child: TextFormField(
                      controller: _password,
                      textInputAction: TextInputAction.next,
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
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 3.0,
              ),
              child: Container(
                  height: size.height / 8,
                  width: size.width,
                  alignment: Alignment.center,
                  child: Container(
                    width: size.width / 1.1,
                    child: TextFormField(
                      controller: _passwordConfirm,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        value = value.toString();
                        if (value != _password.text) {
                          return 'Passwords do not match';
                        }
                        if (value.isEmpty || value.length < 5) {
                          return 'Password is too short';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userData['passwordConfirm'] = value!;
                      },
                      onFieldSubmitted: (_) {
                        _submit();
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        hintText: 'passwordConfirm',
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
        SizedBox(
          height: size.height / 40,
        ),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          PrimaryButton(
            color: Theme.of(context).colorScheme.secondary,
            text: 'Sign Up',
            press: _submit,
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              loginScreen(context);
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ));
  }
}

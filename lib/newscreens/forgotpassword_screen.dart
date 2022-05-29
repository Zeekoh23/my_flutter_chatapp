import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../constants.dart';
import '../models/http_exception.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, String> _userData = {'email': ''};
  var _isLoading = false;

  _showErrorDialog(String message) {
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .forgotPassword(_userData['email']!);
    } on HttpException catch (err) {
      var errMsg = 'An error occurred';
      if (err.toString().contains('There is no user with email address')) {
        errMsg = 'There is no user with email address';
      } else if (err
          .toString()
          .contains('Cast to ObjectId failed for value \"forgotpassword\"')) {
        errMsg = 'Id issue';
      } else if (err.toString().contains(
          'Invalid greeting. response=421 Server busy, too many connections')) {
        errMsg = 'Sent too many emails';
      }
      _showErrorDialog(errMsg);
    } catch (err) {
      const errMsg = 'email not sent';
      await _showErrorDialog(errMsg);
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password?')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: kDefaultPadding * 2,
                    ),
                    Container(
                      width: size.width / 1.1,
                      child: const Text(
                        'Please put your correct Email',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Form(
                      key: _formKey,
                      child: Container(
                        height: size.height / 10,
                        width: size.width,
                        alignment: Alignment.center,
                        child: Container(
                          width: size.width / 1.1,
                          child: TextFormField(
                            controller: controller,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty || !value.contains('@')) {
                                return 'Invalid email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _userData['email'] = value!;
                            },
                            onFieldSubmitted: (_) async {
                              _saveForm();
                            },
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                hintText: 'email',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: size.height / 40,
                    ),
                    PrimaryButton(
                        color: Theme.of(context).colorScheme.secondary,
                        text: 'Submit',
                        press: _saveForm),
                  ],
                ),
              )),
    );
  }
}

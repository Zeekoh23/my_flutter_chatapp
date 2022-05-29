import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../constants.dart';
import '../models/user_model.dart';
import '../providers/chat_provider.dart';
import '../newscreens/home_screen.dart';
import '../models/http_exception.dart';
import '../widgets/headercurved_cont.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  static const routename = '/editprofile';

  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String get number {
    var number = Provider.of<UserProvider>(context, listen: false).number;
    return number;
  }

  String get about {
    var about = Provider.of<UserProvider>(context, listen: false).about;
    return about;
  }

  String get name {
    var name = Provider.of<UserProvider>(context, listen: false).name;
    return name;
  }

  String get image {
    var image = Provider.of<UserProvider>(context, listen: false).image;
    return image;
  }

  final _nameFocusNode = FocusNode();
  final _numberFocusNode = FocusNode();
  final _aboutFocusNode = FocusNode();
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var _editUser = UserItem(name: '', about: '');
  var _initVals = {'name': '', 'number': '', 'about': ''};
  var _isInit = true;
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

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _editUser.name = name;

      _editUser.about = about;
      _initVals = {'name': _editUser.name!, 'about': _editUser.about!};
      _namecontroller.text = _editUser.name!;

      _aboutController.text = _editUser.about!;
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    try {
      var chats = Provider.of<ChatProvider>(context, listen: false);
      await Provider.of<UserProvider>(context, listen: false)
          .updateUser(_editUser);
      await chats.updateChatAbout(_editUser.about!);
      await chats.updateChatName(_editUser.name!);
    } on HttpException catch (err) {
      var errMsg = 'An error occurred';
      if (err
          .toString()
          .contains('Cast to ObjectId failed for value \"forgotpassword\"')) {
        errMsg = 'Id issue';
      } else if (err.toString().contains(
          'Invalid greeting. response=421 Server busy, too many connections')) {
        errMsg = 'Sent too many emails';
      }
      _showErrorDialog(errMsg);
    } catch (error) {
      var errMsg = 'Could not update. Please try again later';
      _showErrorDialog(errMsg);
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushNamed(HomeScreen.routename);
    }
    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushNamed(HomeScreen.routename);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                painter: HeaderCurvedContainer(a: 100, b: 100),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
                  Widget>[
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 35,
                      letterSpacing: 1.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Material(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(
                                letterSpacing: 2,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              fillColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFFdfcfa), width: 0.04)),
                            ),
                            initialValue: _initVals['name'],
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a value.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editUser =
                                  UserItem(name: value, about: _editUser.about);
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Material(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                  letterSpacing: 2,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                fillColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xFFFdfcfa),
                                        width: 0.04))),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            controller: _aboutController,
                            validator: (val) {
                              if (val!.length < 6) {
                                return 'Should be at least 6 characters';
                              }
                              if (val.isEmpty) {
                                return 'Its empty';
                              }
                              return '';
                            },
                            onSaved: (value) {
                              _editUser =
                                  UserItem(name: _editUser.name, about: value);
                            },
                            onFieldSubmitted: (_) async {
                              _saveForm();
                            },
                          ),
                        )
                      ]),
                ),
                const SizedBox(
                  height: 40,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 55,
                      width: double.infinity,
                      child: RaisedButton(
                        onPressed: () async {
                          _saveForm();
                        },
                        color: kPrimaryColor,
                        child: const Center(
                          child: Text(
                            'Update',
                            style: TextStyle(
                              fontSize: 23,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ])
            ])),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
        //backgroundColor: Color(0xFF013666),
        );
  }
}

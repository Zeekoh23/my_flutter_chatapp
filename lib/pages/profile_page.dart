import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../newscreens/welcome_screens.dart';
import '../screens/profilepicview_screen.dart';
import '../screens/editprofile_screen.dart';
import '../providers/user_provider.dart';
import '../widgets/headercurved_cont.dart';
import '../widgets/cloudinary_image.dart';
import '../widgets/normal_image.dart';

import '../helpers/socket_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const routename = '/profilepage';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var socket = SocketHelper.shared;
  XFile? xfile;
  ImagePicker imagePicker = ImagePicker();
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

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var result = image.substring(0, 22);
    final viewinsets = MediaQuery.of(context).viewInsets;
    final size = MediaQuery.of(context).size;

    print(result);
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              /*CustomPaint(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 40,
                  ),
                  painter: HeaderCurvedContainer(a: 220, b: 220)),*/
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height / 199),
                  Padding(
                    padding: EdgeInsets.only(
                      left: viewinsets.left + size.width - 126,
                    ),
                    child: TextButton(
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(EditProfileScreen.routename);
                      },
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 35,
                      letterSpacing: 1.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (result == 'https://res.cloudinary')
                    CloudinaryImage1(image: image)
                  else
                    NormalImage(path: image),
                  const SizedBox(
                    height: 10,
                  ),
                  textfield(name),
                  const SizedBox(
                    height: 15,
                  ),
                  textfield(number),
                  const SizedBox(
                    height: 15,
                  ),
                  textfield(about),
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
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed(WelcomeScreens.routename);
                            Provider.of<UserProvider>(context, listen: false)
                                .logout();
                          },
                          color: kPrimaryColor,
                          child: const Center(
                            child: Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 23,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: viewinsets.bottom + size.height - 535,
                    left: viewinsets.left + size.width - 264),
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        socket.msgController.profilePage.value = true;
                        socket.msgController.popUp.value = 1;
                        xfile = await imagePicker.pickImage(
                            source: ImageSource.gallery);

                        if (xfile!.path == null) {
                          Navigator.pop(context);
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    ProfileViewPicScreen(path: xfile!.path)));
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textfield(String hintText) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              //letterSpacing: 2,
              color: Colors.white,
              //fontWeight: FontWeight.bold,
            ),
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFdfcfa), width: 0.04))),
        readOnly: true,
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: kPrimaryColor.withOpacity(0.05),
      automaticallyImplyLeading: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../constants.dart';
import '../screens/profilepicview_screen.dart';
import '../helpers/socket_helper.dart';
import '../widgets/picture_type.dart';
import './audiocall_screen.dart';
import './videocall_screen.dart';

class UserProfileScreen extends StatefulWidget {
  UserProfileScreen({Key? key, this.name, this.image, this.about, this.number})
      : super(key: key);

  String? name;
  String? image;
  String? about;
  String? number;

  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  var socket = SocketHelper.shared;
  Widget build(BuildContext context) {
    var result = widget.image!.substring(0, 22);
    var cloudinaryImage = CloudinaryImage(widget.image!);
    final String imagePath =
        cloudinaryImage.transform().width(610).height(600).generate();
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Contact Info')),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (result == 'https://res.cloudinary')
                        PictureType(path: imagePath)
                      else
                        PictureType(path: widget.image!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.name!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.number!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 80,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => AudioCallScreen(
                                        name: widget.name,
                                        image: widget.image)));
                          },
                          child: Column(
                            children: [
                              const SizedBox(height: 7),
                              const Icon(Icons.local_phone, size: 38),
                              const SizedBox(height: 7),
                              const Text(
                                'Audio',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Container(
                        width: 90,
                        height: 80,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (builder) => VideoCallScreen(),
                                ));
                          },
                          child: Column(
                            children: [
                              const SizedBox(height: 7),
                              const Icon(Icons.videocam, size: 38),
                              const SizedBox(height: 7),
                              const Text(
                                'Video',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width - 55,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 19, horizontal: 14),
                      child: Text(
                        widget.about!,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

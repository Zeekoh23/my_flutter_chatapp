import 'package:flutter/material.dart';

import '../size_config.dart';
import '../constants.dart';
import '../widgets/splash_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;

  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to ChatEasy",
      "image": 'assets/images/chatimage1.jpg',
    },
    {"text": "A convenient way to chat", "image": "assets/images/chatimg2.jpg"},
    {"text": "Chat with ease", "image": "assets/images/chatimg3.jpg"}
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
        body: Center(
      child: Column(
        children: <Widget>[
          const Spacer(),
          Expanded(
            flex: 3,
            child: PageView.builder(
                onPageChanged: (val) {
                  setState(() {
                    currentPage = val;
                  });
                },
                itemCount: splashData.length,
                itemBuilder: (context, index) => SplashContent(
                    image: splashData[index]['image'],
                    text: splashData[index]['text'])),
          ),
          const Spacer(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  splashData.length,
                  (index) => buildDot(index),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

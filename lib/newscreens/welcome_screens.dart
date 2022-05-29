import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/splash_content.dart';
import '../constants.dart';
import './login_screen.dart';
import '../size_config.dart';

class WelcomeScreens extends StatefulWidget {
  static const routename = '/welcomes';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreens> {
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
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: <Widget>[
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
                      text: splashData[index]['text']),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(20),
                  ),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => buildDot(index),
                        ),
                      ),
                      const Spacer(flex: 3),
                      SizedBox(
                        width: double.infinity,
                        height: getProportionateScreenHeight(70),
                        child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            color: kPrimaryColor,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      childCurrent: widget,
                                      duration:
                                          const Duration(milliseconds: 600),
                                      type:
                                          PageTransitionType.leftToRightJoined,
                                      child: LoginScreen()));
                            },
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: getProportionateScreenWidth(18),
                                color: Colors.white,
                              ),
                            )),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

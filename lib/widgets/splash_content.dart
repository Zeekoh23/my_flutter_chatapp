import 'package:flutter/material.dart';

import '../size_config.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({Key? key, this.text, this.image}) : super(key: key);
  final String? text, image;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Text('ChatEasy',
            style: TextStyle(
                fontSize: getProportionateScreenWidth(36),
                fontWeight: FontWeight.bold)),
        Text(text!,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        const Spacer(flex: 2),
        Image.asset(image!,
            height: getProportionateScreenHeight(245),
            width: getProportionateScreenWidth(295)),
      ],
    );
  }
}

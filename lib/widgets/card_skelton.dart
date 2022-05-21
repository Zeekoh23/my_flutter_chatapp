import 'package:flutter/material.dart';

import '../constants.dart';

class CardSkelton extends StatelessWidget {
  CardSkelton({Key? key, this.height, this.width}) : super(key: key);
  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 6),
        Skelton(height: 34, width: 34),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skelton(),
              SizedBox(height: 8),
              Skelton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget Skelton({double? height, double? width}) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.08),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}

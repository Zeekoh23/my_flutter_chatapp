import 'package:flutter/material.dart';

import '../constants.dart';

class HeaderCurvedContainer extends CustomPainter {
  HeaderCurvedContainer({Key? key, required this.a, required this.b});
  double a;
  double b;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = kPrimaryColor;
    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 1, a, size.width / 1, b)
      ..relativeLineTo(0, -150)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class HeaderCurvedContainer extends CustomPainter {
  HeaderCurvedContainer({Key? key, required this.a, required this.b});
  double a;
  double b;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xFF013666);
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

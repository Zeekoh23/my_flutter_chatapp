import 'package:flutter/material.dart';

class ZoomImage extends StatefulWidget {
  ZoomImage({
    Key? key,
    this.child,
  }) : super(key: key);

  Widget? child;

  @override
  _ZoomImageState createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  TapDownDetails? tapDownDetails;

  late AnimationController _animationController;
  Animation<Matrix4>? animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        _transformationController.value = animation!.value;
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void onDoubleTap() {
    final position = tapDownDetails!.localPosition;

    const double scale = 3;
    final x = -position.dx * (scale - 1);
    final y = -position.dy * (scale - 1);
    final zoomed = Matrix4.identity()
      ..translate(x, y)
      ..scale(scale);
    final value = _transformationController.value.isIdentity()
        ? zoomed
        : Matrix4.identity();

    animation = Matrix4Tween(
      begin: _transformationController.value,
      end: value,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_animationController));
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (details) => tapDownDetails = details,
      onDoubleTap: () {
        onDoubleTap();
      },
      child: InteractiveViewer(
        clipBehavior: Clip.none,
        transformationController: _transformationController,
        panEnabled: false,
        scaleEnabled: false,
        child: widget.child!,
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/widgets/zoom_image.dart';
import 'package:lottie/lottie.dart';

class Page2 extends StatefulWidget {

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> with SingleTickerProviderStateMixin {

  late TransformationController controller;
  late AnimationController animationController;
  Animation<Matrix4>? animation;

  final double minScale = 1;
  final double maxScale = 2;

  @override
  void initState() {
    super.initState();

    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200)
    )..addListener(() => controller.value = animation!.value);
  }

  @override
  void dispose(){
    controller.dispose();
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          panEnabled: false,
          minScale: minScale,
          maxScale: maxScale,
          onInteractionStart: (details){},
          onInteractionEnd: (details) {
            resetAnimation();
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network("https://images.unsplash.com/photo-1505051508008-923feaf90180?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=2070&q=80",
              fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ),
    );
  }

  void resetAnimation(){
      animation = Matrix4Tween(
        begin: controller.value,
        end: Matrix4.identity(),
      ).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear)
      );

      animationController.forward(from: 0);
  }
}
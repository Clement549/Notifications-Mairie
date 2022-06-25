import 'dart:io';
import 'dart:math' as math;
import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';


class CameraWidget extends StatefulWidget {
  CameraWidget({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  CameraWidgetState createState() => CameraWidgetState();
}

class CameraWidgetState extends State<CameraWidget> {

  final photos = <File>[];

  void openCamera() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CameraCamera(
                  onFile: (file) {
                    photos.add(file);
                    Navigator.pop(context);
                    setState(() {});
                  },
            )));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(photos.length == 0)
          Container(),
          if(photos.length > 0)
          Container(
              alignment: Alignment.center,
              width: size.width,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Image.file(
                photos[photos.length - 1],
                fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openCamera,
          child: Icon(Icons.camera_alt),
        ),
    );
  }
}
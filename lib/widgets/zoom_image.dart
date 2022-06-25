import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ZoomImage extends StatefulWidget {

  @override
  _ZoomImageState createState() => _ZoomImageState();
}

class _ZoomImageState extends State<ZoomImage> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        clipBehavior: Clip.none,
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network("https://unsplash.com/photos/ebHCU8n7G38",
            fit: BoxFit.cover,
            ),
          ),
        ),
      )
    );
  }
}
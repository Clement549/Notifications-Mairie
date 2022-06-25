import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class ShimmerWidget extends StatelessWidget{

  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerWidget.rectangular({
    this.width=double.infinity,
    required this.height,
  }) : this.shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.circular({
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

@override
Widget build(BuildContext context) => Shimmer.fromColors(
  baseColor: Colors.grey[400]!,
  highlightColor: Colors.grey[300]!,
  child: Container(
    padding: EdgeInsets.all(0),
    margin: EdgeInsets.all(0),
    width: width,
    height: height,
    decoration: ShapeDecoration(
      shape: shapeBorder,
      color: Colors.grey[400]!,
    ),
    ),
  );
}
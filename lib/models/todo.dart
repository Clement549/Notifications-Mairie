import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:uuid/uuid.dart';

class Todo {
  String id;
  String title;
  String body;
  Timestamp date;
  String img1;
  String img2;
  String img3;
  String pdf;
  String map;
  String topic;
  Function myFunc;

  Todo({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.img1,
    required this.img2,
    required this.img3,
    required this.pdf,
    required this.map,
    required this.topic,
    required this.myFunc,
  });
}



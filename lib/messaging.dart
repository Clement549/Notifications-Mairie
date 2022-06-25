import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

class Messaging {
  static final Client client = Client();

  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  static const String serverKey =
      'AAAA0SIr42M:APA91bGOcLAYoIUztEk5Ea5CvCQFi2MQAlCwqS2qpo1d5XnV8rMbLm5q1u3xOcxk6nYjNgoR5d6I5uOzg_v3R9bbzJqYSNivcfJluJsuKyEEpoQkaXgPjC8waF_RD-m9zJvcP0Fexh8Q';

  static Future<Response> sendToAll({
    @required String ?title,
    @required String ?body,
    @required Timestamp ?date,
    @required String ?img1,
    @required String ?img2,
    @required String ?img3,
    @required String ?pdf,
    @required String ?map,
    @required Function ?myFunc,
    @required String ?id,
    @required String ?topic,
  }) =>
      sendToTopic(title: title, body: body, date: date, img1: img1, img2: img2, img3: img3, pdf: pdf, map: map, myFunc: myFunc, id: id, topic: topic);

  static Future<Response> sendToTopic(
          {@required String ?title,
          @required String ?body,
          @required Timestamp ?date,
          @required String ?img1,
          @required String ?img2,
          @required String ?img3,
          @required String ?pdf,
          @required String ?map,
          @required Function ?myFunc,
          @required String ?id,
          @required String ?topic,
          }) =>
      sendTo(title: title!, body: body!, date: date!, img1: img1!, img2: img2!, img3: img3!, pdf: pdf!, map: map!, myFunc: myFunc!, id: id!, fcmToken: '/topics/$topic');

  static Future<Response> sendTo({
    @required String ?title,
    @required String ?body,
    @required Timestamp ?date,
    @required String ?img1,
    @required String ?img2,
    @required String ?img3,
    @required String ?pdf,
    @required String ?map,
    @required Function ?myFunc,
    @required String ?id,
    @required String ?fcmToken,
  }) =>
      client.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        body: json.encode({
          'notification': {
            'body': '$body', 
            'title': '$title', 
            'color':"#32A2E8",
            'image': img1,
          },
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '$id',
            'status': 'done',
            'route': 'message_page',

            'title': '$title',
            'body': '$body',
            'date': '$date',
            'img1': '$img1',
            'img2': '$img2',
            'img3': '$img3',
            'pdf': '$pdf',
            'map': '$map',
          },
          'to': '$fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );
}
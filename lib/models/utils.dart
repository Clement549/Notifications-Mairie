

import 'package:flutter/cupertino.dart';
import 'package:overlay_support/overlay_support.dart';

class Utils{

  static void showTopSnackBar(
    BuildContext context,
    String title,
    String message,
    Color color,
  ) =>
    showSimpleNotification(
      Text(title),
      subtitle: Text(message),
      background: color,
      slideDismiss: true,
    );
}
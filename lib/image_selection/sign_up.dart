import 'package:flutter/material.dart';
import 'package:flutter_course/image_selection/user_image.dart';

class SignUp extends StatefulWidget {

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  String imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        const SizedBox(height: 15),

        UserImage(
          onFileChanged: (imageUrl) {
            setState(() {
              this.imageUrl = imageUrl;
            });
          },
        ),
      ])
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/image_selection/profil_image.dart';
import 'package:flutter_course/widgets/camera.dart';
import 'package:flutter_course/widgets/gallery_widget.dart';
import 'package:flutter_course/widgets/story_widget.dart';


class ProfilPage extends StatefulWidget {

  @override
  ProfilPageState createState() => ProfilPageState();
}

class ProfilPageState extends State<ProfilPage> {

  final urlImages = [
    "https://source.unsplash.com/random",
    "https://source.unsplash.com/random",
    "https://source.unsplash.com/random",
    "https://source.unsplash.com/random",
    "https://source.unsplash.com/random",
    "https://source.unsplash.com/random",
    "https://source.unsplash.com/random",
    "https://source.unsplash.com/random",
  ];

  String pdp = "";

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: [

            Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: ProfilImage(
                              
                 onFileChanged: (imageUrl) {
                  setState(() {
                     this.pdp = imageUrl;
                  });
                  }
              ),
            ),
            
            ElevatedButton(
              onPressed: () async { 

                var pos = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Story(),
                        ),
                );

               }, 
              child: const Text("Button")
            ),

            ElevatedButton(
              onPressed: () async { 

                var pos = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraScreen(),
                        ),
                );

               }, 
              child: const Text("Button")
            ),

            InkWell(
              child: Ink.image(
                image: NetworkImage(urlImages.first),
                height: 300,
                fit: BoxFit.cover,
              ),
              onTap: openGallery,
              ),
            ],
          ),
        ),
      );
  }

    void openGallery() => Navigator.of(context).push(MaterialPageRoute(

        builder: (_) => GalleryWidget(urlImages: urlImages),
      ),
    );

}

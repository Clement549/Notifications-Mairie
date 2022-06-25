import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/widgets/rounded_button_widget.dart';
import 'package:flutter_course/widgets/zoom_image.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryWidget extends StatefulWidget {

  final List<String> urlImages;
  final  int index;
  final PageController pageController;

  GalleryWidget({
    required this.urlImages, 
    this.index = 0, 
  }) : pageController = PageController(initialPage: index);

  @override
  GalleryWidgetState createState() => GalleryWidgetState();
}

class GalleryWidgetState extends State<GalleryWidget> {

 late int index = widget.index;

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
            children:[
              PhotoViewGallery.builder(
              pageController: widget.pageController,
              itemCount: widget.urlImages.length,
              builder: (context, index) {

                final urlImages = widget.urlImages[index];

                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(urlImages),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 4,
                );
              },
              onPageChanged: (index) => setState(() {
                this.index = index;
              }),
            ),
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(16),
              child: Text(
                'Image ${index + 1}/${widget.urlImages.length}',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic),
              )
            ),
            Container(
              alignment: Alignment.topLeft,
              //padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.fromLTRB(5,23,5,23),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                iconSize: 20,
                color: Colors.white.withOpacity(0.5),
              )
            ),
          ],
        ),
      );
    }
}
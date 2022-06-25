import 'dart:io';
import 'dart:math' as math;
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter_course/image_selection/user_image.dart';
import 'package:flutter_course/widgets/capture_camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:story_creator/story_creator.dart';

class PreviewScreen extends StatelessWidget {
  final File imageFile;
  final List<File> fileList;
  final bool isRear;

  const PreviewScreen({
    required this.imageFile,
    required this.fileList,
    required this.isRear,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child:SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [   
          if(isRear)
          Expanded(
                child: Image.file(imageFile),
          ),
          if(!isRear)
          Expanded(
            child: Transform(
               alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),
                child: Image.file(
                imageFile,
                //fit: BoxFit.cover,
                ),
              ),
          ),
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,0),
              child: TextButton(
                onPressed: () {
                  /*Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => CapturesScreen(
                        imageFileList: fileList,
                      ),
                    ),
                  );*/
                  Navigator.pop(context);
                },
                child: Text('Back'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,0),
              child: TextButton(
                onPressed: () async{

                  var nav = Navigator.of(context);
                  nav.pop();
                  nav.pop();

                  
                  File compressedFile = await compressImagePath(imageFile.path, 70);
                  await UserImageState.uploadFile(compressedFile.path);

                },
                child: Text('Ok'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,0),
              child: TextButton(
                onPressed: () async{

                  try{

                    File editedFile = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context)=> StoryCreator(
                          filePath: imageFile.path,
                      ),
                      ),
                    );

                    if(editedFile != null){

                      var nav = Navigator.of(context);
                      nav.pop();
                      nav.pop();

                      File compressedFile = await compressImagePath(editedFile.path, 70);
                      await UserImageState.uploadFile(compressedFile.path);
                    }

                  }
                  catch(e){print(e);}

                },
                child: Text('Add Text'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ]))));
  }


  Future<File> compressImagePath(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path, '${DateTime.now()}.jpg');

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );

    return result!;
  }
}
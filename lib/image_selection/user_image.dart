import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/image_selection/round_image.dart';
import 'package:flutter_course/widgets/todo_cards.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // flutter run -d chrome --web-renderer html  // flutter build web --web-renderer html --release


class UserImage extends StatefulWidget {

  final Function(String imageUrl) onFileChanged;

  UserImage({
    required this.onFileChanged,
  });

  @override
  UserImageState createState() => UserImageState();
}

class UserImageState extends State<UserImage> {

  final ImagePicker _picker = ImagePicker();

  String? imageUrl;

  final Stream<QuerySnapshot> users = FirebaseFirestore.instance.collection('news').snapshots(); // read Firestore value

  @override
  void initState(){ // onStart()
    getData();
    super.initState();
  }

  getData() async{ //url image profil

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
      //imageUrl = prefs.getString("profilPic");
    });
  }


  @override
  Widget build(BuildContext context) {
   return Container(
     alignment: Alignment.center,
     child: Column(
      children: [
        if (imageUrl == null)
         GestureDetector(
          child: const Icon(Icons.image, size: 60, color: Colors.blueAccent,),
          onTap: () => _selectPhoto(),
         ),

        if (imageUrl != null)
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => _selectPhoto(),
            //child: AppRoundImage.url(
              //imageUrl!,
              //width: 200,
              //height: 200,
            //),
            child:Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.file(   //network
                          File(imageUrl!),
                          height: 150,
                      ),
              ),
            ),
          ),

        InkWell(
          onTap: () => _selectPhoto(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
            child: Text(imageUrl != null
                ? 'Changer image'
                : 'Ajouter image',
              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),),
          ),
        ),
        
      /*  Container( // read firestore value
          height: 250,
          child: StreamBuilder<QuerySnapshot>(stream: users, builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.hasError){
              return const Text("error");
            }
            if(snapshot.connectionState == ConnectionState.waiting){
               return const Text("Loading");
            }

            final data = snapshot.requireData;

            return ListView.builder(
              itemCount: data.size, 
              itemBuilder: (context,index){
                return ToDoCard(title: data.docs[index]["title"], body: data.docs[index]["body"], img1: data.docs[index]["img1"], img2: data.docs[index]["img2"], img3: data.docs[index]["img3"], pdf: data.docs[index]["pdf"], date: data.docs[index]["date"], index: data.docs[index][index], );
              },
            );
          }),
        ),  */
      ],
    ),
   );
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(context: context, builder: (context) => BottomSheet(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: Icon(Icons.camera), title: Text('Caméra'), onTap: () {
            Navigator.of(context).pop();
            _pickImage(ImageSource.camera);
          }),
          ListTile(leading: Icon(Icons.filter), title: Text('Gallerie'), onTap: () {
            Navigator.of(context).pop();
            _pickImage(ImageSource.gallery);
          }),
        ],
      ),
      onClosing: () {},
    ));
  }

  Future _pickImage(ImageSource source) async {

    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile == null) {
      return;
    }

    if(!kIsWeb){

      var file = await ImageCropper.cropImage(sourcePath: pickedFile.path,); //aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1)
      
      if (file == null) {
        return;
      }

      file = await compressImagePath(file.path, 35);

      setState(() { imageUrl = file!.path; });
      widget.onFileChanged(file.path);
    }
    else{

      var file = await compressImagePath(pickedFile.path, 35);

      setState(() { imageUrl = file.path; });
      widget.onFileChanged(file.path);
    }
  }

  Future<File> compressImagePath(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path, '${DateTime.now()}.${p.extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      newPath,
      quality: quality,
    );

    return result!;
  }

  static Future<String> uploadFile(String path) async {

    var uuid = const Uuid();

    final ref = storage.FirebaseStorage.instance.ref()
      .child('images')
      .child('${uuid.v4()}.jpg');

    //setState(() { imageUrl = fileUrl; });
    //widget.onFileChanged(fileUrl);

    final result = await ref.putFile(File(path));
    final fileUrl = await result.ref.getDownloadURL();
 

    return fileUrl;
  }


  void saveProfilPicUrl(url) async {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState((){
        prefs.setString("profilPic", url);
      });
    }

  void _deleteProfilPic(url) async {

     if(url != null){

        FirebaseFirestore.instance
        .collection("news")
        //.where("chapterNumber", isEqualTo : "121 ")
        .get().then((value){
          value.docs.forEach((element) {
           FirebaseFirestore.instance.collection("profilPic").doc(element.id).delete().then((value){
             print("Success!");
           });
          });
        });

        FirebaseStorage.instance.refFromURL(url).delete();
     }
  }
}

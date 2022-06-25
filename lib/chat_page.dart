import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:firebase_storage/firebase_storage.dart' as storage;

import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_course/messaging.dart';
import 'package:flutter_course/widgets/gallery_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: 'j2Zhw650tvVrexBbMYz5');

   List<dynamic> blockedList = [];
   bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    checkIfBlocked();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future checkIfBlocked() async {

      await FirebaseFirestore.instance.collection("users").where("id", isEqualTo: "j2Zhw650tvVrexBbMYz5").get().then((querySnapshot) {
              querySnapshot.docs.forEach((result) {

                      setState((){
                          blockedList = result.data()["blocked"];
                      });
              });
       });

      isBlocked = false;
      blockedList.forEach((item) {
          
        if(item.contains("j2Zhw650tvVrexBbMYz5")){
            isBlocked = true;
            log("you are blocked.");
        } 
      });
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
            /*    TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),   */
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

  void _handleImageSelection() async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {

      if(isBlocked == false){

        final result = await ImagePicker().pickImage(
          imageQuality: 70,
          maxWidth: 1440,
          source: ImageSource.gallery,
        );

        final uid = const Uuid().v4();

        if (result != null) {
          final bytes = await result.readAsBytes();
          final image = await decodeImageFromList(bytes);

          final message = types.ImageMessage(
            author: _user,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            height: image.height.toDouble(),
            id: uid,
            name: result.name,
            size: bytes.length,
            uri: result.path,
            width: image.width.toDouble(),
          );

          _addMessage(message);


          final ref = storage.FirebaseStorage.instance.ref()
            .child('images')
            .child('$uid.jpg');

          final resultImg = await ref.putFile(File(result.path));
          final fileUrl = await resultImg.ref.getDownloadURL();

          CollectionReference msg = FirebaseFirestore.instance.collection("messages");
                        await msg.doc(uid).set({"date": DateTime.now().millisecondsSinceEpoch.toString(), "id": uid, "type": "image", "status": "seen", "receiver": "tNAEAp2lRrP6O5ooecxH3uce4LY2", "sender": "j2Zhw650tvVrexBbMYz5", "height": 600,  "size": 59645,"uri": fileUrl, "width": 1128, "name": result.name})
                            .then((value) => (){})
                            .catchError((error) => print(error)); 

          //await sendNotification(title,body, date, img1, updateList, id,'all');
        }
        else{

          
        }
      }
      else{

        
      }
    }
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
    else if (message is types.ImageMessage) {
      
      List<String> l = [message.uri];

      //openGallery(l);
    }
  }

  void openGallery(urlImages) => Navigator.of(context).push(MaterialPageRoute(

        builder: (_) => GalleryWidget(urlImages: urlImages),
      ),
  );

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {

      if(isBlocked == false){

        final uid = const Uuid().v4();

        final textMessage = types.TextMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: uid,
          text: message.text,
        );

        _addMessage(textMessage);

        CollectionReference msg = FirebaseFirestore.instance.collection("messages");
                        await msg.doc(uid).set({"date": DateTime.now().millisecondsSinceEpoch.toString(), "id": uid, "type": "text", "text": message.text, "status": "seen", "receiver": "tNAEAp2lRrP6O5ooecxH3uce4LY2", "sender": "j2Zhw650tvVrexBbMYz5",})
                            .then((value) => (){})
                            .catchError((error) => print(error)); 

        //await sendNotification(title,body, date, img1, updateList, id,'all');
      }
      else{


      }
    }
    else{


    }
  }

  Future blockUser() async {

      await FirebaseFirestore.instance.collection("users").doc('j2Zhw650tvVrexBbMYz5').update({"blocked": FieldValue.arrayUnion((["tNAEAp2lRrP6O5ooecxH3uce4LY2"]))}); //block user
  }

  void _loadMessages() async {

    String firstName_sender = "";
    String id_sender = "";
    String imageUrl_sender = "";

    String firstName_receiver = "";
    String id_receiver = "";
    String imageUrl_receiver = "";

    String messageId = "";
    String date = "";
    String status = "";
    String type = "";

    String text = "";

    num height = 600;
    num width = 1100;
    num size = 59645;
    String name = "image";
    String uri = "";

    String response_sender = "[{\"author\":{\"firstName\":\"$firstName_sender\",\"id\":\"$id_sender\",\"imageUrl\":\"$imageUrl_sender\"},\"createdAt\":$date,\"id\":\"$messageId\",\"status\":\"$status\",\"text\":\"$text\",\"type\":\"$type\"}]";
    String response_receiver = "[{\"author\":{\"firstName\":\"$firstName_receiver\",\"id\":\"$id_receiver\",\"imageUrl\":\"$imageUrl_receiver\"},\"createdAt\":$date,\"id\":\"$messageId\",\"status\":\"$status\",\"text\":\"$text\",\"type\":\"$type\"}]";
    String responseFinal = "";

    await FirebaseFirestore.instance.collection("users").orderBy('date', descending: true).get().then((querySnapshot) {
              querySnapshot.docs.forEach((result) {

                  if(id_sender.isNotEmpty && id_receiver.isNotEmpty){
                    return;
                  }

                  if(result.data()["id"] == "j2Zhw650tvVrexBbMYz5"){

                        setState((){ 
                            firstName_sender = result.data()["username"];
                            id_sender = result.data()["id"];
                            imageUrl_sender = result.data()["profilPicture"];
                        });
                  }
                  else{
                   
                    setState((){ 
                            firstName_receiver = result.data()["username"];
                            id_receiver = result.data()["id"];
                            imageUrl_receiver = result.data()["profilPicture"];
                        });
                  }
              });
    });
    await FirebaseFirestore.instance.collection("messages").orderBy('date', descending: true).get().then((querySnapshot) {
              querySnapshot.docs.forEach((result) {

                      setState((){ 
                          messageId = result.data()["id"];
                          date= result.data()["date"];
                          status = result.data()["status"];
                          type = result.data()["type"];

                          if(result.data()["sender"] == "j2Zhw650tvVrexBbMYz5"){

                            if(responseFinal.isNotEmpty){ 

                              if(result.data()["type"] == "text"){

                                text = result.data()["text"];

                                responseFinal = responseFinal.substring(0, responseFinal.length - 1); 
                                response_sender = ",{\"author\":{\"firstName\":\"$firstName_sender\",\"id\":\"$id_sender\",\"imageUrl\":\"$imageUrl_sender\"},\"createdAt\":$date,\"id\":\"$messageId\",\"status\":\"$status\",\"text\":\"$text\",\"type\":\"$type\"}]";
                              }
                              else if(result.data()["type"] == "image"){

                                uri = result.data()["uri"];
                                name = result.data()["name"];
                                height = result.data()["height"];
                                width = result.data()["width"];
                                size = result.data()["size"];

                                responseFinal = responseFinal.substring(0, responseFinal.length - 1); 
                                response_sender = ",{\"author\":{\"firstName\":\"$firstName_sender\",\"id\":\"$id_sender\",\"imageUrl\":\"$imageUrl_sender\"},\"createdAt\":$date,\"height\":$height,\"id\":\"$messageId\",\"name\":\"$name\",\"size\":$size,\"status\":\"$status\",\"type\":\"$type\",\"uri\":\"$uri\",\"width\":$width}]";
                              }
                            }
                            else{

                              if(result.data()["type"] == "text"){

                                text = result.data()["text"];

                                response_sender = "[{\"author\":{\"firstName\":\"$firstName_sender\",\"id\":\"$id_sender\",\"imageUrl\":\"$imageUrl_sender\"},\"createdAt\":$date,\"id\":\"$messageId\",\"status\":\"$status\",\"text\":\"$text\",\"type\":\"$type\"}]";
                              }
                              else if(result.data()["type"] == "image"){

                                uri = result.data()["uri"];
                                name = result.data()["name"];
                                height = result.data()["height"];
                                width = result.data()["width"];
                                size = result.data()["size"];

                                response_sender = "[{\"author\":{\"firstName\":\"$firstName_sender\",\"id\":\"$id_sender\",\"imageUrl\":\"$imageUrl_sender\"},\"createdAt\":$date,\"height\":$height,\"id\":\"$messageId\",\"name\":\"$name\",\"size\":$size,\"status\":\"$status\",\"type\":\"$type\",\"uri\":\"$uri\",\"width\":$width}]";
                              }
                            }

                            responseFinal+=response_sender;
                          }
                          else{

                            if(responseFinal.isNotEmpty){ 

                              if(result.data()["type"] == "text"){

                                text = result.data()["text"];

                                responseFinal = responseFinal.substring(0, responseFinal.length - 1); 
                                response_receiver = ",{\"author\":{\"firstName\":\"$firstName_receiver\",\"id\":\"$id_receiver\",\"imageUrl\":\"$imageUrl_receiver\"},\"createdAt\":$date,\"id\":\"$messageId\",\"status\":\"$status\",\"text\":\"$text\",\"type\":\"$type\"}]";
                              }
                              else if(result.data()["type"] == "image"){

                                uri = result.data()["uri"];
                                name = result.data()["name"];
                                height = result.data()["height"];
                                width = result.data()["width"];
                                size = result.data()["size"];

                                responseFinal = responseFinal.substring(0, responseFinal.length - 1); 
                                response_receiver = ",{\"author\":{\"firstName\":\"$firstName_receiver\",\"id\":\"$id_receiver\",\"imageUrl\":\"$imageUrl_receiver\"},\"createdAt\":$date,\"height\":$height,\"id\":\"$messageId\",\"name\":\"$name\",\"size\":$size,\"status\":\"$status\",\"type\":\"$type\",\"uri\":\"$uri\",\"width\":$width}]";
                              }
                            }
                            else{

                              if(result.data()["type"] == "text"){

                                text = result.data()["text"];

                                response_receiver = "[{\"author\":{\"firstName\":\"$firstName_receiver\",\"id\":\"$id_receiver\",\"imageUrl\":\"$imageUrl_receiver\"},\"createdAt\":$date,\"id\":\"$messageId\",\"status\":\"$status\",\"text\":\"$text\",\"type\":\"$type\"}]";
                              }
                              else if(result.data()["type"] == "image"){

                                uri = result.data()["uri"];
                                name = result.data()["name"];
                                height = result.data()["height"];
                                width = result.data()["width"];
                                size = result.data()["size"];

                                response_receiver = "[{\"author\":{\"firstName\":\"$firstName_receiver\",\"id\":\"$id_receiver\",\"imageUrl\":\"$imageUrl_receiver\"},\"createdAt\":$date,\"height\":$height,\"id\":\"$messageId\",\"name\":\"$name\",\"size\":$size,\"status\":\"$status\",\"type\":\"$type\",\"uri\":\"$uri\",\"width\":$width}]";
                              }
                            }

                            responseFinal+=response_receiver;
                          }
                      });
              });
    });

    log(responseFinal);

    final messages = (jsonDecode(responseFinal) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }

  Future sendNotification(title, body, date, img1, myFunc, id, topic) async {

      final response = await Messaging.sendToAll(
          title: title,
          body: body,
          date: date,
          img1: img1,
          myFunc: myFunc,
          id: id,
          topic: topic,
      );

      if(response.statusCode != 200) {

        log("Error while sending notif");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Colors.black,
                  Colors.black87,
                ])          
          ),        
        ),    
        title: const Text('Emma'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert),
            //tooltip: 'Show Snackbar',
            onPressed: () {
             

            },
          ),
        ],
        leading: 
          IconButton(
            icon: const Icon(Icons.arrow_back),
            //tooltip: 'Show Snackbar',
            onPressed: () {
             
              Navigator.pop(context);
            },
          ),
      ),
      body: SafeArea(
        bottom: false,
        child: Chat(
          messages: _messages,
          onAttachmentPressed: _handleAtachmentPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: (_handlePreviewDataFetched),
          onSendPressed: _handleSendPressed,
          user: _user,
          showUserAvatars: true,
          scrollPhysics: const ClampingScrollPhysics(),
        ),
      ),
    );
  }
}
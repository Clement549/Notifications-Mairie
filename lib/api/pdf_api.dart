import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // flutter run -d chrome --web-renderer html  // flutter build web --web-renderer html --release


class PDFApi{
  static Future<File> loadNetwork(String url) async{

    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    return _storeFile(url, bytes);
  }

  static Future<File> _storeFile(String url, List<int> bytes) async {

    final filename = basename(url);
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush:true);
    return file;
  }

  static Future<File?> pickFile() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

      if(result == null){
        return null;
      } 
      else{
        return File(result.paths.first!);
      }
  }

  static Future<Uint8List?> pickFileWeb() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

      if (result != null) {

        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = result.files.first.name;

        return fileBytes;
      }
      else{

         return null;
      }
  }

    static Future<File?> loadFirebase(String url) async {
      try{
        final refPDF = FirebaseStorage.instance.ref().child("pdf/"+"${url}.pdf");
        final bytes = await refPDF.getData();

        return _storeFile(url, bytes!);
      }
      catch(e){
        return null;
      }
    }

      static Future<String> uploadFirebase(String path, Uint8List bytes) async {

        var uuid = const Uuid();
        var name = uuid.v4();

        final ref = storage.FirebaseStorage.instance.ref()
          .child('pdf') // dossier
          .child('${name}.pdf'); // nom fichier

        if(!kIsWeb){

           final result = await ref.putFile(File(path));
           final fileUrl = await result.ref.getDownloadURL();
        }
        else{

            final result = await ref.putData(bytes);
            final fileUrl = await result.ref.getDownloadURL();
        }
        
        return name;
    }
}

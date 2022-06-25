import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_course/api/pdf_api.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


class PDFViewerPage extends StatefulWidget {

  final File file;

  const PDFViewerPage({
    Key? key,
    required this.file,
    }) : super(key:key);
    

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {

  @override
  Widget build(BuildContext context) {

    final name = basename("Prévisualisation"); //widget.file.path

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(100, 198, 214, 1),
                      Color.fromRGBO(0,152, 242, 1),
                    ],
                  ),
                  boxShadow: [
                    //background color of box
                    BoxShadow(
                      color: Color.fromRGBO(0, 50, 70, 1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 1.0, //extend the shadow
                      offset: Offset(
                        0, // Move to right 10  horizontally
                        0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
            ),
          title: Text(name),
          leading: Builder(
            builder: (BuildContext context2) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () { Navigator.pop(context); },
            );
          },
        ),
      ),
      body: Container(
        child: PDFView(
          filePath: widget.file.path,
          //swipeHorizontal: true,
          //pageSnap: false,
          autoSpacing: false,
        ),
      ),
    );
  }
}
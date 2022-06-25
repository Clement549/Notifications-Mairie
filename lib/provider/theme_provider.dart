

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{

  ThemeMode themeMode = ThemeMode.dark;

  bool get isDarkMode => themeMode == ThemeMode.dark;
}

class MyThemes{

  static final lightTheme = ThemeData(
    
    primarySwatch: Colors.blue,
    //primarySwatch: Colors.red,
    primaryColor: Colors.black,
    //colorScheme: const ColorScheme.light(),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blueAccent.withOpacity(1),
      selectionColor: Colors.blueAccent.withOpacity(.6),
      selectionHandleColor: Colors.blueAccent.withOpacity(1),
    )

  );


  static final darkTheme = ThemeData(

    //scaffoldBackgroundColor: Colors.grey.shade900,
    primarySwatch: Colors.blue,
    primaryColor: Colors.white,
    //colorScheme: const ColorScheme.dark(),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blueAccent.withOpacity(1),
      selectionColor: Colors.blueAccent.withOpacity(.6),
      selectionHandleColor: Colors.blueAccent.withOpacity(1),
    )

  );
}
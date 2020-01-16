import 'package:flutter/material.dart';

import 'demonew.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     home: new ImagePage(), //calling chat_screen_item.dart
    );
  }
}

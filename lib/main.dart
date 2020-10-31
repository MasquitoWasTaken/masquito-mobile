import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masquito',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Masquito'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();

  String _result = 'No image taken yet';

  void _onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
        maxWidth: null,
        maxHeight: null,
        imageQuality: null,
      );
      final bytes = File(pickedFile.path).readAsBytesSync();
      final encoded = base64Encode(bytes);
      String newDataUri = 'data:image/jpeg;base64,' + encoded;
      setState(() {
        _result = "Loading results";
      });
    } catch (e) {
      debugPrint("An image error has occuredr");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(_result),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onImageButtonPressed(ImageSource.camera);
        },
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.indigo[700],
      ),
    );
  }
}

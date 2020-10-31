import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masquito',
      theme: ThemeData(
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

class ConfidencePerClass {
  final String category;
  final double confidence;
  final charts.Color color;

  ConfidencePerClass(this.category, this.confidence, Color color)
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class _MyHomePageState extends State<MyHomePage> {
  final String _apiUrl = 'http://192.168.1.33:8080/mask';
  final ImagePicker _picker = ImagePicker();

  var _data;

  void _onImageButtonPressed(ImageSource source) async {
    final pickedFile = await _picker.getImage(
      source: source,
      maxWidth: null,
      maxHeight: null,
      imageQuality: null,
    );
    final bytes = File(pickedFile.path).readAsBytesSync();
    final encoded = base64Encode(bytes);
    String newDataUri = 'data:image/jpeg;base64,' + encoded;

    print("hi");
    Response res = await post(
      _apiUrl + "?image=" + newDataUri,
    );
    String body = res.body;
    this.setState(() {
      _data = jsonDecode(body);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      _data = {
        'map': 0.0,
        'improper': 0.0,
        'none': 0.0,
      };
    }

    List<ConfidencePerClass> data = [
      ConfidencePerClass(
          'mask', double.parse(_data['mask']) / 100, Colors.indigo[900]),
      ConfidencePerClass('improper', double.parse(_data['improper']) / 100,
          Colors.purple[900]),
      ConfidencePerClass(
          'none', double.parse(_data['none']) / 100, Colors.purple[700]),
    ];

    var series = [
      charts.Series(
        domainFn: (ConfidencePerClass confidenceData, _) =>
            confidenceData.category,
        measureFn: (ConfidencePerClass confidenceData, _) =>
            confidenceData.confidence,
        colorFn: (ConfidencePerClass confidenceData, _) => confidenceData.color,
        id: 'Confidence',
        data: data,
      ),
    ];

    var chart = charts.BarChart(
      series,
      animate: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: chart,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onImageButtonPressed(ImageSource.camera);
        },
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }
}

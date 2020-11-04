import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

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
  final String _apiUrl = 'http://javaman.net:8083/mask';
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic> _data = {
    'mask': '0.0',
    'improper': '0.0',
    'none': '0.0',
  };

  void _onImageButtonPressed(ImageSource source) async {
    this.setState(() {
      _data = {
        'mask': '0.0',
        'improper': '0.0',
        'none': '0.0',
      };
    });
    final pickedFile = await _picker.getImage(
      source: source,
      maxWidth: null,
      maxHeight: null,
      imageQuality: null,
    );
    final file = File(pickedFile.path);
    final bytes = file.readAsBytesSync();
    file.delete();
    final encoded = base64Encode(bytes);
    String newDataUri = 'data:image/jpeg;base64,' + encoded;

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
        'mask': '0.0',
        'improper': '0.0',
        'none': '0.0',
      };
    }

    List<ConfidencePerClass> data = [
      ConfidencePerClass(
          'Mask', double.parse(_data['mask']) / 100, Colors.indigo[900]),
      ConfidencePerClass('Improper', double.parse(_data['improper']) / 100,
          Colors.purple[900]),
      ConfidencePerClass(
          'None', double.parse(_data['none']) / 100, Colors.purple[700]),
    ];

    var series = [
      charts.Series(
        domainFn: (ConfidencePerClass confidenceData, _) =>
            confidenceData.category,
        measureFn: (ConfidencePerClass confidenceData, _) =>
            confidenceData.confidence,
        colorFn: (ConfidencePerClass confidenceData, _) => confidenceData.color,
        id: 'confidence',
        data: data,
      ),
    ];

    var chart = charts.BarChart(
      series,
      animate: true,
      behaviors: [
        charts.ChartTitle(
          'Confidence Scores',
          subTitle: 'Predicted by an AI model',
          innerPadding: 25,
        ),
      ],
    );

    return Scaffold(
      drawer: Drawer(
          child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Masquito",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 37,
                        color: Colors.white,
                      ),
                    ),
                    Image(
                      image:
                          AssetImage('assets/icon/icon_inverted_cropped.png'),
                      height: 75,
                      width: 75,
                      alignment: Alignment.topRight,
                    ),
                  ],
                ),
                Text(
                  "See if you're wearing your mask right",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text(
              "Source code (Github)",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            onTap: _redirectGithub,
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(
              "Note: zoom in on faces to increase accuracy",
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(
              "Note: back-facing cameras are more accurate than front-facing ones",
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(
              "Note: this app sends data to a server, but no images are stored",
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(
              "Note: the AI model behind this app is still being developed",
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
              ),
            ),
            onTap: () => {},
          ),
        ],
      )),
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

  _redirectGithub() async {
    const url = "https://github.com/MasquitoWasTaken";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

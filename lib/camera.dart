// Flutter code sample for material.Card.2
import 'dart:io';

import 'package:firebase_mlvision/firebase_mlvision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garbage Sorter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Garbage Sorter Camera'),
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

  File _imageFile;
  String _label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                color: Theme.of(context).primaryColor,
                onPressed: _selectFromGallery,
                child: Text("Select from Gallery"),
              ),
              RaisedButton(
                color: Theme.of(context).primaryColor,
                onPressed: _selectFromCamera,
                child: Text("Select from Camera"),
              ),
              SizedBox(
                height: 200,
                width: 300,
                child: Center(child: _imageFile == null ? Text("No Image Selected") : Image.file(_imageFile)),
              ),
              Center(child: Text(_label == null ? "No Label Found" : _label)),
            ],
          ),
        ),
    );
  }

  void _selectFromGallery() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    processImage(imageFile);
  }

  void _selectFromCamera() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    processImage(imageFile);
  }

  void processImage(File imageFile) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
    final VisionEdgeImageLabeler visionEdgeLabeler = FirebaseVision.instance.visionEdgeImageLabeler('waste', ModelLocation.Local);
    final List<VisionEdgeImageLabel> visionEdgeLabels = await visionEdgeLabeler.processImage(visionImage);

    String label = "Could not label image";
    if (visionEdgeLabels.length > 0) {
      visionEdgeLabels.reduce((current, next) => current.confidence > next.confidence ? current : next);
      label = visionEdgeLabels[0].text;
    }

    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _label = label;
      });
    }
  }
}
// Flutter code sample for material.Card.2
import 'dart:io';

import 'package:firebase_mlvision/firebase_mlvision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'Garbage Sorter';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: ImageSelectorWidget(),
      ),
    );
  }
}

class ImageSelectorWidget extends StatefulWidget {
  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelectorWidget> {

  File _imageFile;
  String _label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          RaisedButton(
            color: Theme.of(context).primaryColor,
            onPressed: _selectImageFromGallery,
            child: Text("Select from Gallery"),
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            onPressed: _selectImageFromCamera,
            child: Text("Select from Camera"),
          ),
          SizedBox(
            height: 200,
            width: 300,
            child: Center(child: _imageFile == null ? Text("No Image Selected") : Image.file(_imageFile)),
          ),
          Center(child: _label == null ? Text("No Label Found") : Text(_label),),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _selectImageFromGallery() async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    processImage(imageFile);
  }

  void _selectImageFromCamera() async {
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
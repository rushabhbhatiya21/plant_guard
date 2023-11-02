import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:plant_guard/pages/preview_screen.dart';
import 'camera_screen.dart'; // Import the camera_screen.dart file

class UploadGalleryScreen extends StatefulWidget {
  @override
  _UploadGalleryScreenState createState() => _UploadGalleryScreenState();
}

class _UploadGalleryScreenState extends State<UploadGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _getImageFromGallery() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> uploadImage(File file, String filename, context) async {
    final request = http.MultipartRequest("POST", Uri.http("192.168.0.104:5000", "/upload"));

    request.files.add(
      http.MultipartFile(
        'files',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: filename,
      ),
    );

    final headers = {"Content-type":"multipart/form-data"};
    request.headers.addAll(headers);

    var res = await request.send();
    var response = await http.Response.fromStream(res);
    String base64t = response.body;
    Uint8List decodedbytes = base64.decode(base64t);

    Image image = Image.memory(decodedbytes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewScreen(
          imgPath: image,
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      // Create an instance of CameraScreen to access the uploadImage function
      CameraScreen cameraScreen = CameraScreen();
      final path = _image!.path;
      uploadImage(File(path), path, context);
    } else {
      print('No image to upload.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload from Gallery'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null)
              Image.file(_image!, width: 200, height: 200),
            ElevatedButton(
              onPressed: _getImageFromGallery,
              child: Text('Pick an image from gallery'),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}

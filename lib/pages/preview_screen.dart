import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreviewScreen extends StatefulWidget {
  final Image imgPath;

  PreviewScreen({required this.imgPath});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  String predictedDisease = 'Predicted Disease: Loading...';
  Image? selectedImage;

  void _clearSelectedImage() {
    setState(() {
      selectedImage = null;
    });
    Navigator.of(context).pop(); // Close the current screen and go back
  }

  Future<void> predictDisease() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.104:5000/predict')); // Replace with your server IP and port

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('predicted_disease')) {
          setState(() {
            predictedDisease = 'Predicted Disease: ${data['predicted_disease']}';
            selectedImage = widget.imgPath; // Set the selected image here
          });

          // Show a dialog with the predicted disease
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Predicted Disease'),
                content: Text('The predicted disease is: ${data['predicted_disease']}'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _clearSelectedImage(); // Clear the selected image
                    },
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            predictedDisease = 'Prediction not available';
          });
        }
      } else {
        throw Exception('Failed to load prediction');
      }
    } catch (e) {
      setState(() {
        predictedDisease = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: selectedImage ?? widget.imgPath, // Use selectedImage if available, otherwise use the original image
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 60.0,
              color: Colors.black,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        predictDisease();
                      },
                      child: const Text('Get Disease Prediction'),
                    ),
                    const SizedBox(width: 16.0),
                    Text(predictedDisease, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

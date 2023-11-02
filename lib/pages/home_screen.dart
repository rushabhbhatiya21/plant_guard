import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add HTTP package
import 'package:plant_guard/auth/login_page.dart';
import 'package:plant_guard/pages/upload_gallery.dart';

import 'camera_screen.dart';
import 'view_images.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late CameraController _controller;
  // late Future<void> _initializeControllerFuture;
  // CameraLensDirection _currentCamera = CameraLensDirection.front;
  // bool _cameraOpen = false;
  //
  // _HomeScreenState() {
  //   _initializeControllerFuture = _initializeCamera();
  // }
  //
  // Future<void> _initializeCamera() async {
  //   // ... Your camera initialization code ...
  //   try {
  //     final cameras = await availableCameras();
  //     final selectedCamera = cameras.firstWhere(
  //           (camera) => camera.lensDirection == _currentCamera,
  //       orElse: () => cameras.first,
  //     );
  //
  //     _controller = CameraController(
  //       selectedCamera,
  //       ResolutionPreset.medium,
  //     );
  //
  //     await _controller.initialize();
  //
  //     // Load the TFLite model here
  //     await loadModel(); // You can provide the path to your model as an argument
  //
  //     setState(() {}); // Trigger a rebuild after camera initialization
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error initializing camera: $e');
  //     }
  //   }
  // }

  // Define a list to store image URLs
  List<String> imageUrls = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch image URLs when the widget initializes
    fetchImageUrls();
  }
//fetch url not working currently
  Future<void> fetchImageUrls() async {
    // Make an HTTP GET request to fetch image URLs
    final response = await http.get(Uri.parse('http://192.168.0.104:5000/get_all'));

    if (response.statusCode == 200) {
      // Parse the response JSON to get a list of image URLs
      final List<dynamic> data = json.decode(response.body);
      final List<String> urls = data.map((item) => item['url'].toString()).toList();

      setState(() {
        imageUrls = urls;
      });
    } else {
      // Handle errors or empty responses
      print('Failed to load image URLs');
    }
  }

  // void _openCamera() {
  //   setState(() {
  //     _cameraOpen = true;
  //   });
  // }
  //
  // void _toggleCamera() {
  //   setState(() {
  //     _cameraOpen = !_cameraOpen;
  //   });
  // }
  //
  // void _toggleCameraDirection() {
  //   setState(() {
  //     _currentCamera = _currentCamera == CameraLensDirection.front
  //         ? CameraLensDirection.back
  //         : CameraLensDirection.front;
  //     _initializeCamera();
  //   });
  // }
  //
  // Future<void> loadModel() async {
  //   try {
  //     // const modelPath = ; // Replace with your model's path
  //     await Tflite.loadModel(
  //       model: 'assets/litemodel.tflite',
  //       labels: 'assets/labels.txt', // Replace with your labels file path
  //     );
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error loading TFLite model: $e');
  //     }
  //   }
  // }
  //
  // Future<void> _captureAndProcessImage() async {
  //   try {
  //     final XFile imageFile = await _controller.takePicture();
  //     final imageBytes = await imageFile.readAsBytes(); // Read image bytes
  //
  //     // Preprocess the image here based on your model's requirements
  //     final preprocessedImageBytes = await preprocessImage(imageBytes);
  //
  //     // Run inference on the preprocessed image
  //     List<dynamic>? results = await Tflite.runModelOnBinary(
  //       binary: preprocessedImageBytes,
  //     );
  //
  //     if (results != null && results.isNotEmpty) {
  //       final result = results[0];
  //       final label = result['label'];
  //       final confidence = result['confidence'];
  //
  //       // Display the results in your app's UI
  //       // For example, show label and confidence score in a widget
  //       if (kDebugMode) {
  //         print('Label: $label, Confidence: $confidence');
  //       }
  //     } else {
  //       // Handle the case when no results are returned
  //       if (kDebugMode) {
  //         print('No results found.');
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error capturing and processing image: $e');
  //     }
  //   }
  // }
  //
  // Future<Uint8List> preprocessImage(Uint8List inputImage) async {
  //   try {
  //     // Decode the input image
  //     img.Image? image = img.decodeImage(inputImage);
  //
  //     // Resize the image to 224x224 pixels
  //     image = img.copyResize(image!, width: 224, height: 224);
  //
  //     // Convert pixel values to floating-point in the range [0, 1]
  //     for (var y = 0; y < image.height; y++) {
  //       for (var x = 0; x < image.width; x++) {
  //         final pixel = image.getPixel(x, y);
  //         final red = img.getRed(pixel);
  //         final green = img.getGreen(pixel);
  //         final blue = img.getBlue(pixel);
  //         final alpha = img.getAlpha(pixel);
  //
  //         // Normalize pixel values by dividing by 255
  //         image.setPixel(x, y, img.getColor((red / 255.0).clamp(0.0, 1.0) as int, (green / 255.0).clamp(0.0, 1.0) as int, (blue / 255.0).clamp(0.0, 1.0) as int, alpha));
  //       }
  //     }
  //
  //     // Encode the preprocessed image back to Uint8List
  //     final preprocessedImage = Uint8List.fromList(img.encodePng(image));
  //
  //     return preprocessedImage;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Error preprocessing image: $e');
  //     }
  //     return Uint8List(0); // Return an empty Uint8List in case of an error
  //   }
  // }

   Future<void> _openCamera(BuildContext context) async {
     // Navigate to the CameraScreen when the camera button is pressed
     Navigator.of(context).push(MaterialPageRoute(builder: (context) => CameraScreen()));
   }

   Future<void> _uploadFromGallery(BuildContext context) async {
    // Navigate to the UploadGalleryScreen when the gallery button is pressed
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => UploadGalleryScreen()));
  }

  // Add a button to navigate to AllImagesScreen
  Future<void> _viewAllImages(BuildContext context) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ViewImagesScreen(imageUrls: imageUrls),
    ));
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      // Handle sign-out errors if any
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

//    @override
//    Widget build(BuildContext context) {
//      return Scaffold(
//        appBar: AppBar(
//          title: const Text('Home Screen'),
//          actions: [
//            PopupMenuButton<String>(
//              onSelected: (value) {
//                if (value == 'logout') {
//                  _signOut(context); // Call the sign-out function
//                }
//              },
//              itemBuilder: (context) => [
//                const PopupMenuItem(
//                  value: 'logout',
//                  child: Text('Logout'),
//                ),
//              ],
//            ),
//          ],
//        ),
//        body: Center(
//          child: Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: [
//              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: [
//                  ElevatedButton.icon(
//                    onPressed: () {
//                      _openCamera(context);
//                    },
//                    icon: Icon(Icons.camera_alt),
//                    label: Text('Open Camera'),
//                  ),
//                ],
//              ),
//              SizedBox(height: 16), // Add some spacing between the buttons
//              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: [
//                  ElevatedButton.icon(
//                    onPressed: () {
//                      _uploadFromGallery(context);
//                    },
//                    icon: Icon(Icons.photo),
//                    label: Text('Upload from Gallery'),
//                  ),
//                ],
//              ),
//            ],
//          ),
//        ),
//      );
//    }
// }

///////////////working//////////////////////
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home Screen'),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'logout') {
//                 _signOut(context); // Call the sign-out function
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'logout',
//                 child: Text('Logout'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     _openCamera(context);
//                   },
//                   icon: Icon(Icons.camera_alt),
//                   label: Text('Open Camera'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16), // Add some spacing between the buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     _uploadFromGallery(context);
//                   },
//                   icon: Icon(Icons.photo),
//                   label: Text('Upload from Gallery'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16), // Add spacing below the "Upload from Gallery" button
//             // Display images using ListView.builder
//             Expanded(
//               child: ListView.builder(
//                 itemCount: imageUrls.length,
//                 itemBuilder: (context, index) {
//                   return Image.network(imageUrls[index]);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _signOut(context); // Call the sign-out function
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the elements
          children: [
            // Add spacing at the top
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _openCamera(context);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Open Camera'),
                ),
              ],
            ),
            const SizedBox(height: 16), // Add some spacing between the buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _uploadFromGallery(context);
                  },
                  icon: const Icon(Icons.photo),
                  label: const Text('Upload from Gallery'),
                ),
              ],
            ),
            // Add spacing between the "Upload from Gallery" button and "View All Images" button
            const SizedBox(height: 16),

            // Add a button to navigate to AllImagesScreen
            ElevatedButton(
              onPressed: () {
                _viewAllImages(context);
              },
              child: const Text('View All Images'),
            ),
          ],
        ),
      ),
    );
  }
}
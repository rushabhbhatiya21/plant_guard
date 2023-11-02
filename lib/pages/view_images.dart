import 'package:flutter/material.dart';

class ViewImagesScreen extends StatefulWidget {
  late final List<String> imageUrls;

  ViewImagesScreen({required this.imageUrls});

  @override
  _ViewImagesScreenState createState() => _ViewImagesScreenState();
}

class _ViewImagesScreenState extends State<ViewImagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Images'),
      ),
      body: ListView.builder(
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(widget.imageUrls[index]);
        },
      ),
    );
  }
}

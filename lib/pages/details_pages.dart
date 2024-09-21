import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:crop_image/crop_image.dart';

import 'package:permission_handler/permission_handler.dart';

import 'dart:ui' as ui;

class DetailsPages extends StatefulWidget {
  final String url,id,name,box_coutn,capiton;

  const DetailsPages({Key? key, required this.url,required this.name,required this.id,required this.box_coutn,required this.capiton}) : super(key: key);

  @override
  State<DetailsPages> createState() => _DetailsPagesState();
}

class _DetailsPagesState extends State<DetailsPages> {
  final controller = CropController(
    aspectRatio: 0.7,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Crop Image"),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: Column(

          children:[
            Text("ID: ${widget.id}"),
            Text("Name: ${widget.name}"),
            Text("box count:${widget.box_coutn}"),
            Text("Caption: ${widget.capiton}"),

            CropImage(
            controller: controller,
            image: Image.network('${widget.url}'),
            paddingSize: 25.0,
            alwaysMove: true,
            minimumImageSize: 500,
            maximumImageSize: 500,
          ),
            ]
        ),
        bottomNavigationBar: _buildButtons(),
      );

  Widget _buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.rotation = CropRotation.up;
              controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              controller.aspectRatio = 1.0;
            },
          ),
          IconButton(
            icon: const Icon(Icons.aspect_ratio),
            onPressed: _aspectRatios,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
            onPressed: _rotateLeft,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
            onPressed: _rotateRight,
          ),
          TextButton(
            onPressed: _finished,
            child: const Text('Done'),
          ),
        ],
      );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            // special case: no aspect ratio
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('free'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value == -1 ? null : value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<void> _finished() async {
    final image = await controller.croppedImage();
    if (mounted) {
      await showDialog<bool>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(6.0),
            titlePadding: const EdgeInsets.all(8.0),
            title: const Text('Cropped image'),
            children: [
              Text('relative: ${controller.crop}'),
              Text('pixels: ${controller.cropSize}'),
              const SizedBox(height: 5),
              image,
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () async {
                  _saveCroppedImage();
                  Navigator.pop(context);
                },
                child: Text('Save Image in your gallery'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _saveCroppedImage() async {
    // Request storage permissions
    await [Permission.storage].request();

    // Crop the image
    final croppedImage = await controller.croppedBitmap();
    if (croppedImage == null) return;

    // Convert the cropped image to bytes
    final bytes = await _imageToByteData(croppedImage);

    // Save image to gallery
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));

    // Show confirmation
    if (result['isSuccess']) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image Saved to Gallery!")));
    }
  }

  Future<List<int>> _imageToByteData(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

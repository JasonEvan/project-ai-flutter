import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isImageAvailable = false;
  bool _isDetecting = false;
  final uri = 'https://d0n8p861-5000.asse.devtunnels.ms/predict';

  // Make a function to open camera
  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    // if image is not null, set the image to the _image variable
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _isImageAvailable = true;
      });
    }
  }

  // Make a function to detect image
  Future<void> _detectImage() async {
    if (_image == null) return;

    setState(() {
      _isDetecting = true;
    });

    // request to the API with HTTP Request using POST method
    // while requesting, send the image too
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(uri),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image!.path,
      ));

      // get response from the API
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      // if the response status is OK then show the prediction
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Image Detection"),
            content: Text("Prediction: ${jsonResponse['data']}"),
          ),
        );
      // else, show the error message
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text("An error occurred: ${jsonResponse['error']}"),
          ),
        );
      }
    } catch (e) {
      // show error message if there is an error from server
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("An error occurred: $e"),
        ),
      );
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  // Make a camera page view
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xffAFFAC4), Color(0xff00543B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if image is not null, show the image,
            // else, show message that the image is not captured yet
            _image != null
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Image.file(
                      _image!,
                    ))
                : const Text('No image captured.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openCamera,
              child: const Text('Open Camera'),
            ),
            const SizedBox(
              height: 5,
            ),
            // deactivate button if image is still null or in a proccess of detecting image
            // on pressed, run the _detectImage function
            ElevatedButton(
                onPressed:
                    _isImageAvailable && !_isDetecting ? _detectImage : null,
                child: const Text("Detect Image"))
          ],
        ),
      ),
    );
  }
}

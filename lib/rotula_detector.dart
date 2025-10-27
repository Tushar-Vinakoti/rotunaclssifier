import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class RotulaDetector extends StatefulWidget {
  const RotulaDetector({super.key});

  @override
  State<RotulaDetector> createState() => _RotulaDetectorState();
}

class _RotulaDetectorState extends State<RotulaDetector> {
  File? _image;
  final picker = ImagePicker();
  String? _prediction;
  final apiKey = 'AIzaSyCnMBg2xIJHZ7ezj9jnbMXEpT4yyW7lkJc';

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _prediction = 'Detecting...';
      });
      _runGemini(_image!);
    }
  }

  Future<void> _runGemini(File image) async {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final prompt = TextPart(
        'Is this a Rotula aquatica plant? Answer with only \'Rotula aquatica\' or \'Other\'.');
    final imageBytes = await image.readAsBytes();
    final dataPart = DataPart('image/jpeg', imageBytes);

    final response = await model.generateContent([
      Content.multi([
        prompt,
        dataPart,
      ])
    ]);

    setState(() {
      _prediction = response.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotula Detector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text('No image selected.')
                : Image.file(_image!),
            const SizedBox(height: 20),
            _prediction != null
                ? Text(
                    'Prediction: $_prediction',
                    style: const TextStyle(fontSize: 20),
                  )
                : Container(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            tooltip: 'Pick Image from Gallery',
            child: const Icon(Icons.photo_library),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => _pickImage(ImageSource.camera),
            tooltip: 'Take a Photo',
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}

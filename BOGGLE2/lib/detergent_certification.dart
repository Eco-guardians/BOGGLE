import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:boggle/cleanser_certification.dart';
import 'model.dart';

class Detergent extends StatefulWidget {
  final String title;

  const Detergent({super.key, required this.title});

  @override
  State<Detergent> createState() => _DetergentState();
}

class _DetergentState extends State<Detergent> {
  String scannedText = '';
  File? imageFile;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      getRecognizedText(pickedFile);
    }
  }

  void getRecognizedText(XFile image) async {
    try {
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);
      RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      scannedText = recognizedText.text.replaceAll('\n', ' ');
      setState(() {});

      await textRecognizer.close();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Textcertification(
            recognizedText: scannedText,
            imageFile: imageFile!,
          ),
        ),
      ).then((result) {
        if (result != null && result is Certification) {
          Navigator.pop(context, result); // result를 다시 상위 페이지로 전달
        }
      });
    } catch (e) {
      print("Error recognizing text: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '세제 인증',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 35),
              const Text(
                '정확한 세제 인증을 위해 사진을 준비해 주세요.\n아래의 등록하기 버튼을 눌러 사진을 불러와주세요.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset(
                  'image/cleanserocr.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                '사진을 등록하면, 위의 그림과 같이 텍스트를 인식하여\n자동으로 세제의 이름이 입력됩니다.',
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 196, 42, 250),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '등록하기',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
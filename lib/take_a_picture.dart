import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'cleanser_certification.dart';

class TakeAPicture extends StatefulWidget {
  @override
  _TakeAPictureState createState() => _TakeAPictureState();
}

class _TakeAPictureState extends State<TakeAPicture> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.high);

    _initializeControllerFuture = _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CleanserCertification(
            recognizedText: '인식된 텍스트', // 필요한 경우 인식된 텍스트를 여기에 추가
            imageFile: File(image.path),
          ),
        ),
      );
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CleanserCertification(
            recognizedText: '인식된 텍스트', // 필요한 경우 인식된 텍스트를 여기에 추가
            imageFile: File(pickedFile.path),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          '세제 인증',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.purple),
            onPressed: () {
              Navigator.of(context).pop(); // 이전 화면으로 돌아가기
            },
          ),
        ],
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller!), // 카메라 프리뷰
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 5),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 촬영 버튼과 갤러리 버튼의 간격을 띄웁니다.
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_album, color: Colors.grey),
                            iconSize: 50,
                            onPressed: _pickImageFromGallery, // 갤러리에서 이미지 가져오기
                          ),
                          const Text(
                            '갤러리',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _takePicture, // 사진 촬영
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 196, 42, 250),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

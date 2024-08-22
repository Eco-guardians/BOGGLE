import 'dart:io';
import 'package:flutter/material.dart';
import 'model.dart';

class Textcertification extends StatefulWidget {
  final String recognizedText;
  final File imageFile;

  const Textcertification({Key? key, required this.recognizedText, required this.imageFile}) : super(key: key);

  @override
  _TextcertificationState createState() => _TextcertificationState();
}

class _TextcertificationState extends State<Textcertification> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.recognizedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text('인증 되었습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 대화 상자를 닫습니다.
                final String currentDate = DateTime.now().toIso8601String().split('T').first; // 시간 제외
                Navigator.pop(
                  context,
                  Certification(
                    _textController.text,
                    '인증완료',
                    currentDate,
                    widget.imageFile,
                  ),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬로 설정
            children: [
              const SizedBox(height: 45),
              const Text(
                '세제 인증을 시작합니다.\n아래의 텍스트가 정확한지 확인해주세요.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.left, // 텍스트를 왼쪽 정렬로 설정
              ),
              const SizedBox(height: 36),
              const Text(
                '인식한 세제 이름',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                textAlign: TextAlign.left, // 텍스트를 왼쪽 정렬로 설정
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _textController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '세제의 이름과 동일하지 않으면 포인트를 받을 수 없습니다. 수정이 필요한 경우 수정하여 주세요.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.left, // 텍스트를 왼쪽 정렬로 설정
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: _showDialog,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color.fromARGB(255, 196, 42, 250),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '인증하기',
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
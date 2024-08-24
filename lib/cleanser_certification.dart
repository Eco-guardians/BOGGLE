import 'dart:io';
import 'package:boggle/receipt_certification.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CleanserCertification extends StatefulWidget {
  final String recognizedText;
  final File imageFile;

  const CleanserCertification({
    Key? key,
    required this.recognizedText,
    required this.imageFile,
  }) : super(key: key);

  @override
  _CleanserCertificationState createState() => _CleanserCertificationState();
}

class _CleanserCertificationState extends State<CleanserCertification> {
  bool isEcoMarkCertified = false; // 친환경 세제 마크 인증 초기값: 인증 안됨
  bool isReceiptUploaded = false; // 영수증 첨부 여부
  File? receiptImage; // 첨부한 영수증 이미지
  List<dynamic>? detectionResults; // 객체 탐지 결과를 저장할 리스트

  @override
  void initState() {
    super.initState();
    _detectObjects();  // 객체 탐지를 초기화 시점에 호출
  }

  // 현재 날짜를 가져와서 'yyyy년 MM월 dd일' 형식으로 포맷팅
  String getCurrentDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy년 MM월 dd일');
    return formatter.format(now);
  }

  // 객체 탐지 API 호출 메서드
  Future<void> _detectObjects() async {
    try {
      final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:8000/detect/')  // Django 서버 URL로 교체
      );

      // 이미지 파일을 multipart 형식으로 추가
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        widget.imageFile.path,
      ));

      // 서버에 요청 보내기
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        setState(() {
          detectionResults = json.decode(responseBody);  // JSON 파싱하여 결과 저장

          // 결과를 바탕으로 친환경 세제 마크가 감지되었는지 판단
          isEcoMarkCertified = _checkEcoMarkCertification(detectionResults!);
        });
      } else {
        print('Failed to detect objects. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during detection: $e');
    }
  }

  // 객체 탐지 결과를 바탕으로 친환경 세제 마크가 감지되었는지 판단하는 메서드
  bool _checkEcoMarkCertification(List<dynamic> results) {
    for (var result in results) {
      if (result['name'] == 'eco_mark') {  // 친환경 세제 마크 라벨을 'eco_mark'라고 가정
        return true;
      }
    }
    return false;
  }

  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isReceiptUploaded = true;
        receiptImage = File(pickedFile.path);
      });

      // 영수증 인증 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptCertification(
            cleanserImage: widget.imageFile,
            receiptImage: receiptImage!,
          ),
        ),
      );
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                getCurrentDate(), // 현재 날짜를 표시
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Image.file(
                widget.imageFile,
                height: 150,
              ),
              const SizedBox(height: 20),
              detectionResults == null
                  ? CircularProgressIndicator()  // 결과를 기다리는 동안 로딩 표시
                  : Column(
                children: detectionResults!.map((result) {
                  double confidence = result['confidence'] * 100;
                  print("Confidence value (original): ${result['confidence']}");
                  print("Confidence value (scaled): ${confidence}");
                  return Text(
                    "Detected: ${result['name']}, Confidence: ${confidence.toStringAsFixed(2)}%",
                    style: TextStyle(fontSize: 14),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                '친환경 세제 마크 인증이 완료되었습니다. 인증 절차에 따라 추가적으로 영수증 사진을 첨부해주세요.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CheckboxListTile(
                title: const Text('친환경 세제 마크 인증 완료'),
                value: isEcoMarkCertified,
                onChanged: (bool? value) {
                  setState(() {
                    isEcoMarkCertified = value ?? false;
                  });
                },
                activeColor: Color.fromARGB(255, 196, 42, 250),
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                title: const Text('영수증 첨부'),
                value: isReceiptUploaded,
                onChanged: (bool? value) {
                  setState(() {
                    isReceiptUploaded = value ?? false;
                  });
                },
                activeColor: Color.fromARGB(255, 196, 42, 250),
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickReceiptImage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Color.fromARGB(255, 196, 42, 250),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '영수증 등록하기',
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

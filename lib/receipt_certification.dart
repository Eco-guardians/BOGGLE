import 'dart:io';
import 'package:flutter/material.dart';
import 'model.dart';
import 'cleanser_certificationList.dart'; // CleanserCertificationList를 임포트합니다.

class ReceiptCertification extends StatefulWidget {
  final File cleanserImage;
  final File receiptImage;

  const ReceiptCertification({
    Key? key,
    required this.cleanserImage,
    required this.receiptImage,
  }) : super(key: key);

  @override
  _ReceiptCertificationState createState() => _ReceiptCertificationState();
}

class _ReceiptCertificationState extends State<ReceiptCertification> {
  bool isEcoMarkCertified = true; // 친환경 세제 마크 인증 완료
  bool isReceiptUploaded = true; // 영수증 첨부 완료

  void _completeCertification() {
    if (isEcoMarkCertified && isReceiptUploaded) {
      final certification = Certification(
        '인증완료',
        DateTime.now().toString().split(' ')[0], // 현재 날짜
        widget.cleanserImage,
        widget.receiptImage, // 영수증 이미지 추가
      );

      // 팝업 알림 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('인증 완료'),
            content: const Text('인증되었습니다.\n25포인트가 지급되었습니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.pop(context); // 팝업 닫기
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CleanserCertificationList(
                        newCertification: certification,
                        userId: 'userId', // 실제 사용자 ID로 대체해야 함
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    } else {
      // 모든 항목이 체크되지 않은 경우 경고 팝업 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('오류'),
            content: const Text('모든 항목을 체크해주세요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                },
              ),
            ],
          );
        },
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
              Image.file(
                widget.cleanserImage,
                height: 150,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Image.file(
                widget.receiptImage,
                height: 200,
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _completeCertification,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Color.fromARGB(255, 196, 42, 250),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '세제 인증하기',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

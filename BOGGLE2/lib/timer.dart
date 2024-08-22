import 'package:flutter/material.dart';

class Timer extends StatelessWidget {
  const Timer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '타이머',
              style: TextStyle(
                fontSize: 24, // 원하는 크기로 조절하세요
                fontWeight: FontWeight.bold,
                color: Colors.black, // 원하는 색상으로 조절하세요
              ),
            ),
            SizedBox(height: 20), // 텍스트와 버튼 사이의 간격 조절
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text("돌아가기"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:boggle/change_fpw.dart';
import 'package:http/http.dart' as http;

class FindPWPage extends StatefulWidget {
  const FindPWPage({Key? key}) : super(key: key);

  @override
  _FindPWPageState createState() => _FindPWPageState();
}

class _FindPWPageState extends State<FindPWPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _findPassword() async {
  final String id = _idController.text;
  final String email = _emailController.text;
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/find_user_password/'), // Django의 API 엔드포인트
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'id': id, 'email': email}),
  );

  if (response.statusCode == 200) {
    // 일치하는 정보가 있으면 비밀번호 변경 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangeFPW(userId: id)), // Pass userId argument
    );
  } else {
    // 일치하는 정보가 없으면 메시지 출력
    final responseBody = jsonDecode(utf8.decode(response.bodyBytes, allowMalformed: true));
    _showDialog('PW 찾기 실패', responseBody['message']);
  }
}


  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("PW 찾기"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Text(
                    '아이디',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),  
            ),
            const SizedBox(height: 5),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    filled: true, 
                    fillColor: Colors.white,     
                    border: OutlineInputBorder(),
                    hintText: '아이디를 입력해주세요',
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Text(
                    '이메일',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),  
            ),
            const SizedBox(height: 5),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    filled: true, 
                    fillColor: Colors.white,  
                    border: OutlineInputBorder(),
                    hintText: '이메일을 입력해주세요',
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC42AFA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),),
                  onPressed: _findPassword,
                  child: const Text('PW 찾기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

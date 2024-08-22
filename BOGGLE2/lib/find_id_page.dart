import 'dart:convert';
import 'package:boggle/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FindIDPage extends StatefulWidget {
  const FindIDPage({Key? key}) : super(key: key);

  @override
  _FindIDPageState createState() => _FindIDPageState();
}

class _FindIDPageState extends State<FindIDPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _foundID;

  bool _isValidEmail(String email) {
    // 이메일 형식을 검사하는 정규 표현식
    final RegExp emailRegExp =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Future<void> _findID() async {
  final String email = _emailController.text;

  if (!_isValidEmail(email)) {
    _showDialog('이메일 입력', '올바른 이메일 주소를 입력하세요.\n(예: exam123@example.com)');
    return;
  }

  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/find_user_id/'), // Django의 API 엔드포인트
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'email': email}),
  );

  if (response.statusCode == 200) {
    final responseBody = jsonDecode(response.body);
    setState(() {
      _foundID = responseBody['id'];
    });
    _showDialog('ID 찾기 성공', 'ID: $_foundID');
  } else {
    _showDialog('ID 찾기 실패', '일치하는 가입정보가 없습니다.');
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
        title: const Text('ID 찾기'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  ),
                ),
                onPressed: _findID,
                child: const Text('ID 찾기'),
              ),
            ),
            SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return const LoginPage();
                        }),
                      );
                    },
                    child: const Text("로그인 하러가기",
                      style: TextStyle(
                        fontSize: 15,
                      ),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

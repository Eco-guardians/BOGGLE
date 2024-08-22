import 'dart:convert';
import 'package:boggle/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChangeFPW extends StatefulWidget {
  final String userId; // 사용자 ID 추가

  const ChangeFPW({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangeFPW> createState() => _ChangeFPWState();
}

class _ChangeFPWState extends State<ChangeFPW> {
  final TextEditingController _idController = TextEditingController(); // 아이디 입력 필드 추가
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPWController = TextEditingController();
  bool _showPassword = false; // 비밀번호 보이기 여부
  bool _showConfirmPassword = false; // 비밀번호 확인 보이기 여부

  @override
  void initState() {
    super.initState();
    _idController.text = widget.userId; // 아이디 입력 필드에 초기 값 설정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PW 재설정'),
        centerTitle: false,
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
                controller: _idController, // 아이디 입력 필드
                readOnly: true, // 읽기 전용으로 설정하여 수정 불가능하게 함
                decoration: const InputDecoration(
                  filled: true, 
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Text(
                    '새로운 비밀번호',
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
                controller: _pwController,
                obscureText: !_showPassword, // 비밀번호 가리기/보이기 제어
                decoration:  InputDecoration(
                  filled: true, 
                  fillColor: Colors.white,       
                  border: const OutlineInputBorder(),
                  hintText: '새로운 비밀번호를 입력해주세요',
                  contentPadding: const EdgeInsets.all(8),
                  suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword; // 상태 변경
                    });
                  },
                ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(
              width: 300,
              child: Padding(
                  padding: EdgeInsets.only(left: 0.0),
                  child: Text(
                    '새로운 비밀번호 확인',
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
                controller: _confirmPWController,
                obscureText: !_showConfirmPassword, // 비밀번호 가리기/보이기 제어
                decoration: InputDecoration(
                  filled: true, 
                  fillColor: Colors.white,       
                  border: const OutlineInputBorder(),
                  hintText: '새로운 비밀번호를 한번 더 입력해주세요',
                  contentPadding: const EdgeInsets.all(8),
                  suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword; // 상태 변경
                    });
                  },
                ),
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
                onPressed: _updatePW,
                child: const Text('비밀번호 변경하기'),
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

  Future<void> _updatePW() async {
    final String newPassword = _pwController.text;
    final String confirmPassword = _confirmPWController.text;
    final String userId = widget.userId;

    if (newPassword != confirmPassword) {
      _showDialog('비밀번호 변경 실패', '새로운 비밀번호가 일치하지 않습니다.');
      return;
    }

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/update_password/'), // Django의 API 엔드포인트
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'id': userId, 'password': newPassword}),
    );

    if (response.statusCode == 200) {
      _showDialog('비밀번호 변경 성공', '비밀번호가 성공적으로 변경되었습니다.');
    } else {
      final responseBody = jsonDecode(response.body);
      _showDialog('비밀번호 변경 실패', responseBody['message']);
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
}

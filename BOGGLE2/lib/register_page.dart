import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:boggle/login_page.dart';
import 'package:boggle/services/user_api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _showPassword = false; // 비밀번호 보이기 여부
  bool _showConfirmPassword = false; // 비밀번호 확인 보이기 여부

  void _register() async {
    // 회원가입 정보 수집
    final String nickname = _nicknameController.text;
    final String id = _idController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String location = _locationController.text;
    final String email = _emailController.text;

    // 이메일 형식 확인
    if (!_isValidEmail(email)) {
      _showErrorDialog('올바른 이메일 형식이 아닙니다.');
      return;
    }

    // 비밀번호 일치 확인
    if (password != confirmPassword) {
      _showErrorDialog('비밀번호가 일치하지 않습니다.');
      return;
    }

    // 서버로 회원가입 요청 보내기
    final registerResponse = await ApiService.registerUser(id, nickname, password, location, email);

    if (registerResponse.statusCode == 201) {
      // 회원가입 성공 시 로그인 페이지로 이동
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
        return LoginPage();
      }));
    } else {
      // 회원가입 실패 시 에러 메시지 표시
      final responseBody = jsonDecode(utf8.decode(registerResponse.bodyBytes, allowMalformed: true));
      _showErrorDialog(responseBody['message'] ?? 'Unknown error');
    }
  }

  bool _isValidEmail(String email) {
    // 이메일 형식 확인하는 정규식
    final RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
        backgroundColor: Colors.white,
        title: const Text('회원가입'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 닉네임 입력란
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '닉네임을 입력해주세요',
              ),
            ),
            const SizedBox(height: 20.0),
            // 아이디 입력란
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '아이디를 입력해주세요',
              ),
            ),
            const SizedBox(height: 20.0),
            // 비밀번호 입력란
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword, // 비밀번호 가리기/보이기 제어
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '비밀번호를 입력해주세요',
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
            const SizedBox(height: 20.0),
            // 비밀번호 확인 입력란
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword, // 비밀번호 가리기/보이기 제어
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '비밀번호를 한번 더 입력해주세요',
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
            const SizedBox(height: 20.0),
            // 거주지역 입력란
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '거주 지역을 입력해주세요',
              ),
            ),
            const SizedBox(height: 20.0),
            // 이메일 입력란
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '이메일을 입력해주세요',
              ),
            ),
            const SizedBox(height: 20.0),
            // 회원가입 버튼
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC42AFA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _register,
              child: const Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

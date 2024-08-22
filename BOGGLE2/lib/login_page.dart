import 'dart:convert';
import 'package:boggle/find_id_page.dart';
import 'package:boggle/find_pw_page.dart';
import 'package:boggle/myhome.dart';
import 'package:boggle/mypage.dart';
import 'package:boggle/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false; // 비밀번호 보이기 여부

  void _login() async {
    final String id = _idController.text;
    final String password = _passwordController.text;

    if (id.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/login_view/'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'id': id,
            'password': password,
          }),
        );
        if (response.statusCode == 200) {
          // 로그인 성공 시 처리
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            // 성공 시 페이지 이동
            return MyHomePage(userId: id);
          }));
        } else {
          // 로그인 실패 시 처리
          final responseBody = json.decode(response.body);
          final errorMessage = responseBody['error'] ?? '알 수 없는 오류가 발생했습니다.';
          print('Login error: $errorMessage');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("확인"),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        // 오류 발생 시 처리
        print('Error during login: $e');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('로그인 중 오류가 발생했습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("확인"),
                ),
              ],
            );
          },
        );
      }
    } else {
      // ID 또는 비밀번호 누락 시 처리
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text("ID와 비밀번호를 입력하세요."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("확인"),
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
        title: const Text(""),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView( // 여기에서 SingleChildScrollView로 감쌈
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // 위젯을 상단에 배치
            children: [
              const SizedBox(height: 50), // 빈 공간 줄이기
              Image.asset(
                'image/boggleimg.png', // 이미지 경로를 실제 이미지 파일 경로로 변경하세요.
                width: 220, // 이미지의 너비를 조정
                height: 220, // 이미지의 높이를 조정
              ),
              const SizedBox(height: 20),
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
                    '비밀번호',
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
                  controller: _passwordController,
                  obscureText: !_showPassword, // 비밀번호 가리기/보이기 제어
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                    hintText: '비밀번호를 입력해주세요',
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
                  onPressed: _login,
                  child: const Text('로그인'),
                ),
              ),
              SizedBox(
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return const FindIDPage();
                          }),
                        );
                      },
                      child: const Text("ID 찾기"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return const FindPWPage();
                          }),
                        );
                      },
                      child: const Text("PW 찾기"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return const RegisterPage();
                          }),
                        );
                      },
                      child: const Text("회원가입"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

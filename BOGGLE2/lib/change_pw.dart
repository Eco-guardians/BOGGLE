import 'package:flutter/material.dart';
import 'package:boggle/do_list.dart';
import 'package:boggle/myhome.dart';
import 'package:boggle/mypage.dart';
import 'package:boggle/community.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePW extends StatefulWidget {
  final String userId;

  const ChangePW({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChangePW> createState() => _ChangePWState();
}

class _ChangePWState extends State<ChangePW> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _newPWController = TextEditingController();
  final TextEditingController _confirmPWController = TextEditingController();
  String _password = '';
  bool _showPassword = false; // 비밀번호 보이기 여부
  bool _showConfirmPassword = false; // 비밀번호 확인 보이기 여부
  bool _showoriginPassword = false; // 비밀번호 보이기 여부

  @override
  var _index = 3; // 페이지 인덱스 0,1,2,3

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/user_info/${widget.userId}'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
      setState(() {
        _password = data['password'] ?? ''; // null 체크 및 기본값 설정
        widget.userId;
      });
    } else {
      // 에러 처리
      print('Failed to load user info');
    }
  }
  // 페이지 이동 함수
  void _navigateToPage(int index) {
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = MyHomePage(userId: widget.userId);
        break;
      case 1:
        nextPage = DoList(userId: widget.userId);
        break;
      case 2:
        nextPage = Community(userId: widget.userId);
        break;
      case 3:
        nextPage = MyPage(userId: widget.userId);
        break;
      default:
        nextPage = MyHomePage(userId: widget.userId);
    }
    if (ModalRoute.of(context)?.settings.name != nextPage.toString()) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => nextPage));
    }
  }

  void _updatePassword() {
    final String pw = _pwController.text;
    final String newPw = _newPWController.text;
    final String confirmPw = _confirmPWController.text;

    if (pw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('비밀번호 입력 오류'),
            content: Text('비밀번호를 모두 입력해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (newPw != confirmPw) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('비밀번호 불일치'),
            content: Text('새로운 비밀번호가 일치하지 않습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('비밀번호 오류'),
            content: Text('비밀번호를 불러올 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    // 현재 비밀번호 확인
    if (_password != pw) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('비밀번호 오류'),
            content: Text('현재 비밀번호가 일치하지 않습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    // 비밀번호 변경 API 호출
    _callChangePasswordAPI(newPw);
  }

  void _callChangePasswordAPI(String newPassword) async {
    final Map<String, String> data = {
      'id': widget.userId,
      'current_password': _pwController.text, // 현재 비밀번호 전송
      'new_password': newPassword,
    };

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/change_password/'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // 비밀번호 변경 성공
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('비밀번호 변경 성공'),
            content: Text('비밀번호가 성공적으로 변경되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyPage(userId: widget.userId)),
                            );
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      // 비밀번호 변경 실패
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('비밀번호 변경 실패'),
            content: Text('비밀번호 변경 중 오류가 발생했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
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
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Text(
          ' BOGGLE',
          style: GoogleFonts.londrinaSolid(
              fontSize: 27,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 196, 42, 250)),
        ),
        centerTitle: false,
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
                    '현재 비밀번호',
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
                  obscureText: !_showoriginPassword, // 비밀번호 가리기/보이기 제어
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                    hintText: '현재 비밀번호를 입력해주세요',
                    contentPadding: const EdgeInsets.all(8),
                    suffixIcon: IconButton(
                    icon: Icon(_showoriginPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showoriginPassword = !_showoriginPassword; // 상태 변경
                      });
                    },
                  ),
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
                  controller: _newPWController,
                  obscureText: !_showPassword, // 비밀번호 가리기/보이기 제어
                  decoration: InputDecoration(
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
                    ),
                  ),
                  onPressed: _updatePassword,
                  child: const Text('비밀번호 수정'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _index = index;
          });
          _navigateToPage(index);
        },
        currentIndex: _index,
        selectedItemColor: Color.fromARGB(255, 196, 42, 250),
        unselectedItemColor: Color.fromARGB(255, 235, 181, 253),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(label: '홈', icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              label: '실천', icon: Icon(Icons.volunteer_activism)),
          BottomNavigationBarItem(
              label: '커뮤니티', icon: Icon(Icons.mark_chat_unread)),
          BottomNavigationBarItem(
              label: 'MY', icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }
}

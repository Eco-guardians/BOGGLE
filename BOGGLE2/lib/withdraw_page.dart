import 'package:flutter/material.dart';
import 'package:boggle/do_list.dart';
import 'package:boggle/login_page.dart';
import 'package:boggle/myhome.dart';
import 'package:boggle/mypage.dart';
import 'package:boggle/community.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class WithdrawPage extends StatefulWidget {
  final String userId;

  const WithdrawPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _pwController = TextEditingController();
  var _index = 3; // 페이지 인덱스 0,1,2,3
  String _password = '';
  bool _showPassword = false; // 비밀번호 보이기 여부

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/user_info/${widget.userId}'));
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

  void _withdraw() async {
    final String pw = _pwController.text;

    if (pw.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('비밀번호 입력 오류'),
            content: Text('비밀번호를 입력해주세요.'),
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

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/withdraw/${widget.userId}/'),
    );

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('회원 탈퇴 성공'),
            content: Text('회원 탈퇴가 완료되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return const LoginPage();
                    }),
                  );
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('오류'),
            content: Text('회원 탈퇴 중 오류가 발생했습니다.'),
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Image.asset(
          'image/boggleimg.png',
          height: 28, // 이미지 높이 설정
          fit: BoxFit.cover, // 이미지 fit 설정
        ),
        centerTitle: false,
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
                  '회원탈퇴를 하시겠습니까?\n탈퇴하려면 현재 비밀번호를 입력해 주세요.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                controller: _pwController,
                obscureText: !_showPassword, // 비밀번호 가리기/보이기 제어
                decoration: InputDecoration(
                  filled: true, // 배경을 채우도록 설정
                  fillColor: Colors.white, // 배경 색상을 하얀색으로 설정
                  border: const OutlineInputBorder(),
                  hintText: '비밀번호를 입력해주세요',
                  contentPadding: const EdgeInsets.all(8),
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
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
                onPressed: _withdraw,
                child: const Text('탈퇴하기'),
              ),
            ),
          ],
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
        selectedItemColor: const Color.fromARGB(255, 196, 42, 250),
        unselectedItemColor: const Color.fromARGB(255, 235, 181, 253),
        items: const <BottomNavigationBarItem>[
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

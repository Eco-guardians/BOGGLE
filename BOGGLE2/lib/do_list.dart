import 'dart:ui';

import 'package:boggle/cleanser_certificationList.dart';
import 'package:boggle/detergent_certification.dart';
import 'package:boggle/quiz.dart';
import 'package:boggle/quizlist.dart';
import 'package:boggle/sewer_report.dart';
import 'package:boggle/timer.dart';
import 'package:flutter/material.dart';
import 'package:boggle/community.dart';
import 'package:boggle/myhome.dart';
import 'package:boggle/mypage.dart';
import 'package:boggle/sewer.dart';
import 'package:google_fonts/google_fonts.dart';

class DoList extends StatefulWidget {
  final String userId;

  const DoList({Key? key, required this.userId}) : super(key: key);

  @override
  State<DoList> createState() => _DoListState();
}

class _DoListState extends State<DoList> {
  var _index = 1; // Ensure the initial index is set correctly

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
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.londrinaSolidTextTheme(), // 구글 폰트 적용
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Image.asset(
            'image/boggleimg.png',
            height: 28, // 이미지 높이 설정
            fit: BoxFit.cover, // 이미지 fit 설정
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CleanserCertificationList(
                              userId: widget.userId), // 수정된 부분
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      minimumSize: const Size(330, 90),
                      backgroundColor: Colors.grey,
                      shadowColor: Colors.black, // Shadow color
                      elevation: 7, // Elevation for shadow
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '세제 인증',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '친환경 세제 인증',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Sewer(title: '하수구 신고', userId: widget.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      minimumSize: const Size(330, 90),
                      backgroundColor: Colors.grey,
                      shadowColor: Colors.black, // Shadow color
                      elevation: 7, // Elevation for shadow
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '빗물받이 신고',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '하수구 빗물받이 불편 신고',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Added gap
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Quizlist(userId: widget.userId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      minimumSize: const Size(330, 90),
                      backgroundColor: Color.fromARGB(255, 196, 42, 250),
                      shadowColor: Colors.black, // Shadow color
                      elevation: 7, // Elevation for shadow
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '오늘의 퀴즈',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '퀴즈를 맞추면 뽑기 기회가!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:boggle/myhome.dart'; // MyHomePage
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class MyBoggle extends StatelessWidget {
  final String nickname;
  final int points;
  final int rank;
  final String userId; // 추가된 userId 필드

  const MyBoggle(
      {Key? key,
      required this.nickname,
      required this.points,
      required this.rank,
      required this.userId}) // userId를 받아옴
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MyHomePage(
                        userId: userId))); // userId를 전달하여 MyHomePage로 이동
          },
        ),
        title: Row(
          children: [
            Image.asset(
              'image/boggleimg.png', // 로고 이미지 경로
              height: 28,
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // background.png 이미지에 그림자 추가
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0), // 테두리 라운드 값 설정
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: Image.asset(
                    'image/background.png', // 배경 이미지 경로
                    // 이미지의 원본 크기를 유지
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildPointsContainer(nickname, points),
              SizedBox(height: 20),
              _buildPointsReport(points),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsContainer(String nickname, int points) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 106, 182, 222), // 파란색 배경
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              '$nickname',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '님의 포인트',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ]),
          SizedBox(height: 10),
          Text(
            textAlign: TextAlign.right,
            '$points' + 'P',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsReport(int points) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFF4682B4), // 어두운 파란색 배경
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '포인트 리포트',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end, // Row 내의 모든 요소를 아래로 정렬
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end, // 막대 그래프를 하단에 정렬
                children: [
                  Text(
                    '1,136 P',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 10, 100, 148),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.bottomCenter,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '전체',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end, // 막대 그래프를 하단에 정렬
                children: [
                  Text(
                    '$points P',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF87CEEB),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.bottomCenter,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '나',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: points / 1136, // 전체 포인트 대비 나의 포인트 비율
                              strokeWidth: 20,
                              color: Color.fromARGB(255, 14, 106, 155),
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '상위 70%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '$nickname 님은 $rank등 입니다.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsColumn(String points, Color color, String label) {
    return Column(
      children: [
        Text(
          points,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(int points) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: points / 1136, // 전체 포인트 대비 나의 포인트 비율
                strokeWidth: 20,
                color: Colors.white,
                backgroundColor: Colors.blue[900],
              ),
            ),
          ),
          Center(
            child: Text(
              '상위 70%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

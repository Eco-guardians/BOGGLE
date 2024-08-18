import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:boggle/do_list.dart';
import 'package:boggle/mypage.dart';
import 'package:boggle/community.dart';
import 'package:boggle/myBOGGLE.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:ui';

class MyBoggle extends StatelessWidget {
  final String nickname;
  final int points;
  final int rank;

  const MyBoggle({
    Key? key,
    required this.nickname,
    required this.points,
    required this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
              Image.asset(
                'image/background.png', // 배경 이미지 경로
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              _buildPointsContainer(nickname, points),
              SizedBox(height: 40),
              _buildPointsReport(points),
              SizedBox(height: 40),
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
        color: Color(0xFFADD8E6), // 파란색 배경
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$nickname 님의 포인트',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '$points P',
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
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPointsColumn('1,136 P', Colors.white, '전체'),
              _buildPointsColumn('$points P', Colors.white, '나'),
            ],
          ),
          SizedBox(height: 20),
          _buildCircularProgress(points),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
    return SizedBox(
      width: 120,
      height: 120,
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

import 'package:flutter/material.dart';
import 'package:boggle/myhome.dart';

class ShopScreen extends StatelessWidget {
  final String userId;

  const ShopScreen({Key? key, required this.userId}) : super(key: key);

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
                builder: (context) =>
                    MyHomePage(userId: userId), // userId를 전달하여 MyHomePage로 이동
              ),
            );
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '내 포인트',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '655 P',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ShopItem(
              title: '고래',
              points: 150,
              imagePath: 'image/whaleicon.png',
            ),
            ShopItem(
              title: '거북이',
              points: 25,
              imagePath: 'image/turtleicon.png',
            ),
            ShopItem(
              title: '물고기',
              points: 15,
              imagePath: 'image/fishicon.png',
            ),
            ShopItem(
              title: '해초',
              points: 5,
              imagePath: 'image/weedicon.png',
            ),
          ],
        ),
      ),
    );
  }
}

class ShopItem extends StatelessWidget {
  final String title;
  final int points;
  final String imagePath;

  const ShopItem({
    Key? key,
    required this.title,
    required this.points,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 50,
            height: 50,
          ),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            '$points P',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

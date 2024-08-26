import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boggle/myhome.dart';

class ShopScreen extends StatefulWidget {
  final String userId;

  const ShopScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late int userPoints;
  late Map<String, bool> itemDisabled; // 아이템 비활성화 상태를 관리할 Map

  @override
  void initState() {
    super.initState();
    userPoints = 0;
    itemDisabled = {
      '고래': false,
      '거북이': false,
      '물고기': false,
      '해초': false,
    };
    _fetchItem();
    _fetchUserPoints();
  }

  Future<void> _fetchItem() async {
    Map<int, String> indexToKey = {
      0: '고래',
      1: '거북이',
      2: '물고기',
      3: '해초',
    };

    // Map을 통해 인덱스를 돌며 요청을 보냄
    for (int i = 0; i < indexToKey.length; i++) {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2:8000/update_user_item/${widget.userId}/${i}'));
      if (response.statusCode == 200) {
        final userItemFromApi = json.decode(response.body)['item'];
        final String? key = indexToKey[i];
        if (key != null) {
          setState(() {
            itemDisabled[key] = userItemFromApi;
          });
        }
      } else {
        throw Exception('Failed to load item');
      }
    }
  }

  Future<void> _updateUserPoints(
      String userId, int pointsToSub, String itemName) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/sub_user_points/'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'userId': userId,
        'pointsToSub': pointsToSub.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Points updated successfully');
      setState(() {
        itemDisabled[itemName] = true; // 아이템 비활성화
      });
      _fetchUserPoints();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('포인트 업데이트에 실패했습니다. 다시 시도해주세요.'),
        ),
      );
    }
  }

  Future<void> _updateUserItem(String userId, String itemName) async {
    Map<String, int> indexToKey = {
      '고래': 0,
      '거북이': 1,
      '물고기': 2,
      '해초': 3,
    };
    int i = indexToKey[itemName]!;
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/buy_user_item/${userId}/${i}'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'userId': userId,
        'item': i.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Item purchased successfully');
      // 상태 업데이트는 _handlePurchase에서 처리
    } else {
      throw Exception('Failed to purchase item');
    }
  }

  Future<void> _fetchUserPoints() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:8000/user_points/${widget.userId}'));
    if (response.statusCode == 200) {
      final userPointsFromApi = json.decode(response.body)['points'];
      setState(() {
        userPoints = userPointsFromApi;
      });
    } else {
      throw Exception('Failed to load user points');
    }
  }

  void _handlePurchase(String itemName, int itemPoints) {
    if (userPoints >= itemPoints) {
      _updateUserPoints(widget.userId, itemPoints, itemName).then((_) {
        setState(() {
          itemDisabled[itemName] = true;
        });
      });
      _updateUserItem(widget.userId, itemName);
    } else {
      // 포인트 부족 경고
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('포인트가 부족합니다!'),
        ),
      );
    }
  }

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
                builder: (context) => MyHomePage(userId: widget.userId),
              ),
            );
          },
        ),
        title: Row(
          children: [
            Image.asset(
              'image/boggleimg.png',
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
                    '$userPoints P',
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
              isDisabled: itemDisabled['고래']!,
              onPurchase: () {
                _handlePurchase('고래', 150);
              },
            ),
            ShopItem(
              title: '거북이',
              points: 25,
              imagePath: 'image/turtleicon.png',
              isDisabled: itemDisabled['거북이']!,
              onPurchase: () {
                _handlePurchase('거북이', 25);
              },
            ),
            ShopItem(
              title: '물고기',
              points: 15,
              imagePath: 'image/fishicon.png',
              isDisabled: itemDisabled['물고기']!,
              onPurchase: () {
                _handlePurchase('물고기', 15);
              },
            ),
            ShopItem(
              title: '해초',
              points: 5,
              imagePath: 'image/weedicon.png',
              isDisabled: itemDisabled['해초']!,
              onPurchase: () {
                _handlePurchase('해초', 5);
              },
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
  final bool isDisabled; // 아이템 비활성화 상태
  final VoidCallback onPurchase;

  const ShopItem({
    Key? key,
    required this.title,
    required this.points,
    required this.imagePath,
    required this.isDisabled,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey : Colors.blue[300], // 비활성화 상태에 따른 색상
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
          IconButton(
            icon: Icon(Icons.add_shopping_cart, color: Colors.white),
            onPressed:
                isDisabled ? null : onPurchase, // 비활성화 상태에 따라 onPressed 처리
          ),
        ],
      ),
    );
  }
}

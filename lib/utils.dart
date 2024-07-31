import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateUserPoints(BuildContext context, String userId, int pointsToAdd) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/update_user_points/'),
    headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'userId': userId,
      'pointsToAdd': pointsToAdd.toString(),
    },
  );

  if (response.statusCode == 200) {
    showPointsEarnedDialog(context, pointsToAdd);
  } else {
    throw Exception('Failed to update points');
  }
}

void showPointsEarnedDialog(BuildContext context, int points) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: 200.0,
          height: 40.0,
          child: Center(
            child: Text(
              '$points 포인트 획득',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:boggle/myhome.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Travel extends StatefulWidget {
  final String location;
  final String userId;

  const Travel({Key? key, required this.location, required this.userId})
      : super(key: key);

  @override
  _TravelState createState() => _TravelState();
}

class _TravelState extends State<Travel> {
  String? imageUrl;
  bool imageLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImageFromUnsplash();
  }

  Future<void> fetchImageFromUnsplash() async {
    setState(() {
      imageLoading = true; // 이미지 로딩 시작
    });

    final response = await http.get(
      Uri.parse(
          'https://api.unsplash.com/photos/random?query=${widget.location}&client_id=Yyaw6oqQ4ucoIDsSdHyTNsNU7Tzw4quEMaRpm4kTJHE'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        imageUrl = data['urls']['regular'];
        imageLoading = false; // 이미지 로딩 완료
      });
    } else {
      // 이미지 로드 실패
      setState(() {
        imageLoading = false; // 로딩 실패 시에도 로딩 종료
      });
      print('Failed to load image');
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
                    builder: (context) => MyHomePage(userId: widget.userId)));
          },
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'BOGGLE',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: '.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  height: 250, // 높이를 적절히 조정하세요
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3), // 그림자의 위치 조정
                      ),
                    ],
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: imageLoading ? Colors.grey : null,
                  ),
                  child: imageLoading
                      ? Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Text(
                                      widget.location,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Text(
                                        '대청댐은 1980년에 준공된 콘크리트 중력식 및 사력식 댐(복합형)으로서 총 저수용량이 14억9천만톤으로 대전과 청주, 천안을 비롯한 충청지역 및 군산 등 전북 일부 지역에 생·공용수를, 금강하류와 미호천 유역에 농업용수를 공급하고 있다. 또한 홍수조절에 따른 댐하류 홍수피해 경감과 수력발전을 통한 청정에너지를.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2), // 그림자의 위치 조정
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '추천 코스',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '자라섬오토캠핑장\n호명호수공원\n쁘띠프랑스(La Petite France)\n강촌유원지\n김유정 문학촌',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

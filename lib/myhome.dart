import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:boggle/do_list.dart';
import 'package:boggle/mypage.dart';
import 'package:boggle/community.dart';
import 'package:boggle/myBOGGLE.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boggle/travel.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:location/location.dart'; // 위치 정보를 위해 추가

class MyHomePage extends StatefulWidget {
  final String userId;

  const MyHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _index = 0; // 페이지 인덱스 0,1,2,3
  String _nickname = '';
  int _points = 0;
  int _rank = 0;
  Location _loc = new Location();
  String _location = ''; // 초기값을 null로 설정
  String _travelLocation = '대청댐';
  double _waterQuality = 1.1; // 수질 ppm 값
  late String _userId = widget.userId; // userId 할당
  String QuizSolve = '미참여'; //Quiz 참여여부
  int detCount = 0; //세제 인증 횟수
  String _imageUrl = ''; // Unsplash에서 불러온 이미지 URL

  @override
  void initState() {
    super.initState();
    _initializeLocationService(); // 위치 서비스 초기화 호출
    _fetchUserInfo();
    _fetchWaterQuality(); // 수질 데이터 가져오기 호출
    _fetchUnsplashImage(_location); // 기본값으로 '대청댐'의 이미지를 가져옴
  }

  // 위치 서비스 초기화 함수
  Future<void> _initializeLocationService() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await _loc.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _loc.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _loc.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _loc.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await _loc.getLocation();
    setState(() {
      _location = '${_locationData.latitude}, ${_locationData.longitude}';
    });
  }

  // Unsplash API를 사용하여 이미지를 가져오는 함수
  void _fetchUnsplashImage(String location) async {
    final response = await http.get(
      Uri.parse(
          'https://api.unsplash.com/search/photos?query=$_travelLocation&client_id=Yyaw6oqQ4ucoIDsSdHyTNsNU7Tzw4quEMaRpm4kTJHE'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _imageUrl = data['results'][0]['urls']['regular'];
      });
    } else {
      // 에러 처리
      print('Failed to load image');
    }
  }

  void _fetchUserInfo() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/user_info/$_userId'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
      setState(() {
        _nickname = data['nickname'] ?? ''; // null 체크 및 기본값 설정
        _points = data['point'] ?? 0;
        _rank = data['rank'] ?? 0;
        _location = data['location'] ?? 'Unknown';
      });
    } else {
      // 에러 처리
      print('Failed to load user info');
    }
  }

  void _fetchWaterQuality() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/get_water_quality/'));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
      setState(() {
        _waterQuality = data['waterQuality'] ?? 1.1; // null 체크 및 기본값 설정
      });
    } else {
      // 에러 처리
      print('Failed to load water quality data');
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
      case 4:
        nextPage = MyBoggle(
            nickname: _nickname,
            points: _points,
            rank: _rank,
            userId: widget.userId);
        break;
      case 5:
        nextPage = Travel(location: _travelLocation, userId: widget.userId);
        break;
      default:
        nextPage = MyPage(userId: widget.userId);
    }
    if (ModalRoute.of(context)?.settings.name !=
        nextPage.runtimeType.toString()) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => nextPage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = GoogleFonts.londrinaSolid(
      fontSize: 27,
      fontWeight: FontWeight.normal,
      color: Color.fromARGB(255, 196, 42, 250),
    );

    final TextStyle indicatorTextStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return DefaultTabController(
      // DefaultTabController로 Scaffold 전체를 감쌈
      length: 0, // 상단 탭의 수
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Image.asset(
                'image/boggleimg.png',
                height: 28, // 이미지 높이 설정
                fit: BoxFit.cover, // 이미지 fit 설정
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14.0), // 오른쪽에 16px 여백 추가
              child: IconButton(
                icon: CircleAvatar(
                  radius: 18,
                  backgroundImage:
                      AssetImage('image/usericon.png'), // 사용자 프로필 이미지 경로
                ),
                onPressed: () {
                  // 프로필 아이콘 클릭 시 동작 추가
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyPage(userId: widget.userId)),
                  );
                },
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(25),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
        ),

        body: Container(
          color: Colors.white, // 배경색을 흰색으로 설정
          child: TabBarView(
            children: [
              _buildAquariumTab(indicatorTextStyle),
            ],
          ),
        ),
        // BottomNavigationBar 제거
      ),
    );
  }

  Widget _buildAquariumTab(TextStyle indicatorTextStyle) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          SizedBox(height: 20),
          _buildUserTreasuresSection(),
          SizedBox(height: 20),
          _buildWaterInformationSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    // 포인트에 따른 이미지와 텍스트를 정의
    String imagePath;
    String message;

    if (_points <= 50) {
      imagePath = 'image/Whale.png';
      message = _nickname + '님의 활동이 보글과 환경 오염을 지키고 있어요!\n계속 이대로 가주세요!';
    } else if (_points <= 100) {
      imagePath = 'image/fish.png';
      message = _nickname + '님의 작은 움직임으로\n보글과 환경 오염을 지킬 수 있어요!\n한 걸음씩 걸어가볼까요?';
    } else {
      imagePath = 'image/tortoise.png';
      message = _nickname + '님, 느려도 괜찮아요!\n흐르가는대로 천천히 해주세요\n당신의 한걸음이 지구를 바꿔요!';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        // Center 위젯으로 감싸서 중앙에 배치
        child: Column(
          mainAxisSize: MainAxisSize.min, // 최소 크기를 설정하여 자식이 있는 만큼만 공간 차지
          children: [
            Image.asset(
              imagePath,
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTreasuresSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _nickname + '님의 보글을 꾸며봐요!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildCard('내 보글', 'image/wave.png', '', '', 61, 168, 224, 4),
              _buildCard('내 포인트', 'image/gacha.png', _points.toString(), '/150',
                  207, 154, 225, 4)
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterInformationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildlongCard(
              '활동하기',
              'image/soap.png',
              'image/gutter.png',
              'image/Quiz.png',
              detCount.toString() + '/1',
              '신고하기',
              QuizSolve,
              192,
              155,
              255,
              1),
          Text(
            ' ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildlongCard('커뮤니티', 'image/community1.png', 'image/community3.png',
              'image/community2.png', ' ', ' ', ' ', 148, 128, 183, 2),
          Text(
            ' ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '우리 지역의 물 관련 정보를 알아봐요!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildWaterQualityCard(),
          SizedBox(height: 10),
          Text(
            ' ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildWaterTravelCard("대청댐"),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildWaterTravelCard(String location) {
    // location에 따른 이미지를 Unsplash에서 가져옴
    _fetchUnsplashImage(location);

    return GestureDetector(
      onTap: () {
        _navigateToPage(5); // 페이지 이동 기능 추가
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 배경 이미지: Unsplash API에서 가져온 이미지 사용
              _imageUrl.isNotEmpty
                  ? Image.network(
                      _imageUrl, // 불러온 이미지 URL 사용
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : CircularProgressIndicator(), // 이미지가 로딩 중일 때 표시

              // 블러 필터
              Positioned(
                right: 0,
                child: Container(
                  width: 130, // 블러 처리할 영역의 너비를 조정
                  height: 200,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 블러 강도 조정
                    child: Container(
                      color: const Color.fromARGB(255, 183, 224, 245)
                          .withOpacity(0.8), // 블러 효과 뒤의 색상
                    ),
                  ),
                ),
              ),
              // 텍스트와 아이콘
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '내 주변 물 여행지',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.luggage,
                              color: Colors.lightBlue,
                              size: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              _travelLocation,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildCard(String title, String imagePath, String point,
      String additionalInfo, int r, int g, int b, int index) {
    return GestureDetector(
      onTap: () {
        // 여기에 페이지 이동 기능을 추가
        _navigateToPage(index); // 예: index 1에 해당하는 페이지로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(240, r, g, b),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 패딩 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 좌측 정렬
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Row(
                // Row 위젯으로 이미지 가로 정렬
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // 이미지 사이 공간 균일하게 배치
                children: [
                  Image.asset(imagePath, height: 60),
                ],
              ),
              Text(
                point,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                additionalInfo,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.purple,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterQualityCard() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 251, 240, 255),
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이달의 수질',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_location),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '${_waterQuality.toString()} ppm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          _buildWaterQualityBar(),
          SizedBox(height: 10),
          _buildWaterQualityIndicators(),
        ],
      ),
    );
  }

  Widget _buildlongCard(
      String title,
      String imagePath1,
      String imagePath2,
      String imagePath3,
      String point,
      String additionalInfo1,
      String additionalInfo2,
      int r,
      int g,
      int b,
      int index) {
    return GestureDetector(
      onTap: () {
        // 여기에 페이지 이동 기능을 추가
        _navigateToPage(index); // 예: index 2에 해당하는 페이지로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(240, r, g, b),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // 패딩 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 좌측 정렬
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Row(
                // Row 위젯으로 이미지 가로 정렬
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // 이미지 사이 공간 균일하게 배치
                children: [
                  Image.asset(imagePath1, height: 50),
                  Image.asset(imagePath2, height: 50),
                  Image.asset(imagePath3, height: 50),
                ],
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 수평으로 중앙 정렬
                children: [
                  Text(
                    point,
                    style: TextStyle(
                        color: Color.fromARGB(255, 163, 109, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    additionalInfo1,
                    style: TextStyle(
                        color: Color.fromARGB(255, 163, 109, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    additionalInfo2,
                    style: TextStyle(
                        color: Color.fromARGB(255, 163, 109, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterQualityBar() {
    return Column(
      children: [
        Row(
          children: List.generate(10, (index) {
            return Expanded(
              child: Container(
                height: 8,
                color: _getColorForIndex(index),
              ),
            );
          }),
        ),
        Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(11, (index) => Text('$index')),
            ),
            Positioned(
              left: _getArrowPosition(),
              child: Icon(
                Icons.arrow_drop_up,
                color: _getColorForArrow(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterQualityIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWaterQualityRow(Icons.water_drop, Colors.blue, '매우 좋음',
              '간단한 정수 후 마실 수 있음', 0.0, 1.0),
          SizedBox(height: 10),
          _buildWaterQualityRow(Icons.water_drop, Colors.lightBlue, '좋음',
              '일반 정수 처리 후 마실 수 있음', 1.0, 2.0),
          SizedBox(height: 10),
          _buildWaterQualityRow(Icons.water_drop, Colors.green, '약간 좋음',
              '일반 정수 처리 후 마실 수 있음', 2.0, 3.0),
          SizedBox(height: 10),
          _buildWaterQualityRow(Icons.water_drop, Colors.blueGrey, '보통',
              '일반 정수 후 공업용수로 사용 가능', 3.0, 6.0),
          SizedBox(height: 10),
          _buildWaterQualityRow(
              Icons.water_drop,
              const Color.fromARGB(255, 172, 155, 1),
              '약간 나쁨',
              '농업용수로 사용 가능',
              6.0,
              8.0),
          SizedBox(height: 10),
          _buildWaterQualityRow(Icons.water_drop, Colors.orange, '나쁨',
              '특수처리 후 공업용수로 사용 가능', 8.0, 10.0),
          SizedBox(height: 10),
          _buildWaterQualityRow(
              Icons.water_drop, Colors.red, '매우 나쁨', '이용 불가능', 10.0, 100),
        ],
      ),
    );
  }

  Widget _buildWaterQualityRow(IconData icon, Color color, String title,
      String subtitle, double min, double max) {
    bool isHighlighted = _waterQuality >= min && _waterQuality < max;
    return Container(
      color: isHighlighted ? color.withOpacity(0.2) : Colors.transparent,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(width: 8),
          Text(subtitle),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    if (index < 1) return Colors.blue;
    if (index < 2) return Colors.lightBlue;
    if (index < 3) return Colors.green;
    if (index < 5) return Colors.blueGrey;
    if (index < 7) return Colors.yellow;
    if (index < 9) return Colors.orange;
    return Colors.red;
  }

  Color _getColorForArrow() {
    double ppm = _waterQuality;
    if (ppm < 1) return Colors.blue;
    if (ppm < 2) return Colors.lightBlue;
    if (ppm < 3) return Colors.green;
    if (ppm < 5) return Colors.blueGrey;
    if (ppm < 7) return Colors.yellow;
    if (ppm < 9) return Colors.orange;
    return Colors.red;
  }

  double _getArrowPosition() {
    double ppm = _waterQuality;
    double maxPosition = 365;
    if (ppm < 3) return 37 * ppm - 9;
    if (ppm < 4) return 36.5 * ppm - 6;
    if (ppm < 11) return 36 * ppm - 5;
    return maxPosition;
  }
}

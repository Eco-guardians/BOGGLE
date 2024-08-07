import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:boggle/do_list.dart';
import 'package:boggle/mypage.dart';
import 'package:boggle/community.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

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
  String? _location; // 초기값을 null로 설정
  double _waterQuality = 1.1; // 수질 ppm 값
  late String _userId = widget.userId; // userId 할당

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _fetchWaterQuality(); // 수질 데이터 가져오기 호출
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
      length: 2, // 상단 탭의 수
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
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
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
              _buildPointsTab(),
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
          selectedItemColor: Color.fromARGB(255, 196, 42, 250),
          unselectedItemColor: Color.fromARGB(255, 235, 181, 253),
          items: [
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
              _buildCard('내 보글', 'image/wave.png', '', '', 61, 168, 224),
              _buildCard('내 포인트', 'image/gacha.png', _points.toString(), '/150',
                  207, 154, 225)
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
          _buildlongCard('활동하기', 'image/soap.png', 'image/gutter.png',
              'image/Quiz.png', '0/1', '', 192, 155, 255),
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
          _buildWaterTravelCard(),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String imagePath, String point,
      String additionalInfo, int r, int g, int b) {
    return Container(
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
            Row(
              // Row 위젯으로 이미지 가로 정렬
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // 이미지 사이 공간 균일하게 배치
              children: [
                Image.asset(imagePath, height: 50),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(height: 5),
            Text(
              point,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              additionalInfo,
              style: TextStyle(
                  color: Colors.purple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ],
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
              Text(_location ?? 'Unknown'),
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
    String additionalInfo,
    int r,
    int g,
    int b,
  ) {
    return Container(
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
            SizedBox(height: 10),
            SizedBox(height: 5),
            Text(
              point,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              additionalInfo,
              style: TextStyle(fontSize: 14),
            ),
          ],
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

  Widget _buildWaterTravelCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('image/water_travel.png'),
          fit: BoxFit.cover,
        ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '내 주변 물 여행지',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, // 가로로 꽉 채우기
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 240, 240, 240), // 컨테이너 색상 변경
                borderRadius: BorderRadius.circular(25.0), // 모서리를 25% 둥글게 설정
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // 그림자 색상 및 투명도
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 3), // 그림자 위치
                  ),
                ],
                border: null, // 외곽선 제거
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: ' ',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: _nickname,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        TextSpan(
                          text: ' 님의 포인트',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '   $_points P',
                    style: GoogleFonts.notoSans(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text(
              '포인트 리포트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '나의 포인트를 비교하고 분석해보세요',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end, // 그래프를 아래쪽에 정렬
              children: [
                _buildPointsColumn(
                    '1,136 P', Colors.grey, '전체 사용자 평균 포인트', 100),
                _buildPointsColumn('$_points P',
                    Color.fromARGB(255, 196, 42, 250), '나의 포인트', _points),
              ],
            ),
            SizedBox(height: 40),
            Text(
              '나의 순위',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '나는 상위 몇 프로?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
            Text(
              '나의 포인트 순위를 알려드립니다.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
            ),
            SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      children: [
                        Center(
                            child: Container(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: 0.7,
                            strokeWidth: 40, // 원의 두께를 더 두껍게 설정
                            color: Color.fromARGB(255, 196, 42, 250),
                            backgroundColor: Colors.grey[200],
                          ),
                        )),
                        Center(
                          child: Text(
                            '상위 70%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 196, 42, 250),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                      SizedBox(width: 10),
                      Text(
                        '$_nickname 님은 $_rank등 입니다.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsColumn(
      String points, Color color, String label, int height) {
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
        SizedBox(height: 10),
        Container(
          width: 50,
          height: height.toDouble(),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), // 상단 좌측 둥글게
              topRight: Radius.circular(10), // 상단 우측 둥글게
            ),
            border: Border.all(color: Colors.black), // 검은색 외곽선
          ),
        ),
        SizedBox(height: 10),
        Text(label),
      ],
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

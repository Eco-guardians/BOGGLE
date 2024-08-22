import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:boggle/myhome.dart';
import 'package:boggle/do_list.dart';
import 'package:boggle/community.dart';
import 'package:boggle/mypage.dart';

class Quiz extends StatefulWidget {
  final String userId;

  const Quiz({super.key, required this.userId});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List<dynamic> _quizData = [];
  int _currentQuizIndex = 0;
  String _resultMessage = '';
  int _correctAnswers = 0;
  bool _isQuizCompleted = false;
  int _selectedIndex = 1;
  String _selectedAnswer = '';
  late String _userId;
  final int _pointsToAdd = 10;
  String _userPoints = '0';

  @override
  void initState() {
    super.initState();
    _userId = widget.userId; // userId 할당
    _fetchQuizData();
    _fetchUserPoints();
  }

  Future<void> _fetchQuizData() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/quiz_data_api'));
    if (response.statusCode == 200) {
      setState(() {
        _quizData = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load quiz data');
    }
  }

  Future<void> _fetchUserPoints() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/user_points/$_userId'));
    if (response.statusCode == 200) {
      final userPoints = json.decode(response.body)['points'];
      setState(() {
        _userPoints = userPoints.toString();
      });
    } else {
      throw Exception('Failed to load user points');
    }
  }

  Future<void> _checkAnswer(String question, String selectedAnswer) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/check_answer/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'question': question,
        'answer': selectedAnswer,
      }),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      setState(() {
        if (result['result'] == 'correct') {
          _resultMessage = 'Correct!';
          _correctAnswers++;
        } else {
          _resultMessage = 'Incorrect!';
        }

        if (_currentQuizIndex < _quizData.length - 1) {
          _currentQuizIndex++;
        } else {
          _isQuizCompleted = true;
          _resultMessage +=
              '\n\nQuiz completed! You got $_correctAnswers out of ${_quizData.length} correct.';
          _updateUserPoints(_userId, _correctAnswers * 3); // Update points here
        }
        _selectedAnswer = '';
      });
    } else {
      throw Exception('Failed to check answer');
    }
  }

  Future<void> _updateUserPoints(String userId, int pointsToAdd) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/update_user_points/'), // 슬래시 추가
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'userId': userId,
        'pointsToAdd': pointsToAdd.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Points updated successfully');
      _fetchUserPoints(); // Fetch user points after updating
    } else {
      throw Exception('Failed to update points');
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
    return Scaffold(
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
      body: _isQuizCompleted ? _buildScorePage() : _buildQuizPage(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _navigateToPage(_selectedIndex);
        },
        currentIndex: _selectedIndex,
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

  Widget _buildQuizPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.all(10.10),
          child: AppBar(
            title: const Text('오늘의 퀴즈', style: TextStyle(color: Colors.black)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: _quizData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _quizData[_currentQuizIndex]['explain'],
                      style: const TextStyle(fontSize: 15.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ..._buildChoiceButtons(_quizData[_currentQuizIndex]),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _checkAnswer(
                        _quizData[_currentQuizIndex]['explain'],
                        _selectedAnswer,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        backgroundColor:
                            const Color.fromARGB(255, 196, 42, 250),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '확인하기',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _resultMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    // Remove this line to stop showing real-time points
                    // Text(
                    //   '포인트: $_userPoints',
                    //   style: const TextStyle(
                    //       fontSize: 20.0, fontWeight: FontWeight.bold),
                    // ),
                  ],
                ),
              ],
            ),
    );
  }

  List<Widget> _buildChoiceButtons(Map<String, dynamic> quiz) {
    List<Widget> choiceButtons = [];
    for (String choice in quiz['choices']) {
      choiceButtons.add(
        RadioListTile<String>(
          title: Text(choice),
          value: choice,
          groupValue: _selectedAnswer,
          onChanged: (String? value) {
            setState(() {
              _selectedAnswer = value!;
            });
          },
        ),
      );
    }
    return choiceButtons;
  }

  Widget _buildScorePage() {
    int pointsEarned = _correctAnswers * 3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Color.fromARGB(255, 196, 42, 250),
            ),
            const SizedBox(height: 20),
            const Text(
              '퀴즈 완료!',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '$_correctAnswers / ${_quizData.length} 정답',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 30),
            Text(
              '$pointsEarned 포인트 획득',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CorrectAnswersPage(quizData: _quizData),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '정답 확인하기',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20), // Added to separate elements
            Text(
              '포인트: $_userPoints',
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class CorrectAnswersPage extends StatelessWidget {
  final List<dynamic> quizData;

  const CorrectAnswersPage({super.key, required this.quizData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
          'image/boggleimg.png',
          height: 28, // 이미지 높이 설정
          fit: BoxFit.cover, // 이미지 fit 설정
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: quizData.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizData[index]['explain'],
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '정답: ${quizData[index]['hNm']}',
                    style:
                        const TextStyle(fontSize: 16.0, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

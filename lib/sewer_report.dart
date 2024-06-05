import 'dart:convert';
import 'dart:io';
import 'package:boggle/community.dart';
import 'package:boggle/do_list.dart';
import 'package:boggle/myhome.dart';
import 'package:boggle/mypage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SewerReport extends StatefulWidget {
  final String title;

  const SewerReport({super.key, required this.title});

  @override
  State<SewerReport> createState() => _SewerReportState();
}

class _SewerState extends State<SewerReport> {
  final int _index = 1; // 페이지 인덱스 0,1,2,3

  // 페이지 이동 함수
  void _navigateToPage(int index) {
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = MyHomePage();
        break;
      case 1:
        nextPage = const DoList();
        break;
      case 2:
        nextPage = Community();
        break;
      case 3:
        nextPage = const MyPage();
        break;
      default:
        nextPage = MyHomePage();
    }
    if (ModalRoute.of(context)?.settings.name != nextPage.toString()) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => nextPage));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class Report {
  final int id;
  final String work;
  final String imageUrl;
  final String title;

  Report({
    required this.id,
    required this.work,
    required this.imageUrl, 
    required  this.title,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    String baseUrl = 'http://10.0.2.2:8000'; 
    return Report(
      id: json['id'],
      work: json['work'],
      title: json['title'],
      imageUrl: json['image'] != null ? '$baseUrl${json['image']}' : '',
    );
  }
}

class _SewerReportState extends State<SewerReport> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController  titleController = TextEditingController ();
  List<Report> reports = [];
  bool isModifying = false;
  int modifyingIndex = 0;
  File? image;
  int _index = 1;

  @override
  void initState() {
    super.initState();
    getReportFromServer();
  }

  Future<void> getReportFromServer() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/getReportList'));
    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = json.decode(responseBody);
      List<Report> list = jsonList.map<Report>((json) => Report.fromJson(json)).toList();
      print("Loaded tasks: ${list.length}");
      setState(() {
        reports = list;
      });
    } else {
      print("Failed to load tasks from server. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  Future<void> addReportToServer(Report report) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/addReport'),
    );

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image', image!.path));
    }

    request.fields['work'] = report.work;
    request.fields['title'] = report.title;

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('신고 접수되었습니다'),
        ),
      );
      getReportFromServer();
    } else {
      print("Failed to add report. Status code: ${response.statusCode}");
    }
  }

  Future<void> updateReportToServer(int id, String title, String work) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/updateReport/$id/'),
    );

    request.fields['title'] = title;
    request.fields['work'] = work;

    var response = await request.send();
    if (response.statusCode == 200) {
      getReportFromServer();
    } else {
      print("Failed to update report. Status code: ${response.statusCode}");
    }
  }

  Future<void> deleteReportToServer(int id) async {
    final response = await http.delete(Uri.parse('http://10.0.2.2:8000/deleteReport/$id/'));
    if (response.statusCode == 200) {
      getReportFromServer();
    } else {
      print("Failed to delete report. Status code: ${response.statusCode}");
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  String getToday() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  void navigateToDetailPage(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailPage(report: report),
      ),
    );
  }

  void _navigateToPage(int index) {
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = MyHomePage();
        break;
      case 1:
        nextPage = const DoList();
        break;
      case 2:
        nextPage = Community();
        break;
      case 3:
        nextPage = const MyPage();
        break;
      default:
        nextPage = MyHomePage();
    }
    if (ModalRoute.of(context)?.settings.name != nextPage.toString()) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => nextPage));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' BOGGLE',
          style: GoogleFonts.londrinaSolid(
              fontSize: 27,
              fontWeight: FontWeight.normal,
              color: const Color.fromARGB(255, 196, 42, 250),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                width: 390,
                height: 652,
                child: Stack(
                  children: [
                    Positioned(
                      left: 27,
                      top: 7,
                      child: SizedBox(
                        width: 97,
                        height: 30,
                        child: Text(
                          '글 작성',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 15,
                            fontFamily: 'Manrope',
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 267,
                      top: 17,
                      child: SizedBox(
                        width: 97,
                        height: 30,
                        child: Text(
                          '작성 시 유의사항',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 12,
                            fontFamily: 'Manrope',
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 27,
                      top: 310,
                      child: SizedBox(
                        width: 97,
                        height: 30,
                        child: Text(
                          '사진 첨부',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 15,
                            fontFamily: 'Manrope',
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 29,
                      top: 79,
                      child: Container(
                        width: 339,
                        height: 41,
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 0.50, color: Color(0xFFBABABA)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '제목을 입력해주세요.',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 28,
                      top: 136,
                      child: Container(
                        width: 339,
                        height: 162,
                        decoration: const ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 0.50, color: Color(0xFFBABABA)),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            controller: textController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '장소 및 신고 내용을 정확히 입력해주세요',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      top: 348,
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(color: Color(0xFFC4C4C4)),
                          child: image != null
                              ? Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                )
                              : const Center(child: Text('+')),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      top: 457,
                      child: GestureDetector(
                        onTap: () async {
                          if (image != null || isModifying) {
                            if (isModifying) {
                              await updateReportToServer(reports[modifyingIndex].id, titleController.text, textController.text);
                            } else {
                              var task = Report(
                                id: 0,
                                title: titleController.text,
                                work: textController.text,
                                imageUrl: '',
                              );
                              await addReportToServer(task);
                            }
                            setState(() {
                              textController.clear();
                              titleController.clear();
                              image = null;
                              isModifying = false;
                            });
                          } else {
                            print("Please select an image.");
                          }
                        },
                        child: Container(
                          width: 335,
                          height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFC42AFA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '등록하기',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: 'Manrope',
                                height: 1.00,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      top: 519,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            titleController.clear();
                            textController.clear();
                            image = null;
                            isModifying = false;
                          });
                        },
                        child: Container(
                          width: 335,
                          height: 56,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFBABABA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '취소하기',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontFamily: 'Manrope',
                                height: 1.00,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return ListTile(
                      title: GestureDetector(
                        onTap: () {
                          navigateToDetailPage(report);
                        },
                        child: Text(
                          report.title,
                          softWrap: true,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                titleController.text = report.title;
                                textController.text = report.work;
                                isModifying = true;
                                modifyingIndex = index;
                              });
                            },
                            child: const Text("수정"),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                deleteReportToServer(report.id);
                              });
                            },
                            child: const Text("삭제"),
                          ),
                        ],
                      ),
                    );
                  },
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
          BottomNavigationBarItem(label: '실천', icon: Icon(Icons.check_circle)),
          BottomNavigationBarItem(label: '커뮤니티', icon: Icon(Icons.group)),
          BottomNavigationBarItem(label: 'MY', icon: Icon(Icons.person))
        ],
      ),
    );
  }
}

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    print('Image URL: ${report.imageUrl}');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' BOGGLE',
          style: GoogleFonts.londrinaSolid(
              fontSize: 27,
              fontWeight: FontWeight.normal,
              color: const Color.fromARGB(255, 196, 42, 250),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            report.imageUrl.isNotEmpty
                ? Image.network(
                    report.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : const Text('No image available'),
            const SizedBox(height: 10),
            Text(
              report.work,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

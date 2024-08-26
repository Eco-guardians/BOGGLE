import 'dart:convert';
import 'dart:io';
import 'package:boggle/community.dart';
import 'package:boggle/do_list.dart';
import 'package:boggle/myhome.dart';
import 'package:boggle/mypage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';




import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // For location services

class MapScreen extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  const MapScreen({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(36.6275892249, 127.452384531); // Default center of the map
  LatLng? _currentLocation; // Store current location
  Set<Marker> _markers = {}; // Set of markers on the map
  bool _isMarkerSelected = false; // To track if a marker is selected

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Get current location when the screen initializes
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle location services not enabled
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        // Handle permission not granted
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      // Move the camera to the current location and add a marker
      mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 14.0));
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: InfoWindow(title: 'Your Current Location'),
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTapped(LatLng location) {
    // Show dialog to add marker information
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MarkerDialog(
          lat: location.latitude,
          lon: location.longitude,
          onConfirm: (name) {
            setState(() {
              final markerId = DateTime.now().toString();
              _markers.add(
                Marker(
                  markerId: MarkerId(markerId),
                  position: location,
                  infoWindow: InfoWindow(
                    title: name,
                    snippet: 'Lat: ${location.latitude}, Lng: ${location.longitude}',
                  ),
                ),
              );
              widget.onLocationSelected(location); // Call the callback function
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 설정'),
        backgroundColor: Color.fromARGB(255, 195, 96, 202),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        onTap: _onMapTapped, // Handle map taps
        markers: _markers, // Display markers on the map
      ),
    );
  }
}

class MarkerDialog extends StatelessWidget {
  final double lat;
  final double lon;
  final Function(String) onConfirm;

  MarkerDialog({
    required this.lat,
    required this.lon,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('위치 추가하기'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('위도: ${lat.toStringAsFixed(7)}'),
            Text('경도: ${lon.toStringAsFixed(7)}'),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '이름',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              onConfirm(nameController.text); // Call the callback with the name
              Navigator.of(context).pop();
            }
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}
class Report {
  final int id;
  final String title;
  final String work;
  final String imageUrl;
  final double latitude;
  final double longitude;

  Report({
    required this.id,
    required this.title,
    required this.work,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
      String baseUrl = 'http://10.0.2.2:8000';
    return Report(
      
      id: json['id'] ?? 0, // 기본값을 지정
      title: json['title'] ?? '', // 기본값을 지정
      work: json['work'] ?? '', // 기본값을 지정
      imageUrl: json['image'] != null ? '$baseUrl${json['image']}' : '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0, // null 처리
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0, // null 처리
    );
  }
}




 


class SewerReport extends StatefulWidget {
  final String title;
  final String userId;

  const SewerReport({Key? key, required this.title, required this.userId}) : super(key: key);

  @override
  State<SewerReport> createState() => _SewerReportState();
}

class _SewerReportState extends State<SewerReport> {
  late String _userId;
  final TextEditingController textController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  List<Report> reports = [];
  bool isModifying = false;
  int modifyingIndex = 0;
  File? image;
  LatLng? _selectedLocation; // Store selected location
  int index = 1;
  String _userPoints = '0';

  @override
  void initState() {
    super.initState();
    _userId = widget.userId;
    _fetchUserPoints();
    getReportFromServer();
  }

  Future<void> _fetchUserPoints() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/user_points/$_userId'));
    if (response.statusCode == 200) {
      final userPoints = json.decode(response.body)['points'];
      setState(() {
        _userPoints = userPoints.toString();
      });
    } else {
      throw Exception('Failed to load user points');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Image.asset(
          'image/boggleimg.png',
          height: 28,
          fit: BoxFit.cover,
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
                       bottom: 220,
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
                            side: BorderSide(
                                width: 0.50, color: Color(0xFFBABABA)),
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
                            side: BorderSide(
                                width: 0.50, color: Color(0xFFBABABA)),
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
                      bottom: 160,
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
                       bottom: 160,
                      right: 20,
                      child: GestureDetector(
                        onTap: () async {
                          LatLng? selectedLocation = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                onLocationSelected: (LatLng location) {
                                  setState(() {
                                    _selectedLocation = location;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.blueAccent,
                          child: Text(
                            '지도에서 위치 선택하기',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedLocation != null)
                      Positioned(
                        bottom: 250,
                        left: 20,
                        child: Container(
                          width: 350,
                          padding: EdgeInsets.all(10),
                          color: Colors.white,
                          child: Text(
                            '선택된 위치\n위도: ${_selectedLocation!.latitude.toStringAsFixed(7)}\n경도: ${_selectedLocation!.longitude.toStringAsFixed(7)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
  left: 32,
  bottom: 80,
  child: GestureDetector(
    onTap: () async {
      if (image != null || isModifying) {
        if (isModifying) {
           await updateReportToServer(
        reports[modifyingIndex].id,
        titleController.text,
        textController.text,
        reports[modifyingIndex].imageUrl,
        reports[modifyingIndex].latitude,
        reports[modifyingIndex].longitude
      );
        } else {
      var task = Report(
        id: 0,
        title: titleController.text,
        work: textController.text,
        imageUrl: '', // Add the image URL if available
        latitude: _selectedLocation?.latitude ?? 0.0, // Use default if location is not selected
        longitude: _selectedLocation?.longitude ?? 0.0, // Use default if location is not selected
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
                       bottom: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            titleController.clear();
                            textController.clear();
                            image = null;
                            isModifying = false;
                            _selectedLocation = null; // Clear selected location
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
      print('Building item $index: ${report.title}');  // 추가 디버깅
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
)

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            index = index;
          });
          navigateToPage(index);
        },
        currentIndex: index,
        selectedItemColor: const Color.fromARGB(255, 196, 42, 250),
        unselectedItemColor: const Color.fromARGB(255, 235, 181, 253),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label: '홈', icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              label: '실천', icon: Icon(Icons.volunteer_activism)),
          BottomNavigationBarItem(
              label: '커뮤니티', icon: Icon(Icons.mark_chat_unread)),
          BottomNavigationBarItem(label: 'MY', icon: Icon(Icons.account_circle))
        ],
      ),
    );
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
  request.fields['latitude'] = report.latitude.toString();  // Convert to String
  request.fields['longitude'] = report.longitude.toString(); // Convert to String

  var response = await request.send();
  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('신고 접수되었습니다'),
      ),
    );
    _updateUserPoints(_userId, 25);
    getReportFromServer();

    showPointsEarnedDialog(context, 25);
  } else {
    print("Failed to add report. Status code: ${response.statusCode}");
  }
}
Future<void> updateReportToServer(int id, String title, String work, String imageUrl, double latitude, double longitude) async {
  final url = 'http://10.0.2.2:8000/updateReport/$id/';
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({
    'title': title,
    'work': work,
    'image': imageUrl,
    'latitude': latitude,
    'longitude': longitude,
  });

  final response = await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    getReportFromServer();
    print('Report updated successfully');
  } else {
    print('Failed to update report: ${response.statusCode}');
  }
}



Future<void> getReportFromServer() async {
  final response = await http.get(Uri.parse('http://10.0.2.2:8000/getReportList'));
  if (response.statusCode == 200) {
    print("Response body: ${response.body}"); // Print the response body
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

  void navigateToPage(int index) {
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
          context, MaterialPageRoute(builder: (context) => nextPage));
    }
  }
Future<void> deleteReportToServer(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/deleteReport/$id/'),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 204) {  // 204 No Content
      getReportFromServer();
      print('Report deleted successfully');
    } else {
      print("Failed to delete report. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print('Exception caught: $e');
  }
}



  void showPointsEarnedDialog(BuildContext context, int points) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 200.0, // Adjust the width as needed
            height: 40.0, // Adjust the height as needed
            child: Center(
              child: Text(
                '$points 포인트 획득',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16, // Adjust the font size as needed
                ),
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
      _fetchUserPoints(); // Update user points after adding points
    } else {
      throw Exception('Failed to update points');
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
}
class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    print('Image URL: ${report.imageUrl}'); // Debug print

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Image.asset(
          'image/boggleimg.png',
          height: 28,
          fit: BoxFit.cover,
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
                    report.imageUrl, // Use Image.network to load from URL
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Error loading image'); // Handle error
                    },
                  )
                : const Text('No image available'),
            const SizedBox(height: 10),
            Text(
              report.work,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Latitude: ${report.latitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Longitude: ${report.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

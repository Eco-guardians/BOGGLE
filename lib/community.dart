import 'package:boggle/recruitment_post.dart';
import 'package:boggle/user_info.dart';
import 'package:flutter/material.dart';
import 'package:boggle/do_list.dart';
import 'package:boggle/myhome.dart';
import 'package:boggle/mypage.dart';
import 'package:boggle/communityInfo.dart';
import 'package:boggle/recruitment_post.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Community extends StatefulWidget {
  final String userId;

  const Community({Key? key, required this.userId}) : super(key: key);

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  var _index = 2; // 페이지 인덱스 0,1,2,3
  String _nickname = '';

  void _fetchUserInfo() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:8000/user_info/${widget.userId}'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
      setState(() {
        _nickname = data['nickname'] ?? ''; // null 체크 및 기본값 설정
      });
      print(_nickname);
    } else {
      // 에러 처리
      print('Failed to load user info');
    }
  }

  final List<CommunityPost> posts = [
    CommunityPost(
      '홍길동',
      'image/usericon.png',
      '2024-05-01 13:17',
      '설거지 바 써보신분?',
      '제가 액체 주방세제에서 고체 주방세제로 바꾸려고 하는데 괜찮은 설거지 바 있으면 추천 부탁드립니다.',
    ),
    CommunityPost(
      '김철수',
      'image/usericon.png',
      '2024-05-01 13:06',
      '주말에 플로깅 가시는 분 있나요?',
      '이번주 무심천에서 진행하는 플로깅에 참여하고 싶은데 혹시 가시는 분 있나요?',
    ),
  ];

  // final List<RecruitmentPost> recruitmentPosts = [
  //   RecruitmentPost(
  //     title: '주말 플로깅 모집',
  //     location: '[충청북도]',
  //     description: '이번 주말 플로깅에 참여하실 분을 모집합니다. 함께 환경 보호 활동을 해보세요!',
  //   ),
  //   RecruitmentPost(
  //     title: '청소 자원봉사자 모집',
  //     location: '[경기도]',
  //     description: '우리 동네 청소에 도움을 주실 자원봉사자를 찾습니다. 많은 참여 부탁드립니다.',
  //   ),
  // ];

// 게시물 리스트를 초기화하는 부분
  List<RecruitmentPost> recruitmentPosts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();  // 초기화 시 DB에서 글을 가져오는 함수 호출
  }

  // Future<void> _fetchPosts() async {
  //   final response = await http.get(
  //     Uri.parse('http://10.0.2.2:8000/recruitment_posts/'), // Django API URL
  //   );

  //   if (response.statusCode == 200) {
  //     final List<dynamic> postData = json.decode(response.body);
  //     setState(() {
  //       recruitmentPosts = postData.map((post) => RecruitmentPost.fromJson(post)).toList();
  //     });
  //   } else {
  //     // Handle the error
  //     print('Failed to load posts');
  //   }
  // }

  Future<void> _fetchPosts() async {
  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/recruitment_posts/'), // Django API URL
  );

  if (response.statusCode == 200) {
    final List<dynamic> postData = json.decode(response.body);
    setState(() {
      recruitmentPosts = postData.map((post) {
        return RecruitmentPost.fromJson(post);
      }).toList();
    });
  } else {
    // Handle the error
    print('Failed to load posts');
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
        nextPage = MyHomePage(userId: widget.userId);
    }
    if (ModalRoute.of(context)?.settings.name != nextPage.toString()) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => nextPage));
    }
  }

  Future<void> _navigateToCommunityPostPage() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CommunityPostPage(userId: widget.userId))
  );

  if (result != null && result is Map<String, dynamic>) {
    setState(() {
      posts.add(CommunityPost(
        'one', // 사용자 닉네임
        'image/usericon.png', // 사용자 이미지 경로
        result['date'], // 게시 날짜
        result['title'], // 게시 제목
        result['content'], // 게시 내용
        postImage: result['image'], // 게시 이미지 (선택적)
      ));
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Image.asset(
          'image/boggleimg.png',
          height: 28,
          fit: BoxFit.cover,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            margin: const EdgeInsets.all(16.0),
            height: 200, // Adjust the height as needed
            child: PageView.builder(
              itemCount: recruitmentPosts.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecruitmentPostPage(post: recruitmentPosts[index]),
                      ),
                    );
                  },
                  child: _buildRecruitPost(recruitmentPosts[index]),
                );                
              },
            ),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CommunityPostScreen(post: posts[index]),
                      ),
                    );
                  },
                  child: _buildPost(posts[index]),
                );
              },
            ),
          ),
        ],
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
          BottomNavigationBarItem(label: 'MY', icon: Icon(Icons.person)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCommunityPostPage,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 196, 42, 250),
      ),
    );
  }
  Widget _buildRecruitPost(RecruitmentPost post) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 217, 130, 255),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space between children
                      children: <Widget>[
                        Text(
                          post.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '[ ${post.recruitment_area} ]', // Add square brackets around the text
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      post.recruitment_date != null 
                        ? DateFormat('yyyy-MM-dd').format(post.recruitment_date!).toString() 
                        : 'Date not available',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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

  Widget _buildPost(CommunityPost post) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(post.userImage),
              ),
              const SizedBox(width: 8.0),
              Text(post.userNickname),
              const Spacer(),
              Text(post.postdate),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(post.postTitle,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4.0),
          Text(post.postContent),
          if (post.postImage != null) ...[
            Image.file(post.postImage!),
          ],
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite),
                color: Colors.grey,
                onPressed: () {
                  // Handle like action
                },
              ),
              Text('${post.likeCount}'), // Static example, replace with dynamic data
              const SizedBox(width: 16.0),
              IconButton(
                icon: const Icon(Icons.comment),
                color: Colors.grey,
                onPressed: () {
                  // Handle comment action
                },
              ),
              Text('${post.commentCount}'), // Static example, replace with dynamic data
            ],
          ),
          const Divider(color: Colors.grey),
        ],
      ),
    );
  }
}


class CommunityPostScreen extends StatefulWidget {
  final CommunityPost post;

  CommunityPostScreen({required this.post});

  @override
  _CommunityPostScreenState createState() => _CommunityPostScreenState();
}

class _CommunityPostScreenState extends State<CommunityPostScreen> {
  bool isLiked = false;
  int likeCount = 0; // 좋아요 개수 초기화
  int commentCount = 0;

  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likeCount;
    commentCount = widget.post.commentCount;
  }

  void _addComment() {
    final comment = _commentController.text;
    if (comment.isNotEmpty) {
      setState(() {
        _comments.add(comment);
        commentCount++;
        widget.post.commentCount = commentCount;
      });
      _commentController.clear();
    }
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    setState(() {
      this.isLiked = !isLiked;
      likeCount += this.isLiked ? 1 : -1;
      widget.post.likeCount = likeCount;
    });
    return !isLiked;
  }

  @override
  void dispose() {
    _commentController.dispose();
    Navigator.pop(context, widget.post); // 변경된 post 객체를 상위 페이지로 전달
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(''), // AppBar의 텍스트를 삭제
        iconTheme:
        const IconThemeData(color: Color.fromARGB(255, 196, 42, 250)),
      ),
      body: Container(
        color: Colors.white, // 배경색을 흰색으로 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(widget.post.userImage),
                ),
                const SizedBox(width: 8.0),
                Text(widget.post.userNickname),
                const Spacer(),
                Text(widget.post.postdate),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(widget.post.postTitle,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Padding(padding: const EdgeInsets.all(15.0)),
            Text(widget.post.postContent, style: const TextStyle(fontSize: 16)),
            if (widget.post.postImage != null) ...[
              const SizedBox(height: 16.0),
              Image.file(widget.post.postImage!),
            ],
            const SizedBox(height: 8.0),
            Row(
              children: [
                LikeButton(
                  size: 20,
                  isLiked: isLiked,
                  likeCount: likeCount,
                  onTap: onLikeButtonTapped,
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: SizedBox(
                      width: 24, // 원하는 너비 설정
                      height: 24, // 원하는 높이 설정
                      child: Image.asset('image/usericon.png'),
                    ),
                    title: Text(
                      _comments[index],
                      style: const TextStyle(color: Colors.black),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Colors.grey), // 글과 댓글 사이에 경계를 추가
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력해주세요.',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Color.fromARGB(255, 196, 42, 250)),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityPostPage extends StatefulWidget {
  final String userId;
  
  const CommunityPostPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CommunityPostPageState createState() => _CommunityPostPageState();
}

class _CommunityPostPageState extends State<CommunityPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _recruitmentPeopleController = TextEditingController();
  final TextEditingController _recruitmentDateController = TextEditingController();
  final TextEditingController _recruitmentDeadlineController = TextEditingController();
  final TextEditingController _recruitmentAreaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _image;
  String _postType = '일반 게시글'; // 게시글 유형을 나타내는 변수
  String _nickname = '';
  int _points = 0;
  int _rank = 0;
  String? _location; // 초기값을 null로 설정
  late final String _userId = widget.userId; // userId 할당

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();  // Fetch user info when the widget is initialized
  }

//   void _fetchUserInfo() async {
//   try {
//     final response =
//         await http.get(Uri.parse('http://10.0.2.2:8000/user_info/$_userId'));

//     if (response.statusCode == 200) {
//       print('Response body: ${response.body}');
//       final data = json.decode(utf8.decode(response.bodyBytes));

//       setState(() {
//         _nickname = data['nickname'] ?? '';
//         _points = data['point'] ?? 0;
//         _rank = data['rank'] ?? 0;
//         _location = data['location'] ?? 'Unknown';
//       });

//       print('Nickname: $_nickname');
//     } else {
//       print('Failed to load user info. Status code: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error fetching user info: $e');
//   }
// }
  void _fetchUserInfo() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/user_info/$_userId'));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          _nickname = data['nickname'] ?? '';
          _points = data['point'] ?? 0;
          _rank = data['rank'] ?? 0;
          _location = data['location'] ?? 'Unknown';
        });

        print('Nickname: $_nickname');
      } else {
        print('Failed to load user info. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }


  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

Future<void> _submitPost() async {
  _fetchUserInfo();
  final String title = _titleController.text.trim();
  final String content = _contentController.text.trim();
  final String date = DateTime.now().toIso8601String();
  final String postType = _postType;

  // Validate required fields
  if (title.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('제목을 입력해 주세요.')),
    );
    return;
  }

  // Initialize the post data map
  Map<String, dynamic> postData = {
    'title': title,
    'content': content,
    'post_type': postType,
    'date': date,
    'nickname': _nickname,  
  };

  // Add additional fields based on the post type
  if (postType == '참여자 모집') {
    postData.addAll({
      'recruitment_people': _recruitmentPeopleController.text.trim(),
      'recruitment_date': _recruitmentDateController.text.trim(),
      'recruitment_deadline': _recruitmentDeadlineController.text.trim(),
      'recruitment_area': _recruitmentAreaController.text.trim(),
      'description': _descriptionController.text.trim(),
    });
  }

  // Add image if it's available
  if (_image != null) {
    postData['image'] = base64Encode(_image!.readAsBytesSync());
  }

  // Send the POST request to the Django backend
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/create_post/'),  // Replace with your Django URL
    headers: {
      'Content-Type': 'application/json'},
    body: json.encode(postData),
  );

  // Check the response status
  if (response.statusCode == 201) {
    // Successfully submitted
    Navigator.pop(context, postData);  // Pass data back to the previous screen
  } else {
    // Handle error
    final responseData = json.decode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit post: ${responseData['content'] ?? 'Unknown error'}')),
    );
    print('Failed to submit post: ${response.body}');
  }
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          '글 작성하기',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color.fromARGB(255, 196, 42, 250)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 글 작성 타입 선택
            const Text(
              '글 유형 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text('일반 게시글'),
              value: '일반 게시글',
              groupValue: _postType,
              onChanged: (value) {
                setState(() {
                  _postType = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('참여자 모집'),
              value: '참여자 모집',
              groupValue: _postType,
              onChanged: (value) {
                setState(() {
                  _postType = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // 제목 입력
            const Text(
              '글 제목',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목을 입력해주세요.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // '일반 게시글' 타입일 경우에만 사진 첨부 가능
            if (_postType == '일반 게시글') ...[
              // 내용 입력
            TextField(
              controller: _contentController,
              maxLines: 8,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                alignLabelWithHint: true,
                labelText: '내용을 입력해주세요. (최대 1000자)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
              const Text(
                '사진 첨부',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  color: Colors.grey[200],
                  width: 100,
                  height: 100,
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : const Icon(Icons.add, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
            ],

            // '참여자 모집' 선택 시 보여줄 추가 입력 필드들
            if (_postType == '참여자 모집') ...[
              const Text(
                '모집 인원',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _recruitmentPeopleController,
                decoration: const InputDecoration(
                  labelText: '모집 인원을 입력해주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '봉사 일자',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  DateTime today = DateTime.now();
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: today,
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _recruitmentDateController.text =
                          '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _recruitmentDateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '모집 마감일자',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  DateTime today = DateTime.now();
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: today,
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _recruitmentDeadlineController.text =
                          '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _recruitmentDeadlineController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '봉사 지역',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _recruitmentAreaController,
                decoration: const InputDecoration(
                  labelText: '봉사 지역을 입력해주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '설명',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '설명을 입력해주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),
            ],

            // 등록하기 버튼
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _fetchUserInfo();
                });
                _submitPost(); 
                },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 196, 42, 250),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '등록하기',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
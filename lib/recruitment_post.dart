import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';

class RecruitmentPost {
  final String title;
  final String recruitment_area;
  final String userImage;
  final String nickname;
  final String description;  
  final DateTime? recruitment_deadline;
  final File? postImage;
  final int recruitment_people;
  int commentCount;
  int people;
  final DateTime? recruitment_date; 

  RecruitmentPost({
    required this.title,
    required this.recruitment_area,
    required this.userImage,
    required this.nickname,
    required this.recruitment_date,
    required this.recruitment_deadline,
    required this.description,
    this.postImage,
    required this.recruitment_people,
    this.people = 0,
    this.commentCount = 0,
  });

  factory RecruitmentPost.fromJson(Map<String, dynamic> json) {
    return RecruitmentPost(
      title: json['title'] ?? 'Untitled',
      recruitment_area: json['recruitment_area'] ?? 'Unknown location',
      userImage: json['user_image'] ?? 'default_image.png',
      nickname: json['nickname'] ?? 'Anonymous',
      recruitment_date: json['recruitment_date'] != null 
        ? DateTime.tryParse(json['recruitment_date'].toString()) 
        : null,
      recruitment_deadline: json['recruitment_deadline'] != null
        ? DateTime.tryParse(json['recruitment_deadline'].toString())
        : DateTime.now(),
      description: json['description'] ?? 'No content available',
      postImage: json['post_image'] != null ? File(json['post_image']) : null,
      recruitment_people: json['recruitment_people'] != null
        ? int.tryParse(json['recruitment_people'].toString()) ?? 0
        : 0,
      commentCount: json['comment_count'] != null 
        ? int.tryParse(json['comment_count'].toString()) ?? 0 
        : 0,
    );
  }
}


class RecruitmentPostPage extends StatefulWidget {
  final RecruitmentPost post;

  RecruitmentPostPage({required this.post});

  @override
  _RecruitmentPostScreenState createState() => _RecruitmentPostScreenState();
}

class _RecruitmentPostScreenState extends State<RecruitmentPostPage> {
  bool isLiked = false;
  int people = 0; // 참가버튼 누른 사람
  int commentCount = 0; // Default value if not provided


  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];
  
  @override
  void initState() {
    super.initState();
    people = widget.post.people;
    commentCount = widget.post.commentCount;
  }

  void _addComment() {
    final comment = _commentController.text;
    if (comment.isNotEmpty) {
      setState(() {
        _comments.add(comment);
        commentCount = (commentCount ?? 0) + 1; // Ensure non-null value
        widget.post.commentCount = commentCount;
      });
      _commentController.clear();
    }
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    setState(() {
      this.isLiked = !isLiked;
      people = (people ?? 0) + (this.isLiked ? 1 : -1); // Ensure non-null value
      // widget.post.recruitment_people = people;
    });
    return !isLiked;
  }


  @override
  void dispose() {
    _commentController.dispose();
    Navigator.pop(context, widget.post); // Pass the updated post back
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(''), // AppBar의 텍스트를 삭제
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 196, 42, 250)),
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
                Text(widget.post.nickname),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(children: [
              Text(
              '봉사 일자: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.post.recruitment_date != null
                    ? DateFormat('yyyy-MM-dd').format(widget.post.recruitment_date!)
                    : 'No date'),
            ],),
            const SizedBox(height: 8.0),
            Row(children: [
              Text(
                '모집마감기한: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.post.recruitment_deadline != null
                    ? DateFormat('yyyy-MM-dd').format(widget.post.recruitment_deadline!)
                    : 'No deadline available',
              ),            
            ],),
            const SizedBox(height: 16.0),
            Text(widget.post.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Padding(padding: const EdgeInsets.all(10.0)),
            Text(widget.post.description, style: const TextStyle(fontSize: 16)),
            if (widget.post.postImage != null) ...[
              const SizedBox(height: 8.0),
              Image.file(widget.post.postImage!),
            ],
            const SizedBox(height: 8.0),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC42AFA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    bool result = await onLikeButtonTapped(isLiked);
                    setState(() {
                      isLiked = result;
                    });
                  },
                  child: Text(
                    isLiked ? '참여취소' : '참여하기', // 상태에 따라 텍스트 변경
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Row(children: [
                  Text(
                  '${people} / ',
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.post.recruitment_people}',
                ),
                ],)
                
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

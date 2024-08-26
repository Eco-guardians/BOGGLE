import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';

class RecruitmentPost {
  final String title;
  final String recruitment_area;
  final String userImage;
  final String userNickname;
  final String description;  
  final DateTime? recruitment_deadline;
  final File? postImage;
  int recruitment_people;
  int commentCount;
  final DateTime? recruitment_date; 

  RecruitmentPost({
    required this.title,
    required this.recruitment_area,
    required this.userImage,
    required this.userNickname,
    required this.recruitment_date,
    required this.recruitment_deadline,
    required this.description,
    this.postImage,
    this.recruitment_people = 0,
    this.commentCount = 0,
  });

  factory RecruitmentPost.fromJson(Map<String, dynamic> json) {
    return RecruitmentPost(
      title: json['title'] ?? 'Untitled',
      recruitment_area: json['recruitment_area'] ?? 'Unknown location',
      userImage: json['user_image'] ?? 'default_image.png',
      userNickname: json['user_nickname'] ?? 'Anonymous',
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
  int recruitment_people = 0; // Default value if not provided
  int commentCount = 0; // Default value if not provided


  final TextEditingController _commentController = TextEditingController();
  final List<String> _comments = [];

  @override
  void initState() {
    super.initState();
    recruitment_people = widget.post.recruitment_people;
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
      recruitment_people = (recruitment_people ?? 0) + (this.isLiked ? 1 : -1); // Ensure non-null value
      widget.post.recruitment_people = recruitment_people;
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
                Text(widget.post.userNickname),
                const Spacer(),
                Text(widget.post.recruitment_date != null
                    ? DateFormat('yyyy-MM-dd').format(widget.post.recruitment_date!)
                    : 'No date'),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(widget.post.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            Padding(padding: const EdgeInsets.all(15.0)),
            Text(widget.post.description, style: const TextStyle(fontSize: 16)),
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
                  likeCount: recruitment_people,
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

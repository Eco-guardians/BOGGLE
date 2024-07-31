import 'dart:io';

import 'package:flutter/material.dart';

class CommunityPost{
  final String userNickname;// 작성자 닉네임
  final String userImage; // 작성자 개인 이미지
  final String postdate; // 작성 날짜
  final String postTitle; // 작성된 제목
  final String postContent;// 작성된 내용
  final File? postImage; // 게시글 이미지
  int likeCount;//좋아요 개수
  int commentCount;// 댓글 개수

  CommunityPost(
      this.userNickname,
      this.userImage,
      this.postdate,
      this.postTitle,
      this.postContent, {
        this.likeCount = 0,
        this.commentCount = 0,
        this.postImage,
      });
}


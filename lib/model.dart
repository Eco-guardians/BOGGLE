import 'dart:io';

import 'package:flutter/material.dart';

class Certification {
  final String certificationCheck; // 세제 인증 여부
  final String certificationDate; // 인증 날짜
  final File cleanserImage; // 세제 이미지
  final File receiptImage; // 영수증 이미지

  Certification(
      this.certificationCheck,
      this.certificationDate,
      this.cleanserImage,
      this.receiptImage,
      );
}


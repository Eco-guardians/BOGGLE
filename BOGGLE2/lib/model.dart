import 'dart:io';

import 'package:flutter/material.dart';

class Certification{
  final String cleansername;// 세제 이름
  final String certificationcheck; // 세제 인증 여부
  final String certificationdate; // 인증 날짜
  final File cleanserImage; //세제 이미지

  Certification(this.cleansername, this.certificationcheck, this.certificationdate, this.cleanserImage);
}


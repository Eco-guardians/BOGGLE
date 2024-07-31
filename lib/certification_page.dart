import 'dart:io';

import 'package:boggle/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CertificationPage extends StatelessWidget {
  const CertificationPage({Key? key, required this.certification})
      : super(key: key);

  final Certification certification;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Image.asset(
          'image/boggleimg.png',
          height: 28, // 이미지 높이 설정
          fit: BoxFit.cover, // 이미지 fit 설정
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, //가운데 정렬
          children: [
            SizedBox(
              height: 350,
              width: 350,
              child: Image.file(certification.cleanserImage as File),
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              certification.cleansername,
              style: GoogleFonts.ibmPlexSansKr(
                  fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '인증확인 일자 : ' + certification.certificationdate,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'model.dart';

class CertificationPage extends StatelessWidget {
  const CertificationPage({Key? key, required this.certification}) : super(key: key);

  final Certification certification;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true, // 뒤로가기 버튼 표시
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Image.asset(
          'image/boggleimg.png',
          height: 28,
          fit: BoxFit.cover,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '인증 여부: ${certification.certificationCheck}',
                  style: GoogleFonts.ibmPlexSansKr(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '인증확인 일자: ${certification.certificationDate}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.file(certification.cleanserImage, fit: BoxFit.cover),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.file(certification.receiptImage, fit: BoxFit.cover),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


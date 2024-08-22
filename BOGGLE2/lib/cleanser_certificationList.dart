import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'model.dart';
import 'certification_page.dart';
import 'detergent_certification.dart';
import 'utils.dart'; // utils.dart 파일 임포트

class CleanserList extends StatelessWidget {
  final Certification? newCertification;
  final String userId; // userId를 받도록 수정

  const CleanserList({Key? key, this.newCertification, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CleanserCertificationList(newCertification: newCertification, userId: userId),
    );
  }
}

class CleanserCertificationList extends StatefulWidget {
  final Certification? newCertification;
  final String userId; // userId를 받도록 수정

  const CleanserCertificationList({Key? key, this.newCertification, required this.userId}) : super(key: key);

  @override
  State<CleanserCertificationList> createState() => _CleanserCertificationListState();
}

class _CleanserCertificationListState extends State<CleanserCertificationList> {
  List<Certification> certificationData = [];

  @override
  void initState() {
    super.initState();
    if (widget.newCertification != null) {
      certificationData.add(widget.newCertification!);
      // 새로운 인증이 추가될 때 포인트 지급
      updateUserPoints(context, widget.userId, 25);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.all(10.10),
          child: AppBar(
            title: const Text('세제 인증 내역', style: TextStyle(color: Colors.black)),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: certificationData.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                color: Colors.white,
                child: ListTile(
                  title: Text(
                      certificationData[index].cleansername,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      )
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          certificationData[index].certificationcheck,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: const Color.fromARGB(255, 196, 42, 250),
                          )
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          certificationData[index].certificationdate,
                          style: GoogleFonts.notoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: const Color.fromARGB(255, 190, 190, 190),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => CertificationPage(certification: certificationData[index])));
                    debugPrint(certificationData[index].cleansername);
                  },
                ),
              ),
              const Divider(
                height: 1,
                color: Color.fromARGB(255, 190, 190, 190),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Detergent(title: '세제 인증'),
              ),
            );
            if (result != null && result is Certification) {
              setState(() {
                certificationData.add(result);
              });
              // 새로운 인증이 추가될 때 포인트 지급
              await updateUserPoints(context, widget.userId, 25);
            }
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 196, 42, 250),
        ),
      ),
    );
  }
}

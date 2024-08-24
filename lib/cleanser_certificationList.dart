import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'model.dart';
import 'receipt_certification.dart';
import 'detergent_certification.dart';

class CleanserCertificationList extends StatefulWidget {
  final Certification? newCertification;
  final String userId;

  const CleanserCertificationList({Key? key, this.newCertification, required this.userId}) : super(key: key);

  @override
  State<CleanserCertificationList> createState() => _CleanserCertificationListState();
}

class _CleanserCertificationListState extends State<CleanserCertificationList> {
  List<Certification> certificationData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.newCertification != null) {
      certificationData.add(widget.newCertification!);
      updateUserPoints(context, widget.userId, 25);
    }
  }

  void updateUserPoints(BuildContext context, String userId, int points) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$points 포인트가 지급되었습니다.'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('세제 인증 내역', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
                    certificationData[index].certificationDate,
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  trailing: Text(
                    certificationData[index].certificationCheck,
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 196, 42, 250),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CertificationDetailPage(certification: certificationData[index]),
                      ),
                    );
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
              updateUserPoints(context, widget.userId, 25);
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


class CertificationDetailPage extends StatelessWidget {
  final Certification certification;

  const CertificationDetailPage({Key? key, required this.certification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인증 상세'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView( // 여기에 SingleChildScrollView 추가
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '인증 날짜: ${certification.certificationDate}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Text(
                '인증 상태: ${certification.certificationCheck}',
                style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 196, 42, 250)),
              ),
              const SizedBox(height: 30),
              Image.file(certification.cleanserImage),
              const SizedBox(height: 20),
              Image.file(certification.receiptImage),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // 1. 일반 공유 패키지 사용

class DetailPage extends StatefulWidget {
  final String question;
  final String answer;

  const DetailPage({
    super.key,
    required this.answer,
    required this.question,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

  // 2. 일반 공유하기 함수 (아주 간단합니다!)
  void _shareResult() {
    // 공유할 메시지 내용을 예쁘게 만듭니다.
    String message = "✨ 심리테스트 결과 ✨\n\n"
        "Q. ${widget.question}\n\n"
        "👉 결과: ${widget.answer}\n\n"
        "나도 테스트 하러 가기! 👇\n"
        "https://www.google.com"; // 나중에 실제 앱 링크로 바꾸세요

    // 스마트폰의 기본 공유 창을 띄웁니다.
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('테스트 결과'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 질문 카드 스타일
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.question,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),

              // 결과 텍스트 강조
              Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // 3. 공유하기 버튼 (디자인 업그레이드)
              SizedBox(
                width: double.infinity, // 버튼을 가로로 꽉 차게
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _shareResult, // 위에서 만든 함수 연결
                  icon: const Icon(Icons.share, color: Colors.white),
                  label: const Text(
                    '친구에게 결과 공유하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, // 세련된 남색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 돌아가기 버튼
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  '다른 테스트 하러 가기',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
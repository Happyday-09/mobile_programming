import 'package:flutter/material.dart';
import 'dart:convert';
import '../sub/question_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 광고 패키지

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference _testRef;
  late Future<List<String>> _dataFuture;

  // 🔹 AdMob 광고 변수
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _testRef = database.ref('test');
    _dataFuture = loadAsset();

    // 🔹 광고 로드
    _loadBannerAd();
  }

  // 🔹 배너 광고 설정 함수
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // 테스트 ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  Future<List<String>> loadAsset() async {
    try {
      DataSnapshot snapshot = await _testRef.get();

      // 🔹 데이터가 없으면 5개 자동 생성
      if (snapshot.value == null) {
        List<Map<String, dynamic>> initialData = [
          {
            "title": "당신의 영혼의 파트너 동물은?",
            "question": "무인도에 떨어졌을 때, 가장 먼저 찾을 물건은?",
            "selects": ["생존 키트", "스마트폰", "침낭", "책"],
            "answer": ["현실적인 리더형", "소통왕 강아지형", "집돌이 고양이형", "지식 탐구 앵무새형"]
          },
          {
            "title": "5초 MBTI 연애편",
            "question": "데이트 중, 애인이 갑자기 화를 낸다면?",
            "selects": ["왜 화났는지 논리적으로 묻는다", "일단 미안하다고 하고 기분을 풀어준다"],
            "answer": ["당신은 T성향 (이성적)", "당신은 F성향 (감성적)"]
          },
          {
            "title": "당신의 운명적인 사랑 스타일",
            "question": "샤워할 때 어디부터 씻나요?",
            "selects": ["머리", "상체", "하체"],
            "answer": ["자만추 추구형", "소개팅 선호형", "운명적 만남 추구형"]
          },
          {
            "title": "나의 숨겨진 부자 지능 테스트",
            "question": "길에서 100만원을 주웠다! 당신의 선택은?",
            "selects": ["바로 경찰서에 가져다준다", "주변을 살피고 슬쩍 챙긴다", "기부한다", "친구들에게 한턱 쏜다"],
            "answer": ["정직한 부자형", "스릴 즐기는 투자자형", "나눔의 천사형", "인싸 탕진형"]
          },
          {
            "title": "나에게 딱 맞는 여행지는?",
            "question": "여행 가방을 쌀 때 당신의 스타일은?",
            "selects": ["일주일 전부터 리스트 작성", "전날 밤에 닥치는 대로", "몸만 간다"],
            "answer": ["계획적인 유럽형", "즉흥적인 동남아형", "자유로운 국내 호캉스형"]
          }
        ];

        for (var data in initialData) {
          await _testRef.push().set(data);
        }
        snapshot = await _testRef.get();
      }

      List<String> testList = [];
      for (var element in snapshot.children) {
        if (element.value != null) {
          testList.add(jsonEncode(element.value));
        }
      }
      return testList;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('심리테스트 모음', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 🔹 메인 리스트
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> item = jsonDecode(snapshot.data![index]);
                      return _buildTestCard(context, item);
                    },
                  );
                } else {
                  return const Center(child: Text('데이터가 없습니다.'));
                }
              },
            ),
          ),
          // 🔹 애드몹 광고 배너
          if (_isBannerAdReady)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  // 🔹 아이콘을 제거한 텍스트 중심의 카드 디자인
  Widget _buildTestCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // lib/main/mainlist_page.dart 파일의 _buildTestCard 함수 내부

          onTap: () async {
            // 1. Firebase Analytics 로그 (기존 코드)
            await FirebaseAnalytics.instance.logEvent(
              name: 'test_click',
              parameters: {'test_name': item['title'].toString()},
            );

            // 🟡 2. Firebase Realtime Database에 "내가 고른 것" 저장하기 (추가된 부분)
            try {
              // 'history'라는 방을 만들어서 누가 뭘 언제 클릭했는지 저장
              DatabaseReference historyRef = FirebaseDatabase.instance.ref('history');
              await historyRef.push().set({
                "test_title": item['title'],
                "selected_time": DateTime.now().toString(),
              });

              // 3. 화면 하단에 "저장되었습니다" 알림 띄우기 (추가된 부분)
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Firebase에 선택 기록이 저장되었습니다! ✅'),
                  duration: Duration(seconds: 1), // 1초만 보여줌
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } catch (e) {
              print('저장 실패: $e');
            }

            // 4. 화면 이동 (기존 코드)
            if (!context.mounted) return;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => QuestionPage(question: item),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0), // 여백을 조금 더 넉넉하게
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'].toString(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                  ),
                ),
                const SizedBox(height: 8), // 제목과 설명 사이 간격
                Text(
                  "탭해서 테스트 시작하기",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
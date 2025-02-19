import 'package:flutter/material.dart';
import 'package:muses_app/page/live_view_page.dart';

import 'play_video_view_page.dart';
import 'video_tab_bar_page.dart';
import '../client/video_rest_client.dart';

class BottomNavigationBarPageApp extends StatelessWidget {
  const BottomNavigationBarPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // home: Container(child:  const Text("1")),);
        home: Scaffold(bottomNavigationBar: BottomNavagationBarViewPage()));
  }
}

/**
 *  底部导航栏，视频，直播，活动，投票
 */
class BottomNavagationBarViewPage extends StatefulWidget {
  const BottomNavagationBarViewPage({super.key});

  @override
  State<BottomNavagationBarViewPage> createState() =>
      _BottomNavagationBarViewPageState();
}

class _BottomNavagationBarViewPageState
    extends State<BottomNavagationBarViewPage> {
  int _bottomNativeBarIndex = 0;
  // final VideoRestClient videoRestClient = VideoRestClient();

  final List<Widget> _pages = [
    const VideoTabBarPage(),
    const LiveViewPage(),
    PlayVideoViewPage(loadVideoFunc: (int pageIndex, int pageCount) {
      return VideoRestClient().listVideo();
    }), // 假设这是你的首页
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          color: Colors.black,
          child: _pages[_bottomNativeBarIndex],
        ),
        bottomNavigationBar: _bottomNavigationBar());
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
        items: items(),
        currentIndex: _bottomNativeBarIndex,
        onTap: (index) {
          setState(() {
            _bottomNativeBarIndex = index;
          });
        },
        fixedColor: Colors.blue,
        type: BottomNavigationBarType.fixed);
  }
}

List<BottomNavigationBarItem> items() {
  return [
    const BottomNavigationBarItem(
      icon: Icon(Icons.video_call),
      label: '视频',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.live_tv),
      label: '直播',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.local_activity),
      label: '活动(todo)',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.how_to_vote),
      label: '投票(todo)',
    ),
  ];
}

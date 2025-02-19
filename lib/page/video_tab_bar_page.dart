import 'package:flutter/material.dart';

import '../util/common_logger.dart';
import 'play_video_view_page.dart';
import '../view/video_pub_view_element.dart';
import '../client/video_rest_client.dart';

class TabBarViewPageApp extends StatelessWidget {
  const TabBarViewPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: VideoTabBarPage());
  }
}

class VideoTabBarPage extends StatefulWidget {
  const VideoTabBarPage({super.key});
  @override
  State<VideoTabBarPage> createState() => _VideoTabBarPageState();
}

class _VideoTabBarPageState extends State<VideoTabBarPage>
    with SingleTickerProviderStateMixin {
  VideoRestClient videoRestClient = VideoRestClient();

  List tab = ["我的", "推荐"];

  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: tab.length, vsync: this);
    log.info("begin init videoTabBarPage");
  }

  @override
  Widget build(BuildContext context) {
    log.info("begin build videoTabBarPage");
    return _buildWidget();
  }

  Widget _buildWidget() {
    return Scaffold(
      appBar: AppBar(
        bottom: _buildTabBar(),
        centerTitle: true,
      ),
      body: _buildBodyView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pubVideo,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  _pubVideo() {
    log.info("begin pub video, open the video publish drawer input for video info");
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const Scaffold(body: VideoPubViewElement());
    }));
  }

  _buildBodyView() {
    return TabBarView(controller: _tabController, children: [
      PlayVideoViewPage(loadVideoFunc: (int pageIndex, int pageCount) {
        return videoRestClient.listVideo();
      }),
      PlayVideoViewPage(loadVideoFunc: (int pageIndex, int pageCount) {
        return videoRestClient.listVideo();
      })
    ]);
  }

  _buildTabBar() {
    return PreferredSize(
        preferredSize: const Size(double.infinity, 0), //标题高度
        child: TabBar(
          isScrollable: false,
          labelStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.tab,
          controller: _tabController,
          tabs: tab.map((e) {
            return Tab(text: e);
          }).toList(),
        ));
  }
}

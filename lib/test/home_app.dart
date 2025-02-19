import 'package:flutter/material.dart';

import '../page/play_video_view_page.dart';
import '../page/video_tab_bar_page.dart';
import '../client/video_rest_client.dart';
// import 'package:marquee/marquee.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "myapp",
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            // appBar:
            body: Container(
                decoration: BoxDecoration(color: Colors.grey[500]),
                child: const VideoTabBarPage()),
            bottomNavigationBar: BottomAppBar(
                padding: const EdgeInsets.only(top: 0.0, left: 0.0),
                child: Container(
                    height: 100,
                    decoration: const BoxDecoration(color: Colors.black),
                    child: const BottomBar()))
            // bottomNavigationBar: BottomNavigationBar(items: [],),
            ));
  }
}

class Home extends StatelessWidget {
  Home({super.key});
  VideoRestClient videoRestClient = VideoRestClient();

  @override
  Widget build(BuildContext context) {
    return PlayVideoViewPage(loadVideoFunc: (int pageIndex, int pageCount) {
      return videoRestClient.listVideo();
    });
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          getBtmTextWidget("首页", true),
          getBtmTextWidget("同城", false),
          const AddIcon(),
          getBtmTextWidget("消息", false),
          getBtmTextWidget("我的", false),
        ],
      ),
    );
  }

  getBtmTextWidget(String content, bool selectFlag) {
    return Text(content,
        style: selectFlag
            ? const TextStyle(fontSize: 18, color: Colors.white)
            : TextStyle(fontSize: 18, color: Colors.grey[600]));
  }
}

class AddIcon extends StatelessWidget {
  const AddIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: 60,
      child: Stack(children: <Widget>[
        Positioned(
            height: 35,
            width: 50,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.circular(10)))),
        Positioned(
            height: 35,
            width: 50,
            right: 0,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10)))),
        Positioned(
            height: 35,
            width: 50,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add),
            ))
      ]),
    );
  }
}

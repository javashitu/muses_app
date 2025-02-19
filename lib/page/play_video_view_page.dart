import 'package:flutter/material.dart';
import 'package:muses_app/view/video_play_desc_view_element.dart';

import '../common/global.dart';
import '../models/videoProgramInfo.dart';
import '../util/common_logger.dart';
import '../view/video_play_button_view_element.dart';
import '../client/video_rest_client.dart';
import '../view/video_play_view_element.dart';

class PlayVideoViewPageApp extends StatelessWidget {
  PlayVideoViewPageApp({super.key});

  VideoRestClient videoRestClient = VideoRestClient();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(
        body: PlayVideoViewPage(loadVideoFunc: (int pageIndex, int pageCount) {
      return videoRestClient.listVideo();
    })));
  }
}

typedef LoadMoreVideo = Future<List<VideoProgramInfo>> Function(
  int pageCount,
  int pageSize,
);

class PlayVideoViewPage extends StatefulWidget {
  final LoadMoreVideo loadVideoFunc;

  const PlayVideoViewPage({super.key, required this.loadVideoFunc});

  @override
  State<PlayVideoViewPage> createState() => _PlayVideoViewPageState();
}

class _PlayVideoViewPageState extends State<PlayVideoViewPage> {
  late PageController _pageController;
  late VideoRestClient videoRestClient;

  late List<VideoProgramInfo> videoProgramList = [];

  late Future<List<VideoProgramInfo>> future;
  int _pageIndex = 0;
  final int _pageSize = 10;
  int loadCount = 0;

  @override
  void initState() {
    super.initState();
    log.info("begin init playVideoViewPage");
    User user = UserMock.getUser();
    videoRestClient = VideoRestClient();
    _pageController = PageController(
      initialPage: _pageIndex,
      viewportFraction: 1.0,
    );
    future = widget.loadVideoFunc(_pageIndex, _pageSize).catchError((error) {
      log.info("load video from server faillure, the error $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    PageView.builder(
      itemCount: 100,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) {
        log.info("this page has in end, will initialize other page");
        _loadMoreVideo();
      },
      controller: _pageController,
      allowImplicitScrolling: false,
      padEnds: true,
      reverse: false,
      itemBuilder: (context, index) {
        return Stack(children: [
          Positioned(
              child: VideoPlayViewElement(
            videoUrl: videoProgramList[index % loadCount].videoUrl,
            pageIndex: index,
          )),
        ]);
      },
    );

    log.info("begin build playVideoViewPage");
    return FutureBuilder(
        future: future,
        builder: (BuildContext context,
            AsyncSnapshot<List<VideoProgramInfo>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.connectionState == ConnectionState.done) {
            // 如果数据加载完成
            if (snapshot.hasError) {
              return const Center(child: Text('加载视频失败，可能服务器挂了'));
            } else if (snapshot.hasData) {
              log.info(
                  "load videoProgramInfo finished, will add videoProgramInfo to list");
              final parsedData = snapshot.data;
              _addVideoInfoToList(parsedData);
              if (loadCount == 0) {
                return const Center(child: Text('没有查询到视频数据，可能服务器被清空了'));
              }

              //必须在materriaApp下面一层次啊能拿到
              double screenWidth = MediaQuery.of(context).size.width;
              double screenHeight = MediaQuery.of(context).size.height;

              return Container(
                color: Colors.black,
                child: PageView.builder(
                  itemCount: 100,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) {
                    if (index == loadCount - 1) {
                      log.info(
                          "this page has in end, will initialize other page");
                      _loadMoreVideo();
                    }
                  },
                  controller: _pageController,
                  allowImplicitScrolling: false,
                  padEnds: true,
                  reverse: false,
                  itemBuilder: (context, index) {
                    return Stack(children: [
                      Positioned(
                          child: VideoPlayViewElement(
                        videoUrl: videoProgramList[index % loadCount].videoUrl,
                        pageIndex: index,
                      )),
                      Positioned(
                          bottom: 0,
                          width: 0.75 * screenWidth,
                          height: 120,
                          child: VideoDescViewElement(
                              videoProgramList[index % loadCount])),
                      Positioned(
                          right: 0,
                          width: 0.25 * screenWidth,
                          height: 0.4 * screenHeight,
                          top: 0.3 * screenHeight,
                          child: VideoPlayButtonViewElement(
                            videoProgramInfo:
                                videoProgramList[index % loadCount],
                          )),
                    ]);
                  },
                ),
              );
            }
          }
          // 其他情况下，可以返回一个默认的占位符或者空组件
          return Container();
        });
  }

  _loadMoreVideo() async {
    log.info(
        "load more videoPorgramInfo to play, now load page is $_pageIndex");
    List<VideoProgramInfo> videoList =
        await widget.loadVideoFunc(_pageIndex + 1, _pageSize);
    _pageIndex++;
    _addVideoInfoToList(videoList);
  }

  _addVideoInfoToList(List<VideoProgramInfo>? videoList) {
    log.info("add videoProgramInfo to list in playVideoViewPage");
    if (videoList == null || videoList.isEmpty) {
      return;
    }
    videoProgramList.addAll(videoList);
    loadCount = videoProgramList.length;
  }
}

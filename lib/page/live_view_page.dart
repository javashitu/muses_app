import 'package:flutter/material.dart';
import 'package:muses_app/client/live_rest_client.dart';
import 'package:muses_app/models/liveProgramInfo.dart';
import 'package:muses_app/view/live_view_element.dart';

import '../util/common_logger.dart';

class LiveViewPage extends StatefulWidget {
  const LiveViewPage({super.key});

  @override
  State<LiveViewPage> createState() => _LiveViewPageState();
}

class _LiveViewPageState extends State<LiveViewPage> {
  //緩存的直播信息
  List<LiveProgramInfo> activeliveProgramInfo = [];
  late Future<List<LiveProgramInfo>> future;
  LiveRestClient liveRestClient = LiveRestClient.random();

  static const int _maxLoadCount = 100;
  static const int _pageSize = 20;
  //这个pageIndex不是滑动翻页的页码，而是去查询直播数据时的页码
  int _pageIndex = 0;
  int _loadCount = 0;
  bool _joinFlag = false;
  bool _pubFlag = false;

  late PageController _pageController;

  _loadMorectiveLive() async {
    liveRestClient.listActiveLiveProgram(_pageIndex + 1).then((value) {
      if (value.isNotEmpty) {
        _pageIndex++;
        _addLive(value);
      }
    });
  }

  _addLive(List<LiveProgramInfo>? liveProgramInfoList) {
    if (liveProgramInfoList == null || liveProgramInfoList.isEmpty) {
      log.info("liveProgramInfoList is null, won't addLive");
      return;
    }
    log.info(
        "liveProgramInfoList is not null, will add live data to page liveList the live count is ${liveProgramInfoList.length}");
    // setState(() {
    activeliveProgramInfo.addAll(liveProgramInfoList);
    _loadCount = activeliveProgramInfo.length;
    // });
  }

  _joinLive() {
    log.info("will join the live ");
    setState(() {
      _joinFlag = true;
    });
  }

  Widget _buildLiveElement(LiveProgramInfo liveProgramInfo, int index) {
    String connectUrl = liveProgramInfo.liveAddress["url"];
    String connectionId = liveProgramInfo.liveAddress["connectionId"];
    String roomId = liveProgramInfo.liveAddress["roomId"];
    String token = liveProgramInfo.liveAddress["token"];
    String userId = connectionId;
    log.info("generate liveViewElement, the pubFlag is $_joinFlag");
    LiveViewElement liveViewElement = LiveViewElement(
      pubFlag: _joinFlag,
      roomId: roomId,
      userId: userId,
      token: token,
      connectionId: connectionId,
      connectUrl: connectUrl,
      closeCallback: (roomIdParam, indexParam, closeFlag) => Future.delayed(
          Duration.zero,
          () => _liveCloseCallback(roomIdParam, indexParam, closeFlag)),
      liveViewElementIndex: index,
    );
    return Center(child: liveViewElement);
  }

  @override
  initState() {
    log.info("begin init live page");
    super.initState();

    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
    );
    future = liveRestClient.listActiveLiveProgram(_pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    log.info("begin build live page");
    FutureBuilder<List<LiveProgramInfo>> futureBuilder = FutureBuilder(
        future: future,
        builder: (BuildContext buildContext,
            AsyncSnapshot<List<LiveProgramInfo>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            List<LiveProgramInfo>? parsedData = snapshot.data;
            log.info(
                "liveProgramInfo future data is ready, will add live info to list and build livePageView");
            _addLive(parsedData);

            return PageView.builder(
              itemCount: _maxLoadCount,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                if (index == _loadCount - 1) {
                  _loadMorectiveLive();
                  return;
                }
              },
              controller: _pageController,
              allowImplicitScrolling: false,
              padEnds: true,
              reverse: false,
              itemBuilder: (context, index) {
                if (_loadCount == 0) {
                  // Expanded(
                  //     child: );
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("当前没有直播"),
                          const SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: _pubLive, child: const Text("开始直播"))
                        ]),
                  );
                }
                if (!_joinFlag) {
                  LiveProgramInfo liveProgramInfo =
                      activeliveProgramInfo[index % _loadCount];
                  var userId = liveProgramInfo.createUserId;
                  // var buttonName = "加入${userId}的直播";
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Text("当前没有直播"),
                          // const SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: _joinLive,
                              child: Text("加入${userId}的直播"))
                        ]),
                  );
                }
                LiveProgramInfo liveProgramInfo =
                    activeliveProgramInfo[index % _loadCount];

                return _buildLiveElement(liveProgramInfo, index);
              },
            );
          }
          return Container();
        });

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: futureBuilder),
          // ElevatedButton(
          //     onPressed: _listOtherLive, child: const Text("查询现在进行的直播")),
          // Expanded(child: ElevatedButton(onPressed: _pubLive(), child: const Text("开始直播"))),
        ],
      ),
    );
  }

  _pubLive() {
    liveRestClient.pubLive().then((liveProgramInfo) {
      log.info(
          "pub live finished, add liveProgramInfo to list and rebuild livePage");
      String roomId = liveProgramInfo.liveAddress["roomId"];

      _joinFlag = true;
      _pubFlag = true;
      log.info("pub live finish the room $roomId ");
      setState(() => _addLive([liveProgramInfo]));
    });
  }

  _listOtherLive() {
    liveRestClient.listActiveLiveProgram(_pageIndex).then((value) {
      setState(() {
        _addLive(value);
      });
    });
  }

  _liveCloseCallback(String roomId, int index, bool closeFlag) {
    _joinFlag = false;
    _pubFlag = false;
    int removeIndex = index % _loadCount;
    LiveProgramInfo? liveProgramInfo;
    if (closeFlag) {
      if (activeliveProgramInfo.isNotEmpty) {
//退出后不一定要移除,但是直播关闭时移除
        liveProgramInfo = activeliveProgramInfo.removeAt(removeIndex);
      }
    } else {
      liveProgramInfo = activeliveProgramInfo[index];
    }

    if (liveProgramInfo == null) {
      log.info("liveProgramInfo is null, skipping callback.");
      return;
    }

    log.info(
        "live has close,do _liveCloseCallback,remove closed live ，the removeIndex $removeIndex, the roomId $roomId, the index $index ");
    if (liveProgramInfo.liveRoomId != roomId) {
      log.info(
          "under liveCloseCallback, the callback roomId not equals liveProgramInfo.roomId, the callback roomId $roomId the liveProgramInfo.roomId ${liveProgramInfo.liveRoomId}");
      // return;
    }

    setState(() {
      _loadCount = activeliveProgramInfo.length;
    });
  }
}

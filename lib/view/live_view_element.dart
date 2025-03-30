import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:muses_app/models/index.dart';
import 'package:muses_app/view/controller/live_controller.dart';

import '../client/socket_io_client.dart';
import '../util/common_logger.dart';

class RtcPeerRendererStream {
  RTCVideoRenderer rtcVideoRenderer;
  RTCPeerConnection rtcPeerConnection;
  bool pubFlag;
  String streamId;

  Widget? liveWidget;

  RtcPeerRendererStream(this.rtcPeerConnection, this.rtcVideoRenderer,
      this.pubFlag, this.streamId);
}

/**
 * 组件的基本逻辑
 * 拿到房间的信息，然后加入，如果是主播，则pub流，如果是观众，则sub所有pub的流，每当有新的流pub，自动sub
 * 
 * 这个页面太长了，必须要拆分，拆分的思想是
 * 页面view控制显示的式样，即页面的布局，如长宽，颜色
 * 页面的按钮的事件在页面里注册，但是事件的逻辑通过调用controller来控制，页面组装时需要的数据也从controller获取
 * controller分为连接控制controller, 直播行令控制controller
 * 
 */
class LiveViewElement extends StatefulWidget {
  bool pubFlag;

  //直播间数据
  String roomId;
  String userId;
  String connectUrl;
  String connectionId;
  String token;

  int liveViewElementIndex;
  Function closeCallback;

  LiveViewElement({
    super.key,
    this.pubFlag = false,
    required this.roomId,
    required this.userId,
    required this.connectUrl,
    required this.connectionId,
    required this.token,
    required this.closeCallback,
    required this.liveViewElementIndex,
  });

  @override
  State<LiveViewElement> createState() {
    return _LiveViewElementState();
  }
}

class _LiveViewElementState extends State<LiveViewElement> {
  // //true pub，false sub
  // late SocketIoClient socketIoClient;

  // int streamCount = 0;

  // final Map<String, String> _userMap = {};

  // //服务器配置
  // late bool audio;
  // late Map<String, dynamic> videoMandatory;

  // //RTC模型
  // late MediaStream _mediaStream;
  // //自己发布的流
  // Map<String, RtcStream> pubStreamMap = {};
  // //value为RtcPeerConnection和rtcVideoRender的pair
  // Map<String, RtcPeerRendererStream> pubPeerMap = {};
  // //自己用来订阅的流，还有别人用来订阅自己的流
  // Map<String, RtcStream> subStreamMap = {};
  // Map<String, RtcPeerRendererStream> subPeerMap = {};

  //显示rtc视频的widget
  List<Widget> rtcVideoViewList = [];

  // bool initiativeCloseFlag = false;
  // bool liveCloseFlag = false;

  //============================新加的属性======================================
  late LiveController liveController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log.info("will initialize all liveViewElement");
    log.info(
        "the liveViewElement roomId is ${widget.roomId} the userId is ${widget.userId}");
    // _initLiveElement();
    liveController = LiveController();
    liveController.roomId = widget.roomId;
    liveController.userId = widget.userId;
    liveController.connectUrl = widget.connectUrl;
    liveController.connectionId = widget.connectionId;
    liveController.token = widget.token;
    liveController.liveViewElementIndex = widget.liveViewElementIndex;
    liveController.closeCallback = widget.closeCallback;
    liveController.updateLiveLayoutCallback = updateLiveLayoutCallback;
    liveController.pubFlag = widget.pubFlag;
    liveController.initLiveController();
  }

  @override
  void didUpdateWidget(LiveViewElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    log.info("will execute didUpdateWidget in liveViewElement");
    log.info(
        "the liveViewElement roomId is ${widget.roomId} the userId is ${widget.userId}");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log.info("will execute didChangeDependencies in liveViewElement");
  }

  // _initLiveElement() async {
  //   _initConnection();
  //   _doEnterRoom(widget.roomId, widget.connectionId, widget.connectionId);
  //   if (!widget.pubFlag) {
  //     initRenderers();
  //   }
  // }

  // void initRenderers() async {
  //   pubPeerMap.forEach((key, value) async {
  //     await value.rtcVideoRenderer.initialize();
  //   });
  //   subPeerMap.forEach((key, value) async {
  //     await value.rtcVideoRenderer.initialize();
  //   });
  // }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    log.info(
        "widget on deactive, wille dispose all rtcVideoRender and close socketIoClient");
    liveController.doCloseLiveResource();
  }

  @override
  Widget build(BuildContext context) {
    log.info(
        "will build the liveViewElement's scaffold，the pub flag is ${widget.pubFlag} ,the live widget list length is ${rtcVideoViewList.length}");
    return Scaffold(
      body: Stack(
        children: [
          // 下层：视频网格居中显示
          Positioned.fill(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight:
                      MediaQuery.of(context).size.height - 100, // 为按钮预留底部空间
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: rtcVideoViewList.length,
                  itemBuilder: (context, index) => rtcVideoViewList[index],
                ),
              ),
            ),
          ),

          // 上层：悬浮底部按钮
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            backgroundColor:
                                const Color.fromARGB(255, 242, 232, 235),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          onPressed: _openCameraAndPubStream,
                          child: const Text(
                            "直播上麦",
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            backgroundColor:
                                const Color.fromARGB(255, 242, 232, 235),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          onPressed: _hangUpPubStream,
                          child: const Text(
                            "挂断连麦",
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            backgroundColor:
                                const Color.fromARGB(255, 242, 232, 235),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          onPressed: _leaveLive,
                          child: const Text(
                            "退出直播",
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            backgroundColor:
                                const Color.fromARGB(255, 242, 232, 235),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                          onPressed: _closeLive,
                          child: const Text(
                            "结束直播",
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        ),
                      )),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
//=======================================按钮事件===============================================

  void _openCameraAndPubStream() async {
    liveController.openCameraAndPubStream();
  }

  _hangUpPubStream() async {
    liveController.hangUpPubStream();
  }

  _leaveLive() async {
    liveController.leaveLive();
  }

  _closeLive() async {
    liveController.closeLive();
  }

  void updateLiveLayoutCallback() {
    int count = 4;
    liveController.pubPeerMap.forEach((key, value) {
      if (!value.pubFlag) {
        return;
      }
      count++;
    });
    liveController.subPeerMap.forEach((key, value) {
      if (value.pubFlag) {
        return;
      }
      count++;
    });
    log.info(
        "will add videoRender into the liveViewElement, the add count is $count");
    List<Widget> tempRtcVideoViewList = [];
    liveController.pubPeerMap.forEach((key, value) {
      if (!value.pubFlag) {
        log.info(
            "this stream not pubStream, streamId is $key the rtcPeerRenderer streamId is ${value.streamId}");
        return;
      }
      var rtcVideoRender = value.rtcVideoRenderer;
      value.liveWidget = Container(
        // margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        // Todo 这里不设置这个宽高会不会有问题？
        width: 200,
        height: 200,
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height / count,
        decoration: const BoxDecoration(color: Colors.black54),
        child: RTCVideoView(rtcVideoRender, mirror: true),
      );
      tempRtcVideoViewList.add(value.liveWidget!);
    });
    log.info("list sub live view page, will add subStream to widget list");
    liveController.subPeerMap.forEach((key, value) {
      if (value.pubFlag) {
        log.info(
            "this stream not subStream,won't add widget, streamId is $key the rtcPeerRenderer streamId is ${value.streamId}");
        return;
      }
      var rtcVideoRender = value.rtcVideoRenderer;
      value.liveWidget = Container(
        // margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        // width: MediaQuery.of(context).size.width,
        // height: MediaQuery.of(context).size.height / count,
        decoration: const BoxDecoration(color: Colors.black54),
        child: RTCVideoView(rtcVideoRender, mirror: true),
      );
      tempRtcVideoViewList.add(value.liveWidget!);
    });
    log.info("add rtcvideoView finish, init all rtcVideoRender");

    liveController.initRenderers();
    liveController.rtcVideoViewList = tempRtcVideoViewList;

    setState(() {
      log.info("live info change, will update the live layout");
      rtcVideoViewList = tempRtcVideoViewList;
    });
  }
}

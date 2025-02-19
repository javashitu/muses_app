import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:muses_app/models/index.dart';

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
  //true pub，false sub
  late SocketIoClient socketIoClient;

  int streamCount = 0;

  final Map<String, String> _userMap = {};

  //服务器配置
  late bool audio;
  late Map<String, dynamic> videoMandatory;

  //RTC模型
  late MediaStream _mediaStream;
  Map<String, RtcStream> pubStreamMap = {};
  //value为RtcPeerConnection和rtcVideoRender的pair
  Map<String, RtcPeerRendererStream> pubPeerMap = {};

  Map<String, RtcStream> subStreamMap = {};
  Map<String, RtcPeerRendererStream> subPeerMap = {};

  //显示rtc视频的widget
  List<Widget> rtcVideoViewList = [];

  bool initiativeCloseFlag = false;
  bool liveCloseFlag = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log.info("will initialize all liveViewElement");
    log.info(
        "the liveViewElement roomId is ${widget.roomId} the userId is ${widget.userId}");
    _initLiveElement();
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

  _initLiveElement() async {
    _initConnection();
    _doEnterRoom(widget.roomId, widget.connectionId, widget.connectionId);
    if (!widget.pubFlag) {
      initRenderers();
    }
  }

  void initRenderers() async {
    pubPeerMap.forEach((key, value) async {
      await value.rtcVideoRenderer.initialize();
    });
    subPeerMap.forEach((key, value) async {
      await value.rtcVideoRenderer.initialize();
    });
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    log.info(
        "widget on deactive, wille dispose all rtcVideoRender and close socketIoClient");
    _doCloseLiveViewElement();
  }

  @override
  Widget build(BuildContext context) {
    log.info(
        "will build the liveViewElement's scaffold，the pub flag is ${widget.pubFlag}");
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Expanded(child: Column(children: rtcVideoViewList)),
          Container(
                  // margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: 300,
                  height: 30,
                  child: ElevatedButton(
                      onPressed: _openCameraAndPubStream,
                      child: Text("已经进入直播间我也要发布视频")))
        ],
      )),
    );
  }

//=======================================回调父组件事件===============================================
  void _onConnectionClose() {
    log.info(
        "connection has close, check whether need close liveElement resource");

    if (initiativeCloseFlag) {
      log.info(
          "initiativeClose liveElement, not need close liveElement resource");
      return;
    }
    _closeLiveResource();
  }

//=======================================回调父组件事件===============================================

//=======================================初始化事件===============================================

  void _initConnection() {
    socketIoClient = SocketIoClient(
        connectUrl: widget.connectUrl,
        connectionId: widget.connectionId,
        roomId: widget.roomId,
        token: widget.token,
        messageHandler: _dispatchMessage,
        closeHndler: _onConnectionClose);
    socketIoClient.connect();
  }

  _executeQuietly(Function func) {
    log.info("quietly execute func begin ");
    try {
      func();
      log.info("quietly execute func end ");
    } catch (error, stackTrace) {
      log.info("quietly execute func error ");

      log.info(
          "execute func catch error $error \r\n and the trace $stackTrace");
    }
  }

  _doCloseLiveViewElement() {
    log.info(
        "doCloseLiveViewElement， will close all connection and then close liveViewElement's resourrce ");
    initiativeCloseFlag = true;
    _executeQuietly(() {
      LeaveReq leaveReq = LeaveReq();
      leaveReq.protoType = "leave";
      leaveReq.roomId = widget.roomId;
      leaveReq.userId = widget.userId;
      leaveReq.userName = widget.userId;
      socketIoClient.close(leaveReq);
    });
    _closeLiveResource();
  }

  _closeLiveResource() {
    log.info(
        "begin close live resource,include peerConnection and videoRender ");
    //处于deactive阶段不用重新rebuild
    if (pubPeerMap.isNotEmpty) {
      pubPeerMap.forEach((key, value) {
        _closeRtcPeerRenderer(key, value);
      });
    }
    if (subPeerMap.isNotEmpty) {
      subPeerMap.forEach((key, value) {
        _closeRtcPeerRenderer(key, value);
      });
    }
    if (liveCloseFlag) {
      log.info("live has close, will callback to live page");
      widget.closeCallback(widget.roomId, widget.liveViewElementIndex);
    }
  }

//=======================================初始化事件===============================================
//=======================================按钮事件===============================================

  void _openCameraAndPubStream() async {
    var mediaContraints = {"audio": audio, "video": videoMandatory};
    try {
      log.info("begin get all user media then pub stream");
      _mediaStream = await navigator.mediaDevices.getUserMedia(mediaContraints);

      RTCPeerConnection rtcPeerConnection =
          await createPeerConnection({"iceServer": []});
      RTCVideoRenderer rtcVideoRenderer = RTCVideoRenderer();
      rtcVideoRenderer.srcObject = _mediaStream;

      _mediaStream.getTracks().forEach((track) {
        rtcPeerConnection.addTrack(track, _mediaStream);
      });
      var pubStreamId = _genPubStreamId();

      pubPeerMap.putIfAbsent(
          pubStreamId,
          () => RtcPeerRendererStream(
              rtcPeerConnection, rtcVideoRenderer, true, pubStreamId));
      _rebuildRTCVideoView();

      rtcPeerConnection.createOffer({}).then((offer) {
        rtcPeerConnection.setLocalDescription(offer);

        PubReq pubReq = PubReq();
        pubReq.protoType = "pub";
        pubReq.signalType = "offer";
        pubReq.signalMessage = offer.toMap();
        pubReq.roomId = widget.roomId;
        pubReq.userId = widget.userId;

        var pubStream = {
          "streamId": pubStreamId,
          "userId": widget.userId,
          "pubFlag": true,
          "audio": true,
          "video": true
        };

        pubReq.pubStream = pubStream;
        pubReq.subStream = "";
        log.info("emit to server pubReq");
        socketIoClient.emit(pubReq);
      });
    } catch (e) {
      log.info(e.toString());
    }
  }

  _doEnterRoom(String roomId, String userId, String userName) async {
    var enterReq = EnterReq();
    enterReq.protoType = "enter";
    enterReq.roomId = roomId;
    enterReq.userId = userId;
    enterReq.userName = userId;
    log.info("emit to server enterReq");
    socketIoClient.emit(enterReq);
  }

  _doSubStream(String pubUserId, String pubStreamId) {
    log.info(
        "will sub stream for user $pubUserId the be pubStreamId -> $pubStreamId");
    var subStreamId = _genSubStreamId();

    var pubStream = {
      "streamId": pubStreamId,
      "userId": pubUserId,
      "pubFlag": true,
      "audio": true,
      "video": true
    };

    var subStream = {
      "streamId": subStreamId,
      "userId": widget.userId,
      "pubFlag": false,
      "audio": true,
      "video": true
    };

    SubReq subReq = SubReq();
    subReq.protoType = "sub";
    subReq.roomId = widget.roomId;
    subReq.userId = widget.userId;
    subReq.signalType = "";
    subReq.pubStream = pubStream;
    subReq.subStream = subStream;
    subReq.signalMessage = {};

    log.info(
        "send sub message to server no offer or answer only notify anchor init peerConnection");
    socketIoClient.emit(subReq);
  }

  String _genSubStreamId() {
    return "sub_${widget.userId}_${DateTime.now().millisecond}_${streamCount++}";
  }

  String _genPubStreamId() {
    return "pub_${widget.userId}_${DateTime.now().millisecond}_${streamCount++}";
  }

  bool isPubStreamId(String streamId) {
    return streamId.startsWith("pub_");
  }

  _rebuildRTCVideoView() {
    int count = 4;
    pubPeerMap.forEach((key, value) {
      if (!value.pubFlag) {
        return;
      }
      count++;
    });
    subPeerMap.forEach((key, value) {
      if (value.pubFlag) {
        return;
      }
      count++;
    });
    log.info(
        "will add videoRender into the liveViewElement, the add count is $count");
    List<Widget> tempRtcVideoViewList = [];
    pubPeerMap.forEach((key, value) {
      if (!value.pubFlag) {
        log.info(
            "this stream not pubStream, streamId is $key the rtcPeerRenderer streamId is ${value.streamId}");
        return;
      }
      var rtcVideoRender = value.rtcVideoRenderer;
      value.liveWidget = Container(
        // margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / count,
        decoration: const BoxDecoration(color: Colors.black54),
        child: RTCVideoView(rtcVideoRender, mirror: true),
      );
      tempRtcVideoViewList.add(value.liveWidget!);
    });
    log.info("list sub live view page, will add subStream to widget list");
    subPeerMap.forEach((key, value) {
      if (value.pubFlag) {
        log.info(
            "this stream not subStream,won't add widget, streamId is $key the rtcPeerRenderer streamId is ${value.streamId}");
        return;
      }
      var rtcVideoRender = value.rtcVideoRenderer;
      value.liveWidget = Container(
        // margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / count,
        decoration: const BoxDecoration(color: Colors.black54),
        child: RTCVideoView(rtcVideoRender, mirror: true),
      );
      tempRtcVideoViewList.add(value.liveWidget!);
    });
    log.info("add rtcvideoView finish, init all rtcVideoRender");

    initRenderers();
    setState(() {
      rtcVideoViewList = tempRtcVideoViewList;
    });
  }

//=========================================按钮事件================================================
//=======================================派发事件消息===============================================
  _dispatchMessage(var message) async {
    String protoType = message["protoType"];
    log.info("the message protoType is $protoType");
    switch (protoType) {
      case "enterRsp":
        _onEnterRsp(message);
        break;
      case "pubRsp":
        _onPubRsp(message);
        break;
      default:
        _dispatchEvent(message);
    }
  }

  void _dispatchEvent(var event) {
    String protoType = event["protoType"];
    switch (protoType) {
      case "enterEvent":
        _onEnterEvent(event);
        break;
      case "pubEvent":
        _dispatchSignal(event);
        break;
      case "subEvent":
        _dispatchSignal(event);
        break;
      case "negoEvent":
        _dispatchSignal(event);
        break;
      case "closeEvent":
        _onCloseEvent(event);
        break;
      case "leaveEvent":
        _onLeaveEvent(event);
      default:
        log.info(
            "can't dispatch the event, maybe no release feature,ignore the event");
    }
  }

  void _dispatchSignal(var event) async {
    switch (event["signalType"]) {
      case "offer":
        _onReceiveOffer(event);
        break;
      case "answer":
        _onReceiveAnswer(event);
        break;
      case "ice":
        _onReceiveIce(event);
        break;
      default:
        log.info(
            "no signal, it's a sub message, will init a rtcPeerConnection for sub");
        _initPCForSub(event);
    }
  }

  void _onEnterRsp(var event) async {
    log.info("receive enterRsp, will init some info ");
    EnterRsp enterRsp = EnterRsp.fromJson(event);
    var config = enterRsp.peerConfig;
    videoMandatory = enterRsp.flutterRtcMediaConf["videoMandatory"];
    audio = enterRsp.flutterRtcMediaConf["audio"];
    log.info("the serverPeer config is $config");
    if (enterRsp.userPubMap.isNotEmpty) {
      log.info("something one has pubStream,doSub");
      enterRsp.userPubMap.forEach((String key, dynamic value) {
        if (key == widget.userId) {
          log.info("this stream is pub by myself, can't sub");
          return;
        }
        for (var pubStreamId in (value as List<dynamic>)) {
          _doSubStream(key, pubStreamId);
        }
      });
    }
    if (enterRsp.anchorFlag) {
      log.info("enter room success, i'm anchor will pub stream");
      _openCameraAndPubStream();
    }
  }

  _onPubRsp(event) {
    log.info("receive pubRsp ");
  }

  _onCloseEvent(event) {
    log.info("receive closeEvent ");
    liveCloseFlag = true;
    _doCloseLiveViewElement();
  }

  _onLeaveEvent(event) {
    log.info("receive leaveEvent ");
    LeaveEvent leaveEvent = LeaveEvent.fromJson(event);
    if (leaveEvent.hangUpStreamId != null &&
        leaveEvent.hangUpStreamId!.isNotEmpty) {
      for (var streamId in leaveEvent.hangUpStreamId!) {
        _closeStream(streamId);
      }
    }
    if (leaveEvent.closePeerConnectionList != null &&
        leaveEvent.closePeerConnectionList!.isNotEmpty) {
      leaveEvent.closePeerConnectionList!.forEach((sreamId) {
        RtcPeerRendererStream? rtcPeerRendererPair = subPeerMap[sreamId];
        if (rtcPeerRendererPair != null) {
          log.info(
              "when leave event, close peerConnection is subStream peerConnection, will remove from subPeerMap");
          _closeRtcPeerRenderer(sreamId, rtcPeerRendererPair);
        } else {
          rtcPeerRendererPair = pubPeerMap[sreamId];
          if (rtcPeerRendererPair != null) {
            log.info(
                "when leave event, close peerConnection is pubStream peerConnection, will remove from pubPeerMap");
            _closeRtcPeerRenderer(sreamId, rtcPeerRendererPair);
          } else {
            log.info(
                "when leave event, can't find the peerConnection of streamId subStreamId");
          }
        }
      });
    }
    _rebuildRTCVideoView();
  }

  void _onEnterEvent(event) async {
    log.info("receive enter event");
    EnterEvent enterEvent = EnterEvent.fromJson(event);
    _userMap.putIfAbsent(enterEvent.userId, () => enterEvent.userId);
  }

  _onReceiveOffer(event) async {
    log.info("receive offer, event carry offer");
    String subStreamId;
    RTCSessionDescription offer;
    RtcStream subStream;
    Map<String, dynamic> curPubStreamMap;
    if (event["protoType"] == "pubEvent") {
      log.info("this is pub event, will sub the pubStream");
      PubEvent pubEvent = PubEvent.fromJson(event);
      subStreamId = _genSubStreamId();
      offer = RTCSessionDescription(
          pubEvent.signalMessage["sdp"], pubEvent.signalMessage["type"]);
      subStream = RtcStream();
      subStream.streamId = subStreamId;
      subStream.userId = widget.userId;
      subStream.pubFlag = false;
      subStream.audio = true;
      subStream.video = true;
      curPubStreamMap = pubEvent.pubStream;
    } else {
      log.info("this is sub event, will deserialize subStream");

      SubEvent subEvent = SubEvent.fromJson(event);
      subStream = RtcStream.fromJson(subEvent.subStream);
      curPubStreamMap = subEvent.pubStream;
      subStreamId = subStream.streamId;
      offer = RTCSessionDescription(
          subEvent.signalMessage["sdp"], subEvent.signalMessage["type"]);
    }
    var rtcPeerConnection = await createPeerConnection({"iceServer": []});
    RTCVideoRenderer rtcVideoRenderer = RTCVideoRenderer();
    subPeerMap.putIfAbsent(
        subStreamId,
        () => RtcPeerRendererStream(
            rtcPeerConnection, rtcVideoRenderer, false, subStreamId));

    rtcPeerConnection.setRemoteDescription(offer);
    //以订阅的人的流id为标识，表示这个订阅的人和主播建立的连接关系
    subStreamMap.putIfAbsent(subStreamId, () => subStream);
    log.info(
        "receive offer, will create a new rtcPeerConncetion to connect it");

    rtcPeerConnection.createAnswer().then((answer) {
      rtcPeerConnection.setLocalDescription(answer);
      SubReq subReq = SubReq();
      subReq.protoType = "sub";
      subReq.signalType = "answer";
      subReq.signalMessage = answer.toMap();
      subReq.roomId = widget.roomId;
      subReq.userId = widget.userId;
      subReq.pubStream = curPubStreamMap;
      subReq.subStream = subStream.toJson();
      socketIoClient.emit(subReq);
    });
    rtcPeerConnection.onIceCandidate = (event) {
      if (event.candidate != null) {
        log.info(
            "rtcPeerConnection ice candidate ready will send ice to another client, the event is $event");
        var candidateData = {
          "sdpMLineIndex": event.sdpMLineIndex,
          "sdpMid": event.sdpMid,
          "candidate": event.candidate
        };
        NegoReq negoReq = NegoReq();
        negoReq.protoType = "nego";
        negoReq.roomId = widget.roomId;
        negoReq.userId = widget.userId;
        negoReq.userName = widget.userId;
        negoReq.negoPubFlag = false;
        negoReq.signalType = "ice";
        negoReq.signalMessage = candidateData;
        negoReq.pubStream = curPubStreamMap;
        negoReq.subStream = subStream.toJson();
        socketIoClient.emit(negoReq);
      } else {
        log.info("ice is ready but no candidate， ignore this ");
      }
    };

    rtcPeerConnection.onTrack = (event) {
      log.info("remote stream is ready will play remote stream ");
      if (event.track.kind == 'video') {
        setState(() {
          rtcVideoRenderer.srcObject = event.streams[0];
        });
      } else {
        log.info("remote track is ready,but not video, ignore");
      }
    };
    _rebuildRTCVideoView();
  }

  void _onReceiveAnswer(event) async {
    log.info(
        "receive subEvent, remote client sub my stream,save remote answer ");
    SubEvent subEvent = SubEvent.fromJson(event);
    RtcStream subStream = RtcStream.fromJson(subEvent.subStream);
    RtcStream pubStream = RtcStream.fromJson(subEvent.pubStream);
    String curStreamId = subStream.streamId;
    RtcPeerRendererStream? rtcPeerRendererPair = pubPeerMap[curStreamId];
    if (rtcPeerRendererPair == null) {
      log.info(
          "can't find rtcPeerRendererPair by subStreamId, maybe it's a pubStream");
      curStreamId = pubStream.streamId;

      rtcPeerRendererPair = pubPeerMap[curStreamId];
    }
    if (rtcPeerRendererPair == null) {
      log.info("can't find rtcPeerRendererPair by pubStream, something wrong ");
      return;
    }
    log.info("try regist ice candidate");
    pubPeerMap.forEach((streamId, rtcPeerRendererPair) {
      log.info("iterate the pubPeerMap,the streamId is $streamId");
    });

    rtcPeerRendererPair.rtcPeerConnection.setRemoteDescription(
        RTCSessionDescription(
            subEvent.signalMessage["sdp"], subEvent.signalMessage["type"]));
  }

  void _onReceiveIce(event) {
    log.info("receive nego event , the nego event carry ice");
    NegoEvent negoEvent = NegoEvent.fromJson(event);
    RTCIceCandidate rtcIceCandidate = RTCIceCandidate(
        negoEvent.signalMessage["candidate"],
        negoEvent.signalMessage["sdpMid"],
        negoEvent.signalMessage["sdpMLineIndex"]);
    if (negoEvent.negoPubFlag) {
      var subStreamId = negoEvent.subStream["streamId"];
      subPeerMap[subStreamId]!.rtcPeerConnection.addCandidate(rtcIceCandidate);
    } else {
      String curStreamId = negoEvent.subStream["streamId"];
      RtcPeerRendererStream? rtcPeerRendererPair = pubPeerMap[curStreamId];
      if (rtcPeerRendererPair == null) {
        log.info(
            "can't find rtcPeerRenderer by subStreamId, maybe can find by pubStreamId");
        curStreamId = negoEvent.pubStream["streamId"];
        rtcPeerRendererPair = pubPeerMap[curStreamId];
      }
      if (rtcPeerRendererPair == null) {
        log.info("something wrong, can't find the rtcPeerRenderer");
        return;
      }
      rtcPeerRendererPair.rtcPeerConnection.addCandidate(rtcIceCandidate);
    }
  }

  void _initPCForSub(event) async {
    log.info(
        "this is a sub request, but no offer, will create a new rtcPeerConncetion to connect it");
    SubEvent subEvent = SubEvent.fromJson(event);
    var pubStream = subEvent.pubStream;
    var subStream = subEvent.subStream;
    var subStreamId = subStream["streamId"];
    var rtcPeerConnection = await createPeerConnection({"iceServer": []});
    RTCVideoRenderer rtcVideoRenderer = RTCVideoRenderer();

    _mediaStream.getTracks().forEach((track) {
      rtcPeerConnection.addTrack(track, _mediaStream);
    });

    rtcPeerConnection.createOffer({}).then((offer) {
      rtcPeerConnection.setLocalDescription(offer);

      pubPeerMap.putIfAbsent(
          subStreamId,
          () => RtcPeerRendererStream(
              rtcPeerConnection, rtcVideoRenderer, false, subStreamId));
      _rebuildRTCVideoView();

      SubReq subReq = SubReq();
      subReq.protoType = "sub";
      subReq.signalType = "offer";
      subReq.signalMessage = offer.toMap();
      subReq.roomId = widget.roomId;
      subReq.userId = widget.userId;
      subReq.subStream = subStream;

      subReq.pubStream = pubStream;
      log.info("emit to server subReq and carry offer");
      socketIoClient.emit(subReq);
    });

    //在新建之后立刻注册，不要在接收到answer时注册，那个时候可能会注册不成功
    rtcPeerConnection.onIceCandidate = (candidate) {
      log.info("rtc peerconnection ice candidate ready will send ice");
      var candidateData = {
        "sdpMLineIndex": candidate.sdpMLineIndex,
        "sdpMid": candidate.sdpMid,
        "candidate": candidate.candidate
      };
      NegoReq negoReq = NegoReq();
      negoReq.protoType = "nego";
      negoReq.roomId = widget.roomId;
      negoReq.userId = widget.userId;
      negoReq.userName = widget.userId;
      negoReq.negoPubFlag = true;
      negoReq.signalType = "ice";
      negoReq.protoType = "nego";
      negoReq.signalMessage = candidateData;

      negoReq.subStream = subStream;
      negoReq.pubStream = pubStream;
      socketIoClient.emit(negoReq);
    };
  }

  _closeStream(String streamId) {
    _closePubStream(streamId);
    _closeSubStream(streamId);
  }

  _closeSubStream(String streamId) {
    log.info("begin close subStream, will close $streamId");
    subStreamMap.remove(streamId);
    // _closeRtcPeerRenderer(streamId);
    RtcPeerRendererStream? rtcPeerRendererPair = subPeerMap[streamId];
    if (rtcPeerRendererPair != null) {
      log.info("will remove rtcPeerRender in subPeerMap");
      _closeRtcPeerRenderer(streamId, rtcPeerRendererPair);
      subPeerMap.remove(streamId);
    }
  }

  _closeRtcPeerRenderer(
      String streamId, RtcPeerRendererStream rtcPeerRendererPair) {
    log.info("begin close rtcPeerRenderer, by streamId $streamId");
    rtcPeerRendererPair.rtcPeerConnection.close();
    rtcPeerRendererPair.rtcPeerConnection.dispose();
    rtcPeerRendererPair.rtcVideoRenderer.srcObject
        ?.getTracks()
        .forEach((track) => track.stop());
    rtcPeerRendererPair.rtcVideoRenderer.srcObject = null;
    rtcPeerRendererPair.rtcVideoRenderer.dispose();
    if (rtcPeerRendererPair.liveWidget != null) {
      log.info("will remove liveWiget");
      rtcVideoViewList.remove(rtcPeerRendererPair.liveWidget);
    } else {
      log.info("can't find live widget");
    }
  }

  _closePubStream(String streamId) {
    log.info(
        "begin close pubStream, will close pubStream and peerConnection and rtcVideoRendererof  $streamId");
    pubStreamMap.remove(streamId);
    RtcPeerRendererStream? rtcPeerRendererPair = pubPeerMap[streamId];
    if (rtcPeerRendererPair != null) {
      log.info("will close peerRender which in pubPeerMap");
      _closeRtcPeerRenderer(streamId, rtcPeerRendererPair);
      pubPeerMap.remove(streamId);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:muses_app/models/index.dart';
import 'package:muses_app/util/func_utils.dart';
import 'package:muses_app/view/live_view_element.dart';

import '../../client/socket_io_client.dart';
import '../../util/common_logger.dart';

class LiveController {
//: connectUrl,
  late String connectUrl;
  // connectionId,
  late String connectionId;
  // roomId,
  late String roomId;
  //: token,
  late String token;
  //: userId,
  late String userId;

  late int liveViewElementIndex;

  late Function closeCallback;

  late Function updateLiveLayoutCallback;

  late bool pubFlag;
//===========================以上字段是新加的=================================

  //true pub，false sub
  late SocketIoClient socketIoClient;

  int streamCount = 0;

  final Map<String, String> _userMap = {};

  //服务器配置
  late bool audio;
  late Map<String, dynamic> videoMandatory;

  //RTC模型
  late MediaStream _mediaStream;
  //自己发布的流
  Map<String, RtcStream> pubStreamMap = {};
  //value为RtcPeerConnection和rtcVideoRender的pair
  Map<String, RtcPeerRendererStream> pubPeerMap = {};
  //自己用来订阅的流，还有别人用来订阅自己的流
  Map<String, RtcStream> subStreamMap = {};
  Map<String, RtcPeerRendererStream> subPeerMap = {};

  //显示rtc视频的widget
  List<Widget> rtcVideoViewList = [];

  // bool initiativeCloseFlag = false;

  bool liveCloseFlag = false;
/**
 * 方法编写的基本思想
 * 1. controller负责维护直播需要的数据，包括连接，流，rtcPeerConnection
 * 2. controller触发的事件可以直接改变controller的属性，在每个改变的方法内部，再决定要不要通知到上游组件刷新布局
 * 3. 页面可能会退出或者因为某些原因改变，这个时候直接调用对应的针对这种改变定制的方法，不要复用
 * 
 */
//=======================================回调父组件事件===============================================
  /**
   * 不在连接断开的回调里关闭直播资源，而是根据收到的事件和按钮事件来决定关闭顺序
   */
  void _onConnectionClose() {
    log.info(
        "connection has close, check whether need close liveElement resource");

    // if (initiativeCloseFlag) {
    //   log.info(
    //       "initiativeClose liveElement, not need close liveElement resource");
    //   return;
    // }
    // _closeLiveResource();
  }

//=======================================回调父组件事件===============================================

//=======================================初始化事件===============================================

  initLiveController() async {
    _initConnection();
    _doEnterRoom(roomId, connectionId, connectionId);
    //todo 这行代码有啥用？
    // if (!pubFlag) {
    // initRenderers();
    // }
  }

  void _initConnection() {
    socketIoClient = SocketIoClient(
        connectUrl: connectUrl,
        connectionId: connectionId,
        roomId: roomId,
        token: token,
        messageHandler: _dispatchMessage,
        closeHndler: _onConnectionClose);
    socketIoClient.connect();
  }

//=======================================初始化事件===============================================
//=======================================按钮事件===============================================

  void openCameraAndPubStream() async {
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
        pubReq.roomId = roomId;
        pubReq.userId = userId;

        RtcStream pubStream = RtcStream();
        pubStream.streamId = pubStreamId;
        pubStream.userId = userId;
        pubStream.pubFlag = true;
        pubStream.audio = true;
        pubStream.video = true;
        pubStreamMap[pubStreamId] = pubStream;

        pubReq.pubStream = pubStream.toJson();
        pubReq.subStream = "";
        log.info("emit to server pubReq");
        socketIoClient.emit(pubReq);
      });
    } catch (e) {
      log.info(e.toString());
    }
  }

  hangUpPubStream() async {
    log.info("will hang up the stream by pub nearlly ");
    //这里就按照发布时间的顺序，挂断最近发布的流，一般的SDK逻辑是挂断指定的流，所以我挂断时需要根据流id去挂断
    var pubStreamId;
    for (var key in pubStreamMap.keys.toList().reversed) {
      log.info("the last pubStream is $key ,the pubStream will close ");
      pubStreamId = key;
      break;
    }
    HangUpReq hangUpReq = HangUpReq();
    hangUpReq.protoType = "hangUp";
    hangUpReq.pubStreamFlag = true;
    hangUpReq.roomId = roomId;
    hangUpReq.userId = userId;
    hangUpReq.userName = userId;
    hangUpReq.streamId = pubStreamId;
    socketIoClient.emit(hangUpReq);
    _closePubStream(pubStreamId);
    _rebuildRTCVideoView();
  }

  leaveLive() async {
    log.info("leave the live room, and hang up my stream  ");
    LeaveReq leaveReq = LeaveReq();
    leaveReq.protoType = "leave";
    leaveReq.roomId = roomId;
    leaveReq.userId = userId;
    leaveReq.userName = userId;
    socketIoClient.emit(leaveReq);
    pubStreamMap.keys.toList().forEach(((pubstreamId) {
      log.info("will close the pubStream $pubstreamId");
      _closePubStream(pubstreamId);
    }));
    subStreamMap.keys.toList().forEach((subStreamId) {
      log.info("will close the subStream $subStreamId");
      _closeSubStream(subStreamId);
    });
    _rebuildRTCVideoView();
    closeCallback(roomId, liveViewElementIndex, false);
  }

  /**
   * 关闭直播，先发送关闭的消息，发送成功即认为可以关闭所有流
   * 然后关闭本地的所有流，并且刷新布局,有个问题是否在这里关闭连接？理论上可以关闭，如果关闭，服务器发送数据会失败。
   * 服务器收到关闭直播的信息后会广播到所有人关闭事件，收到关闭事件后再断开发送行令的连接
   * 
   */
  closeLive() async {
    log.info("close the live room, and hang up all stream  ");
    CloseReq closeReq = CloseReq();
    closeReq.protoType = "close";
    closeReq.roomId = roomId;
    closeReq.userId = userId;
    closeReq.userName = userId;
    socketIoClient.emit(closeReq);
    pubStreamMap.keys.toList().forEach(((pubstreamId) {
      log.info("will close the pubStream $pubstreamId");
      _closePubStream(pubstreamId);
    }));
    subStreamMap.keys.toList().forEach((subStreamId) {
      log.info("will close the subStream $subStreamId");
      _closeSubStream(subStreamId);
    });
    liveCloseFlag = true;
    _rebuildRTCVideoView();
    closeCallback(roomId, liveViewElementIndex, true);
  }
//=========================================按钮事件================================================

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
      "userId": userId,
      "pubFlag": false,
      "audio": true,
      "video": true
    };

    SubReq subReq = SubReq();
    subReq.protoType = "sub";
    subReq.roomId = roomId;
    subReq.userId = userId;
    subReq.signalType = "";
    subReq.pubStream = pubStream;
    subReq.subStream = subStream;
    subReq.signalMessage = {};

    log.info(
        "send sub message to server no offer or answer only notify anchor init peerConnection");
    socketIoClient.emit(subReq);
  }

  _rebuildRTCVideoView() {
    updateLiveLayoutCallback();
  }

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
      case "hangUpEvent":
        _onHangUpEvent(event);
        break; // Add this missing break
      case "closeEvent":
        _onCloseEvent(event);
        break;
      case "leaveEvent":
        _onLeaveEvent(event);
        break;
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
        if (key == userId) {
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
      openCameraAndPubStream();
    }
  }

  _onPubRsp(event) {
    log.info("receive pubRsp ");
  }

  _onHangUpEvent(event) {
    log.info("receive hangUpEvent");
    //只能收到pub流的hangup，但是pub流hangUp时下发的是sub流的信息
    HangUpEvent hangUpEvent = HangUpEvent.fromJson(event);
    log.info("the deserailize hangUpEvent is $hangUpEvent");
    for (var subStreamId in hangUpEvent.streamId ?? []) {
      _closeSubStream(subStreamId);
    }
    _rebuildRTCVideoView();
  }

  _onCloseEvent(event) {
    log.info("receive closeEvent ");
    // liveCloseFlag = true;
    doCloseLiveResource();
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

  _onEnterEvent(event) async {
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
      subStream.userId = userId;
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
      subReq.roomId = roomId;
      subReq.userId = userId;
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
        negoReq.roomId = roomId;
        negoReq.userId = userId;
        negoReq.userName = userId;
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
        rtcVideoRenderer.srcObject = event.streams[0];
        updateLiveLayoutCallback();
        // setState(() {
        //   rtcVideoRenderer.srcObject = event.streams[0];
        // });
      } else {
        log.info("remote track is ready,but not video, ignore");
      }
    };
    _rebuildRTCVideoView();
  }

  _onReceiveAnswer(event) async {
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

  _onReceiveIce(event) {
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

//=======================================派发事件消息===============================================
//=======================================事件消息协助处理方法===============================================
  _initPCForSub(event) async {
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
      subReq.roomId = roomId;
      subReq.userId = userId;
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
      negoReq.roomId = roomId;
      negoReq.userId = userId;
      negoReq.userName = userId;
      negoReq.negoPubFlag = true;
      negoReq.signalType = "ice";
      negoReq.protoType = "nego";
      negoReq.signalMessage = candidateData;

      negoReq.subStream = subStream;
      negoReq.pubStream = pubStream;
      socketIoClient.emit(negoReq);
    };
  }

  /**
   * 收到closeEvent时执行关闭直播资源，页面销毁时也执行关闭直播资源(包括挂断流和关闭连接)
   * 资源只能被关闭一次
   * 如果通过按钮点击主动关闭资源，然后关闭页面，页面关闭时还会回调到这里，所以要在这里判断是不是已经关闭一次了。也就是还说主动关闭时需要先关闭掉本地除了连接以外的资源并且重新刷新页面布局
   * 如果收到了其他方的关闭直播请求，这个时候要关闭所有资源
   * 
   */
  doCloseLiveResource() {
    log.info(
        "do close live will close all connection and then close live resourrce ");
    if (liveCloseFlag) {
      //只做最后的连接断开，主动关闭直播时，本地资源其实已经释放，这个时候只需要关闭连接即可
      socketIoClient.closeQuietly();
      return;
    }
    liveCloseFlag = true;
    FuncUtils.executeQuietly(() {
      LeaveReq leaveReq = LeaveReq();
      leaveReq.protoType = "leave";
      leaveReq.roomId = roomId;
      leaveReq.userId = userId;
      leaveReq.userName = userId;
      socketIoClient.close(leaveReq);
    });
    _closeAllLiveStream();
    log.info("live has close, will callback to live page");
    closeCallback(roomId, liveViewElementIndex, true);
  }

  String _genSubStreamId() {
    return "sub_${userId}_${DateTime.now().millisecond}_${streamCount++}";
  }

  String _genPubStreamId() {
    return "pub_${userId}_${DateTime.now().millisecond}_${streamCount++}";
  }

  bool isPubStreamId(String streamId) {
    return streamId.startsWith("pub_");
  }
//=======================================事件消息协助处理方法===============================================
/**
 * 带close的方法都会实际的关闭并且移除需要关闭的对象
 */
//=======================================原子方法，初始化或者销毁释放某个资源===============================================

  /**
   * 关闭直播的所有资源
   */
  _closeAllLiveStream() {
    log.info(
        "begin close live resource,include peerConnection and videoRender ");
    //处于deactive阶段不用重新rebuild
    if (pubPeerMap.isNotEmpty) {
      for (String streamId in pubStreamMap.keys.toList()) {
        _closePubStream(streamId);
      }
    }
    if (subPeerMap.isNotEmpty) {
      for (String streamId in subStreamMap.keys.toList()) {
        _closeSubStream(streamId);
      }
    }
  }

  _closeStream(String streamId) {
    _closePubStream(streamId);
    _closeSubStream(streamId);
  }

  _closeRtcPeerRenderer(
      String streamId, RtcPeerRendererStream rtcPeerRendererPair) {
    log.info("begin close rtcPeerRenderer, by streamId $streamId");
    rtcPeerRendererPair.rtcPeerConnection.close();
    rtcPeerRendererPair.rtcPeerConnection.dispose();

    //这里分别断开了每个轨道，如果一个人sub了同一个人多次，这里的断开是不是有问题
    //还真有这个问题，这里就不断开轨道，直接销毁peerConnection了，但是不断开是不是也有问题？
    // rtcPeerRendererPair.rtcVideoRenderer.srcObject
    //     ?.getTracks()
    //     .forEach((track) => track.stop());
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
    //todo 更改了原本的逻辑，让刷新布局放到了实际的事件和函数里，而不是底层的流信息变更时
    // _rebuildRTCVideoView();
  }

  _closeSubStream(String streamId) {
    log.info("begin close subStream, will close $streamId");
    log.info(
        "before close subStream, print the map, the subStreamMap $subStreamMap ,the subPeerMap $subPeerMap");
    subStreamMap.remove(streamId);
    RtcPeerRendererStream? rtcPeerRendererPair = subPeerMap[streamId];
    if (rtcPeerRendererPair != null) {
      log.info("will remove rtcPeerRender in subPeerMap");
      _closeRtcPeerRenderer(streamId, rtcPeerRendererPair);
      subPeerMap.remove(streamId);
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
//=======================================原子方法，初始化或者销毁释放某个资源===============================================
}

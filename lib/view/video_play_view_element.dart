import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../client/video_rest_client.dart';
import '../util/common_logger.dart';

class VideoPlayViewElement extends StatefulWidget {
  final String videoUrl;
  int pageIndex = 0;


  VideoPlayViewElement({super.key, required this.videoUrl, this.pageIndex = 0});

  @override
  State<VideoPlayViewElement> createState() =>
      _VideoPlayViewElementState(activeIndex: pageIndex);
}

class _VideoPlayViewElementState extends State<VideoPlayViewElement> {
  late VideoPlayerController _videoPlayerController;
  bool initializeFinished = false;
  bool loadFailureFlag = false;

  //这个属性是demo里用来做自动播放下一个视频的，但是因为我这里一个element只播放一个视频用不上这个属性了。这里只用来做debug
  int activeIndex = 0;
  int playCount = 0;

  _VideoPlayViewElementState({this.activeIndex = 0});

  @override
  void dispose() {
    log.info(
        "now the videoPlayViewlement is disopose, will dispose the videoPlayViewlement and all videoPlayerController， the activeIndex is $activeIndex");
    // TODO: implement dispose
    super.dispose();
    _videoPlayerController.removeListener(_controllerListenFunc);
    _videoPlayerController.dispose();
  }

  @override
  void didUpdateWidget(VideoPlayViewElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    log.info(
        "now execute didUpdateWidget in videoPlayViewElement,  the activeIndex is $activeIndex");
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    log.info(
        "now execute didChangeDependencies in videoPlayViewElement, the activeIndex is $activeIndex");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log.info(
        "begin init videoPlayViewlement, now the initializeFinished is $initializeFinished and the activeIndex is $activeIndex");
    _initController();
  }

  _initController() {
    log.info(
        "begin load video from netWork and then init the videoPlayerController, the activeIndex is $activeIndex");
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          initializeFinished = true;
        });
        log.info(
            "now the videoPlayerController init finished , initializeFinished is $initializeFinished and the activeIndex is $activeIndex");

        _videoPlayerController.play();
        _videoPlayerController.addListener(_controllerListenFunc);
      }).catchError((error) {
        log.info(
            "init video for videoPlayer from network failure erros is $error");
        setState(() {
          loadFailureFlag = true;
        });
      });
  }

  _controllerListenFunc() {
    var curPosition = _videoPlayerController.value.position.inMilliseconds;
    var totalPosition = _videoPlayerController.value.duration.inMilliseconds;
    if (curPosition == totalPosition) {
      log.info(
          "listen the video play,play terminated, the curPosition is $curPosition and the totalPosition is $totalPosition and the activeIndex $activeIndex");

      setState(() {
        playCount = playCount + 1;
      });
      _videoPlayerController.seekTo(Duration.zero);
      _videoPlayerController.play();
      log.info("video play terminated the activeIndex is $activeIndex");
      if (activeIndex == 1) {
        activeIndex = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log.info(
        "begin build the VideoPlayer in videoPlayViewElement, the activeIndex is $activeIndex ");
    return loadFailureFlag
        ? const Center(
            child: Text(
            "读取视频网络流失败，可能服务器挂了",
            style: TextStyle(color: Colors.white),
          ))
        : initializeFinished
            ? VideoPlayer(_videoPlayerController)
            : const Center(
                child: Text(
                "loading...",
                style: TextStyle(color: Colors.white12),
              ));
  }
}

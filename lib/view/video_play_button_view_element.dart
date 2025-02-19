import 'package:flutter/material.dart';

import '../models/videoProgramInfo.dart';
import '../util/common_logger.dart';

/**
 * 头像及头像下方的按钮
 */
class VideoPlayButtonViewElement extends StatefulWidget {

  late VideoProgramInfo videoProgramInfo;
  VideoPlayButtonViewElement({super.key,required this.videoProgramInfo});

  @override
  State<VideoPlayButtonViewElement> createState() => _VideoPlayButtonViewElementState();
}

class _VideoPlayButtonViewElementState extends State<VideoPlayButtonViewElement> {
  @override
  Widget build(BuildContext context) {
    log.info("begin build VideoPlayButtonViewElement");
    return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      SizedBox(
        width: 60,
        height: 70,
        // padding: EdgeInsets.only(top: 0.0,),
        child: Stack(children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://pic3.zhimg.com/v2-18962bed49ad57cbb500229504097cf4_b.jpg"),
            ),  
          ),
          Positioned(
              bottom: 0,
              left: 15,
              child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.redAccent),
                  child: const Icon(Icons.add, size: 20, color: Colors.white))),
        ]),
      ),
      IconText(
          icon: const Icon(Icons.favorite, size: 50, color: Colors.redAccent),
          text: widget.videoProgramInfo.likes.toString()),
      const IconText(
          icon: Icon(Icons.feedback, size: 50, color: Colors.white),
          text: "999"),
      const IconText(
          icon: Icon(Icons.reply, size: 50, color: Colors.white), text: "999")
    ],
  );
  }
}

class IconText extends StatelessWidget {
  const IconText({super.key, required this.icon, required this.text});
  final Icon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
          icon,
          Text(text, style: const TextStyle(color: Colors.white))
        ]);
  }
}
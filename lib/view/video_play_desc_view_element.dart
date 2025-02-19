import 'package:flutter/material.dart';

import '../models/videoProgramInfo.dart';
import '../util/common_logger.dart';

class VideoDescViewElement extends StatelessWidget {
  final VideoProgramInfo videoProgramInfo;

  const VideoDescViewElement(
    this.videoProgramInfo, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    log.info("begin build VideoDescViewElement");
    return Column(
          children: <Widget>[
    ListTile(
      title: Text(
        videoProgramInfo.id,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        videoProgramInfo.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    const Row(children: <Widget>[
      SizedBox(width: 10),
      Icon(Icons.music_note),
      // Marquee(text:"人民日报创作的视频和音乐")
    ])
          ],
        );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:muses_app/client/video_rest_client.dart';

import '../util/common_logger.dart';
import 'video_pub_select_element.dart';

class TextFormFieldDemoApp extends StatelessWidget {
  const TextFormFieldDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: VideoPubViewElement()));
  }
}

class VideoPubViewElement extends StatefulWidget {
  const VideoPubViewElement({super.key});

  @override
  State<VideoPubViewElement> createState() => _VideoPubViewElementState();
}

class _VideoPubViewElementState extends State<VideoPubViewElement> {
  final _formKey = GlobalKey<FormState>();

  VideoRestClient videoRestClient = VideoRestClient();

  //手机号的控制器
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _fileName = "";
  String videoStoreId = "";
  bool videoUploadFinish = false;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          TextField(
            controller: _titleController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              labelText: '请输入标题)',
            ),
          ),
          TextField(
            controller: _descController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              filled: true,
              labelText: '请输入描述)',
            ),
          ),
          const VideoPubSelectListElement(),
          ListTile(
            title: Text("选择文件$_fileName"),
            onTap: () {
              log.info("choose file to upload");
              _pickFile();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                onPressed: _publishVideo,
                child: const Text("提交"),
              ),
              ElevatedButton(
                onPressed: _cancel,
                child: const Text("取消"),
              )
            ],
          )
        ]));
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['mp4', 'jpg', 'doc', 'txt'],
    );
    log.info("choolse file finished , check the filePickResult");

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        log.info("the picked file is $_fileName");
        videoRestClient.uploadVideo(result.files.first).then((id) {
          log.info("the video stroe id is $id");
          videoStoreId = id;
          videoUploadFinish = true;
        }).catchError((error) {
          log.info("upload video failure");
        });
      });
    } else {
      log.info("the picked file is null");
    }
  }

  _publishVideo() {
    if (!videoUploadFinish) {
      log.info("video not upload");
      return;
    }
    String title = _titleController.text;
    String desc = _titleController.text;
    videoRestClient.pubVideo(title, desc, videoStoreId);
    Navigator.pop(context);
  }

  _cancel() {
    log.info("cancel pub ");
    Navigator.pop(context);
  }
}

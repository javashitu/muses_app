import 'package:flutter/material.dart';

import '../util/common_logger.dart';

class VideoPubSelectListElement extends StatefulWidget {
  const VideoPubSelectListElement({super.key});

  @override
  State<VideoPubSelectListElement> createState() => _VideoPubSelectListElementState();
}

class _VideoPubSelectListElementState extends State<VideoPubSelectListElement> {
  String chooseVisable = "all";

  final Map<String, String> _visuableMap = {
    "all": "所有人可见",
    "self": "仅自己可见",
    "subscribe": "仅互关可见(todo)"
  };

  @override
  Widget build(BuildContext context) {
    return
        ListTile(
      title: Text(_visuableMap[chooseVisable]!),
      onTap: () {
        _showBasicModalBottomSheet();
        log.info("click the buttom the count is");
      },
    );
  }

  _showBasicModalBottomSheet() async {
    showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200, // 设置高度
          width: double.infinity,
          color: Colors.cyan[100],
          child: Center(
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: _visuableMap.entries.map((entry) {
                return ListTile(
                  leading: const Icon(Icons.people_alt_outlined),
                  title: Text(entry.value),
                  onTap: () {
                    setState(() {
                      chooseVisable = entry.key;
                    });
                    Navigator.pop(context, entry.key);
                  },
                );
              }).toList(),
            )),
          ),
        );
      },
    ).then((value) {
      log.info('选择的结果是: $value');
    });
  }
}

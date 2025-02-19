import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';



class WebRtcConnectSample extends StatefulWidget {
  const WebRtcConnectSample({super.key});

  @override
  State<WebRtcConnectSample> createState() => _WebRtcConnectSampleState();
}

class _WebRtcConnectSampleState extends State<WebRtcConnectSample> {
  final TextEditingController _textController = TextEditingController();

  late MediaStream _mediaStream;
  late RTCPeerConnection _localConnection;
  final _localRtcVideoRender = RTCVideoRenderer();

  final _remoteRtcVideoRender = RTCVideoRenderer();

  bool _inCalling = false;

  late RTCPeerConnection _remoteConnection;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRenderers();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    if (_inCalling) {
      // _stop();
    }
    _localRtcVideoRender.dispose();
  }

  void initRenderers() async {
    await _localRtcVideoRender.initialize();
  }

  void _makeCall() async {
    final mediaContraints = {
      "audio": true,
      "video": {
        'mandatory': {
          'minWidth':
              '1280', // Provide your own width, height and frame rate here
          'minHeight': '720',
          'minFrameRate': '30',
        },
      }
    };

    try {
      print("get all user media");
      var stream = await navigator.mediaDevices.getUserMedia(mediaContraints);
      print("get all camera");
      // cameras = await Helper.cameras;
      print("fill stream into video render");
      _mediaStream = stream;
      _localRtcVideoRender.srcObject = _mediaStream;

      _localConnection = await createPeerConnection({"iceServer": []});

      stream.getTracks().forEach((track) {
        _localConnection.addTrack(track, stream);
      });

      var offer = await _localConnection.createOffer({});
      _localConnection.setLocalDescription(offer);
      _localConnection.onIceCandidate = (candidate) {
        print("rtc peerconnection ice candidate ready $candidate");
      };
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) {
      print("page not mounted in tree, ignore this");
      return;
    }
    setState(() {
      _inCalling = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            decoration: const BoxDecoration(color: Colors.black54),
            child: RTCVideoView(_localRtcVideoRender, mirror: true),
          ),
          Row(
            children: [
              TextField(
                controller: _textController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  // contentPadding: EdgeInsets.all(10.0),
                  icon: Icon(Icons.description),
                  filled: true,
                  labelText: '请输入描述)',
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            decoration: const BoxDecoration(color: Colors.black54),
            child: RTCVideoView(_remoteRtcVideoRender, mirror: true),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _makeCall,
        tooltip: "call",
        child: const Icon(Icons.phone),
      ),
    );
  }
}

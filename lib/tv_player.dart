import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';

class TvPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String channelName;
  final List? channelsList;
  final int? initialIndex;
  final String server;
  final String username;
  final String password;

  const TvPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.channelName,
    this.channelsList,
    this.initialIndex,
    required this.server,
    required this.username,
    required this.password,
  }) : super(key: key);

  @override
  _TvPlayerScreenState createState() => _TvPlayerScreenState();
}

class _TvPlayerScreenState extends State<TvPlayerScreen> {
  BetterPlayerController? _controller;
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex?? 0;
    _initPlayer(widget.videoUrl);
  }

  void _initPlayer(String url) {
    setState(() => isLoading = true);
    _controller?.dispose();

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      headers: {"User-Agent": "VLC/3.0.18", "Referer": widget.server},
      liveStream: true,
      videoFormat: BetterPlayerVideoFormat.hls,
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fullScreenByDefault: true,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControlsOnInitialize: false,
          enableProgressBar: false,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    _controller!.addEventsListener((e) {
      if (e.betterPlayerEventType == BetterPlayerEventType.initialized) {
        setState(() => isLoading = false);
      }
      if (e.betterPlayerEventType == BetterPlayerEventType.exception) {
        if (url.endsWith('.m3u8')) {
          _initPlayer(url.replaceAll('.m3u8', '.ts'));
        }
      }
    });
  }

  void _changeChannel(int dir) {
    if (widget.channelsList == null) return;
    int newIndex = currentIndex + dir;
    if (newIndex >= 0 && newIndex < widget.channelsList!.length) {
      currentIndex = newIndex;
      var item = widget.channelsList![currentIndex];
      String url = '${widget.server}/live/${widget.username}/${widget.password}/${item['stream_id']}.m3u8';
      _initPlayer(url);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: (n, e) {
          if (e is KeyDownEvent) {
            if (e.logicalKey == LogicalKeyboardKey.arrowUp) _changeChannel(1);
            if (e.logicalKey == LogicalKeyboardKey.arrowDown) _changeChannel(-1);
            if (e.logicalKey == LogicalKeyboardKey.goBack) Navigator.pop(context);
          }
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            if (_controller!= null) BetterPlayer(controller: _controller!),
            if (isLoading) Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: Colors.red),
                SizedBox(height: 15),
                Text('جاري التحميل...', style: TextStyle(color: Colors.white, fontSize: 18)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

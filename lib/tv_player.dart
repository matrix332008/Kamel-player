import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class TvPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String channelName;
  final List? channelsList;
  final int? initialIndex;
  final String server;
  final String username;
  final String password;

  const TvPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.channelName,
    this.channelsList,
    this.initialIndex,
    required this.server,
    required this.username,
    required this.password,
  });

  @override
  State<TvPlayerScreen> createState() => _TvPlayerScreenState();
}

class _TvPlayerScreenState extends State<TvPlayerScreen> {
  final FijkPlayer player = FijkPlayer();
  int currentIndex = 0;
  bool showUI = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex?? 0;
    WakelockPlus.enable();
    _initPlayer(widget.videoUrl);
  }

  void _initPlayer(String url) async {
    await player.setOption(FijkOption.hostCategory, "enable-snapshot", 1);
    await player.setOption(FijkOption.playerCategory, "mediacodec", 1);
    await player.setOption(FijkOption.playerCategory, "mediacodec-auto-rotate", 1);
    await player.setOption(FijkOption.playerCategory, "mediacodec-handle-resolution-change", 1);
    await player.setDataSource(url, autoPlay: true);
    await player.enterFullScreen();
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _playNext();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _playPrev();
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
                 event.logicalKey == LogicalKeyboardKey.enter) {
        setState(() => showUI =!showUI);
      } else if (event.logicalKey == LogicalKeyboardKey.goBack ||
                 event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      }
    }
  }

  void _playNext() {
    if (widget.channelsList!= null && currentIndex < widget.channelsList!.length - 1) {
      setState(() => currentIndex++);
      final nextCh = widget.channelsList![currentIndex];
      final url = '${widget.server}/live/${widget.username}/${widget.password}/${nextCh['stream_id']}.m3u8';
      player.reset().then((_) => player.setDataSource(url, autoPlay: true));
    }
  }

  void _playPrev() {
    if (widget.channelsList!= null && currentIndex > 0) {
      setState(() => currentIndex--);
      final prevCh = widget.channelsList![currentIndex];
      final url = '${widget.server}/live/${widget.username}/${widget.password}/${prevCh['stream_id']}.m3u8';
      player.reset().then((_) => player.setDataSource(url, autoPlay: true));
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    player.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentName = widget.channelsList!= null
       ? widget.channelsList![currentIndex]['name']
        : widget.channelName;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          _handleKey(event);
          return KeyEventResult.handled;
        },
        child: Stack(
          children: [
            Center(
              child: FijkView(
                player: player,
                color: Colors.black,
                panelBuilder: fijkPanel2Builder(),
              ),
            ),
            if (showUI)
              Positioned(
                top: 40,
                left: 40,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    currentName,
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (showUI && widget.channelsList!= null)
              Positioned(
                bottom: 40,
                left: 40,
                child: Text(
                  '↑↓ تغيير القناة OK إخفاء/إظهار رجوع للخروج',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

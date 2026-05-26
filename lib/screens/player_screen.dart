import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  const PlayerScreen({super.key, required this.url, required this.title});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final FijkPlayer player = FijkPlayer();

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    player.setDataSource(widget.url, autoPlay: true);
    player.enterFullScreen();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    player.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FijkView(
          player: player,
          color: Colors.black,
          panelBuilder: fijkPanel2Builder(),
        ),
      ),
    );
  }
}

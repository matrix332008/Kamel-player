import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

void main() {
  runApp(const KamelTVApp());
}

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kamel TV',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> episodes = [
    {'title': 'حلقة تجريبية 1', 'url': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'},
    {'title': 'حلقة تجريبية 2', 'url': 'https://test-streams.mux.dev/pts_shift/master.m3u8'},
  ];

  void _playEpisode(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerPage(url: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/icon.png', height: 80),
              const SizedBox(height: 10),
              const Text('Kamel TV', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: episodes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.black54,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(episodes[index]['title']!, style: const TextStyle(color: Colors.white)),
                        trailing: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                        onTap: () => _playEpisode(episodes[index]['url']!, episodes[index]['title']!),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final String url;
  final String title;
  const PlayerPage({super.key, required this.url, required this.title});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late BetterPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BetterPlayerController(
      const BetterPlayerConfiguration(aspectRatio: 16 / 9, autoPlay: true),
      betterPlayerDataSource: BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.url),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: BetterPlayer(controller: _controller)),
    );
  }
}

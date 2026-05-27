import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const KamelTVApp());
}

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    final has = p.getString('type')!= null;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => has? const HomePage() : const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isXtream = true;
  final serverCtrl = TextEditingController(text: 'http://');
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final m3uCtrl = TextEditingController();

  Future<void> _saveXtream() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('type', 'xtream');
    await sp.setString('server', serverCtrl.text.trim());
    await sp.setString('user', userCtrl.text.trim());
    await sp.setString('pass', passCtrl.text.trim());
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<void> _saveM3u() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('type', 'm3u');
    await sp.setString('m3u', m3uCtrl.text.trim());
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset('assets/icon.png', fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                const Text('Kamel TV', style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => isXtream = true),
                      style: ElevatedButton.styleFrom(backgroundColor: isXtream? Colors.red : Colors.grey[800]),
                      child: const Text('Xtream Codes'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => setState(() => isXtream = false),
                      style: ElevatedButton.styleFrom(backgroundColor:!isXtream? Colors.deepPurple : Colors.grey[800]),
                      child: const Text('M3U Playlist'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 380,
                  child: Column(
                    children: [
                      if (isXtream)...[
                        _input(serverCtrl, 'رابط السيرفر', Icons.dns, true),
                        const SizedBox(height: 12),
                        _input(userCtrl, 'اسم المستخدم', Icons.person),
                        const SizedBox(height: 12),
                        _input(passCtrl, 'كلمة المرور', Icons.lock, false, true),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveXtream,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('دخول', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ] else...[
                        _input(m3uCtrl, 'رابط M3U', Icons.link, true),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveM3u,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                            child: const Text('دخول', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // خانة بيضاء مع تنقل فوق/لوطة
  Widget _input(TextEditingController c, String hint, IconData icon, [bool auto = false, bool obscure = false]) {
    return Focus(
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            FocusScope.of(context).nextFocus();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            FocusScope.of(context).previousFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: c,
        obscureText: obscure,
        autofocus: auto,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.red),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 3),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String type = '', server = '', user = '', pass = '', m3u = '';
  int menu = 0;
  List cats = [];
  List streams = [];
  String catId = '';
  bool loading = false;

  final menus = [
    {'t': 'البث المباشر', 'i': Icons.live_tv},
    {'t': 'الأفلام', 'i': Icons.movie},
    {'t': 'المسلسلات', 'i': Icons.tv},
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      type = sp.getString('type')?? '';
      server = sp.getString('server')?? '';
      user = sp.getString('user')?? '';
      pass = sp.getString('pass')?? '';
      m3u = sp.getString('m3u')?? '';
    });
    _loadCats();
  }

  Future<void> _loadCats() async {
    if (type == 'm3u') {
      _loadStreams();
      return;
    }
    setState(() => loading = true);
    final action = menu == 0? 'get_live_categories' : menu == 1? 'get_vod_categories' : 'get_series_categories';
    final url = '$server/player_api.php?username=$user&password=$pass&action=$action';
    final r = await http.get(Uri.parse(url));
    final data = json.decode(utf8.decode(r.bodyBytes));
    setState(() {
      cats = data;
      loading = false;
      if (cats.isNotEmpty) {
        catId = cats[0]['category_id'];
        _loadStreams();
      }
    });
  }

  Future<void> _loadStreams() async {
    setState(() => loading = true);
    if (type == 'm3u') {
      final r = await http.get(Uri.parse(m3u));
      final lines = utf8.decode(r.bodyBytes).split('\n');
      final List s = [];
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('#EXTINF')) {
          final name = lines[i].split(',').last;
          if (i + 1 < lines.length) {
            s.add({'name': name, 'url': lines[i + 1].trim()});
          }
        }
      }
      setState(() { streams = s; loading = false; });
      return;
    }
    final action = menu == 0? 'get_live_streams' : menu == 1? 'get_vod_streams' : 'get_series';
    final url = '$server/player_api.php?username=$user&password=$pass&action=$action&category_id=$catId';
    final r = await http.get(Uri.parse(url));
    final data = json.decode(utf8.decode(r.bodyBytes));
    setState(() { streams = data; loading = false; });
  }

  String _getUrl(dynamic m) {
    if (menu == 0) return '$server/live/$user/$pass/${m['stream_id']}.ts';
    if (menu == 1) return '$server/movie/$user/$pass/${m['stream_id']}.${m['container_extension']}';
    return '$server/series/$user/$pass/${m['series_id']}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // القائمة اليسار
          Container(
            width: 250,
            color: const Color(0xFF0D1B5C),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const CircleAvatar(radius: 30, backgroundImage: AssetImage('assets/icon.png')),
                const SizedBox(height: 10),
                Text(user, style: const TextStyle(color: Colors.white)),
                const Divider(color: Colors.white24, height: 30),
               ...List.generate(menus.length, (i) => Focus(
                      onFocusChange: (hasFocus) {
                        if (hasFocus) setState(() => menu = i);
                      },
                      child: Container(
                        color: menu == i? Colors.red : Colors.transparent,
                        child: ListTile(
                          autofocus: i == 0,
                          leading: Icon(menus[i]['i'] as IconData, color: Colors.white),
                          title: Text(menus[i]['t'] as String, style: const TextStyle(color: Colors.white)),
                          onTap: () { setState(() => menu = i); _loadCats(); },
                        ),
                      ),
                    )),
              ],
            ),
          ),
          // التصنيفات
          Container(
            width: 220,
            color: Colors.black,
            child: loading
               ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: cats.length,
                    itemBuilder: (_, i) {
                      final c = cats[i];
                      final sel = c['category_id'] == catId;
                      return Container(
                        color: sel? Colors.red.shade800 : Colors.transparent,
                        child: ListTile(
                          title: Text(c['category_name']?? '', style: const TextStyle(color: Colors.white)),
                          onTap: () { setState(() => catId = c['category_id']); _loadStreams(); },
                        ),
                      );
                    },
                  ),
          ),
          // القنوات
          Expanded(
            child: loading
               ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 0.8, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: streams.length,
                    itemBuilder: (_, i) {
                      final s = streams[i];
                      final name = s['name']?? s['title']?? '';
                      final icon = s['stream_icon']?? s['cover']?? '';
                      final url = type == 'm3u'? s['url'] : _getUrl(s);
                      return InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerPage(url: url, title: name))),
                        child: Container(
                          color: Colors.grey[900],
                          child: Column(
                            children: [
                              Expanded(
                                child: icon!= ''
                                   ? Image.network(icon, fit: BoxFit.cover, width: double.infinity,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.tv, color: Colors.white))
                                    : const Icon(Icons.tv, color: Colors.white),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(name, maxLines: 2, textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
      const BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false, // بلا ضبابة
        ),
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.url,
      ),
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
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(widget.title)),
      body: BetterPlayer(controller: _controller),
    );
  }
}

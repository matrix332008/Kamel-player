import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const KamelApp());
}

class KamelApp extends StatelessWidget {
  const KamelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Splash(),
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

  _check() async {
    final p = await SharedPreferences.getInstance();
    final h = p.getString('host');
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => h == null
            ? const TvLogin()
            : HomePage(host: h, user: p.getString('user')!, pass: p.getString('pass')!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover),
        ),
        child: Center(child: Image.asset('assets/icon.png', width: 180)),
      ),
    );
  }
}

// ===== LOGIN TV مع أسهم =====
class TvLogin extends StatefulWidget {
  const TvLogin({super.key});
  @override
  State<TvLogin> createState() => _TvLoginState();
}

class _TvLoginState extends State<TvLogin> {
  bool isXtream = true;
  final url = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  final fX = FocusNode(), fM = FocusNode(), f1 = FocusNode(), f2 = FocusNode(), f3 = FocusNode(), fC = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fX.requestFocus());
  }

  @override
  void dispose() {
    fX.dispose(); fM.dispose(); f1.dispose(); f2.dispose(); f3.dispose(); fC.dispose();
    super.dispose();
  }

  login() async {
    if (url.text.isEmpty || user.text.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    await p.setString('host', url.text);
    await p.setString('user', user.text);
    await p.setString('pass', pass.text);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(host: url.text, user: user.text, pass: pass.text)));
  }

  KeyEventResult handleKey(FocusNode current, FocusNode? up, FocusNode? down, FocusNode? left, FocusNode? right, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown && down != null) { down.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && up != null) { up.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && left != null) { left.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight && right != null) { right.requestFocus(); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken)),
        ),
        child: Center(
          child: SizedBox(
            width: 850,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon.png', width: 150, height: 150),
                const SizedBox(height: 25),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Focus(focusNode: fX, onKeyEvent: (n, e) => handleKey(fX, null, f1, null, fM, e), child: Builder(builder: (c) { final h = Focus.of(c).hasFocus; return GestureDetector(onTap: () => setState(() => isXtream = true), child: Container(width: 260, height: 65, decoration: BoxDecoration(color: isXtream ? Colors.pinkAccent : Colors.indigo.shade900, borderRadius: BorderRadius.circular(30), border: h ? Border.all(color: Colors.white, width: 3) : null), child: const Center(child: Text('Xtream Codes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))))); })),
                  const SizedBox(width: 20),
                  Focus(focusNode: fM, onKeyEvent: (n, e) => handleKey(fM, null, f1, fX, null, e), child: Builder(builder: (c) { final h = Focus.of(c).hasFocus; return GestureDetector(onTap: () => setState(() => isXtream = false), child: Container(width: 260, height: 65, decoration: BoxDecoration(color: !isXtream ? Colors.pinkAccent : Colors.indigo.shade900, borderRadius: BorderRadius.circular(30), border: h ? Border.all(color: Colors.white, width: 3) : null), child: const Center(child: Text('M3U Playlist', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))))); })),
                ]),
                const SizedBox(height: 30),
                Focus(focusNode: f1, onKeyEvent: (n, e) => handleKey(f1, fX, f2, null, null, e), child: TextField(controller: url, focusNode: f1, decoration: InputDecoration(hintText: 'رابط السيرفر http://...', filled: true, fillColor: Colors.black54, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
                const SizedBox(height: 8),
                Focus(focusNode: f2, onKeyEvent: (n, e) => handleKey(f2, f1, f3, null, null, e), child: TextField(controller: user, focusNode: f2, decoration: InputDecoration(hintText: 'اسم المستخدم', filled: true, fillColor: Colors.black54, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
                const SizedBox(height: 8),
                Focus(focusNode: f3, onKeyEvent: (n, e) => handleKey(f3, f2, fC, null, null, e), child: TextField(controller: pass, focusNode: f3, obscureText: true, decoration: InputDecoration(hintText: 'كلمة المرور', filled: true, fillColor: Colors.black54, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
                const SizedBox(height: 25),
                Focus(focusNode: fC, onKeyEvent: (n, e) => handleKey(fC, f3, null, null, null, e), child: Builder(builder: (c) { final h = Focus.of(c).hasFocus; return GestureDetector(onTap: login, child: Container(width: 380, height: 65, decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(30), border: h ? Border.all(color: Colors.white, width: 3) : null), child: const Center(child: Text('اتصال', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))))); })),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===== HOME =====
class HomePage extends StatefulWidget {
  final String host, user, pass;
  const HomePage({super.key, required this.host, required this.user, required this.pass});
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  List cats = [];
  bool load = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    try {
      final u = '${widget.host}/player_api.php?username=${widget.user}&password=${widget.pass}&action=get_live_categories';
      final r = await http.get(Uri.parse(u));
      setState(() { cats = json.decode(r.body); load = false; });
    } catch (e) {
      setState(() => load = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
        child: load ? const Center(child: CircularProgressIndicator()) : ListView.builder(
          padding: const EdgeInsets.all(40),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final c = cats[i];
            return Card(color: Colors.black54, child: ListTile(autofocus: i == 0, title: Text(c['category_name'], style: const TextStyle(fontSize: 24)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChannelsPage(host: widget.host, user: widget.user, pass: widget.pass, catId: c['category_id'], name: c['category_name'])))));
          },
        ),
      ),
    );
  }
}

// ===== CHANNELS =====
class ChannelsPage extends StatefulWidget {
  final String host, user, pass, catId, name;
  const ChannelsPage({super.key, required this.host, required this.user, required this.pass, required this.catId, required this.name});
  @override
  State<ChannelsPage> createState() => _ChState();
}

class _ChState extends State<ChannelsPage> {
  List ch = [];
  bool load = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    final u = '${widget.host}/player_api.php?username=${widget.user}&password=${widget.pass}&action=get_live_streams&category_id=${widget.catId}';
    final r = await http.get(Uri.parse(u));
    setState(() { ch = json.decode(r.body); load = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name), backgroundColor: Colors.black54),
      body: load ? const Center(child: CircularProgressIndicator()) : GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 0.75),
        itemCount: ch.length,
        itemBuilder: (_, i) {
          final s = ch[i];
          return Focus(autofocus: i == 0, child: Builder(builder: (ctx) {
            final f = Focus.of(ctx).hasFocus;
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Player(url: s['stream_id'].toString(), host: widget.host, user: widget.user, pass: widget.pass, name: s['name']))),
              child: AnimatedContainer(duration: const Duration(milliseconds: 150), margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black54, border: f ? Border.all(color: Colors.pinkAccent, width: 3) : null, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.tv, size: 50, color: f ? Colors.pinkAccent : Colors.white), const SizedBox(height: 10), Padding(padding: const EdgeInsets.all(6), child: Text(s['name'], textAlign: TextAlign.center, maxLines: 2, style: TextStyle(color: f ? Colors.pinkAccent : Colors.white)))])),
            );
          }));
        },
      ),
    );
  }
}

// ===== PLAYER =====
class Player extends StatefulWidget {
  final String url, host, user, pass, name;
  const Player({super.key, required this.url, required this.host, required this.user, required this.pass, required this.name});
  @override
  State<Player> createState() => _PState();
}

class _PState extends State<Player> {
  late VideoPlayerController c;
  bool ok = false;

  @override
  void initState() {
    super.initState();
    final link = '${widget.host}/live/${widget.user}/${widget.pass}/${widget.url}.ts';
    c = VideoPlayerController.networkUrl(Uri.parse(link))..initialize().then((_) { setState(() => ok = true); c.play(); });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Center(child: ok ? AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c)) : const CircularProgressIndicator()));
  }
}

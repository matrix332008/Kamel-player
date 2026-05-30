import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
      home: const TvLogin(),
    );
  }
}

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

  login() {
    if (url.text.isEmpty || user.text.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(host: url.text, user: user.text, pass: pass.text)));
  }

  KeyEventResult handleKey(FocusNode current, FocusNode? up, FocusNode? down, FocusNode? left, FocusNode? right, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown && down != null) { down.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && up != null) { up.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && left != null) { left.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight && right != null) { right.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
      if(current == fC) login();
      if(current == fX) setState(()=> isXtream = true);
      if(current == fM) setState(()=> isXtream = false);
    }
    return KeyEventResult.ignored;
  }

  Widget btn(String t, FocusNode n, {bool selected = false, bool big = false}) {
    return Focus(
      focusNode: n,
      onKeyEvent: (node, e) => handleKey(n, null, f1, n==fM?fX:null, n==fX?fM:null, e),
      child: Builder(builder: (c) { 
        final h = Focus.of(c).hasFocus; 
        return GestureDetector(
          onTap: (){
            if(n==fX) setState(()=> isXtream = true);
            if(n==fM) setState(()=> isXtream = false);
            if(n==fC) login();
          },
          child: Container(
            width: big ? 380 : 260, height: 65, 
            decoration: BoxDecoration(
              color: selected ? Colors.pinkAccent : (t == 'اتصال' ? Colors.redAccent : Colors.blue.shade900), 
              borderRadius: BorderRadius.circular(30), 
              border: h ? Border.all(color: Colors.white, width: 4) : null
            ), 
            child: Center(child: Text(t, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))
          )
        ); 
      }),
    );
  }

  Widget field(String h, TextEditingController c, FocusNode n, FocusNode? up, FocusNode? down) {
    return Focus(
      focusNode: n, 
      onKeyEvent: (node, e) => handleKey(n, up, down, null, null, e), 
      child: TextField(
        controller: c, 
        focusNode: n, 
        obscureText: h.contains('كلمة'), 
        decoration: InputDecoration(
          hintText: h, 
          filled: true, 
          fillColor: Colors.grey.shade900, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.pinkAccent, width: 2))
        ), 
        style: const TextStyle(fontSize: 20)
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: SizedBox(
          width: 850,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('KAMEL TV', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
              const SizedBox(height: 40),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                btn('Xtream Codes', fX, selected: isXtream),
                const SizedBox(width: 20),
                btn('M3U Playlist', fM, selected: !isXtream),
              ]),
              const SizedBox(height: 30),
              field('رابط السيرفر http://...', url, f1, fX, f2),
              const SizedBox(height: 8),
              field('اسم المستخدم', user, f2, f1, f3),
              const SizedBox(height: 8),
              field('كلمة المرور', pass, f3, f2, fC),
              const SizedBox(height: 25),
              btn('اتصال', fC, big: true),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String host, user, pass;
  const HomePage({super.key, required this.host, required this.user, required this.pass});
  @override State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  List cats = []; bool load = true;
  @override void initState() { super.initState(); _load(); }
  _load() async {
    try {
      final u = '${widget.host}/player_api.php?username=${widget.user}&password=${widget.pass}&action=get_live_categories';
      final r = await http.get(Uri.parse(u));
      setState(() { cats = json.decode(r.body); load = false; });
    } catch (e) { setState(() => load = false); }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(title: const Text('الأقسام'), backgroundColor: Colors.pinkAccent),
      body: load ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: const EdgeInsets.all(40),
        itemCount: cats.length,
        itemBuilder: (_, i) {
          final c = cats[i];
          return Card(color: Colors.grey.shade900, child: ListTile(autofocus: i == 0, title: Text(c['category_name'], style: const TextStyle(fontSize: 24)), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChannelsPage(host: widget.host, user: widget.user, pass: widget.pass, catId: c['category_id'], name: c['category_name'])))));
        },
      ),
    );
  }
}

class ChannelsPage extends StatefulWidget {
  final String host, user, pass, catId, name;
  const ChannelsPage({super.key, required this.host, required this.user, required this.pass, required this.catId, required this.name});
  @override State<ChannelsPage> createState() => _ChState();
}

class _ChState extends State<ChannelsPage> {
  List ch = []; bool load = true;
  @override void initState() { super.initState(); _load(); }
  _load() async {
    final u = '${widget.host}/player_api.php?username=${widget.user}&password=${widget.pass}&action=get_live_streams&category_id=${widget.catId}';
    final r = await http.get(Uri.parse(u));
    setState(() { ch = json.decode(r.body); load = false; });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(title: Text(widget.name), backgroundColor: Colors.pinkAccent),
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
              child: AnimatedContainer(duration: const Duration(milliseconds: 150), margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade900, border: f ? Border.all(color: Colors.pinkAccent, width: 3) : null, borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.tv, size: 50, color: f ? Colors.pinkAccent : Colors.white), const SizedBox(height: 10), Padding(padding: const EdgeInsets.all(6), child: Text(s['name'], textAlign: TextAlign.center, maxLines: 2, style: TextStyle(color: f ? Colors.pinkAccent : Colors.white)))])),
            );
          }));
        },
      ),
    );
  }
}

class Player extends StatefulWidget {
  final String url, host, user, pass, name;
  const Player({super.key, required this.url, required this.host, required this.user, required this.pass, required this.name});
  @override State<Player> createState() => _PState();
}

class _PState extends State<Player> {
  late VideoPlayerController c; bool ok = false;
  @override void initState() { super.initState(); final link = '${widget.host}/live/${widget.user}/${widget.pass}/${widget.url}.ts'; c = VideoPlayerController.networkUrl(Uri.parse(link))..initialize().then((_) { setState(() => ok = true); c.play(); }); }
  @override void dispose() { c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: Center(child: ok ? AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c)) : const CircularProgressIndicator()));
}

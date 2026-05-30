import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      home: const LoginPage(),
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
  final url = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  final fX = FocusNode(), fM = FocusNode(), f1 = FocusNode(), f2 = FocusNode(), f3 = FocusNode(), fC = FocusNode();
  String error = '';

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
    setState(() => error = '');
    if (url.text.isEmpty || user.text.isEmpty) {
      setState(() => error = 'عبي البيانات الكل');
      return;
    }
    
    if (isXtream) {
      try {
        final link = '${url.text}/player_api.php?username=${user.text}&password=${pass.text}';
        final r = await http.get(Uri.parse(link));
        final data = json.decode(r.body);
        if (data['user_info']['status'] == 'Active') {
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(host: url.text, user: user.text, pass: pass.text)));
        } else {
          setState(() => error = 'بيانات غالطة');
        }
      } catch (e) {
        setState(() => error = 'فما مشكل في السيرفر');
      }
    } else {
      // M3U
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => M3uPage(m3uUrl: url.text)));
    }
  }

  KeyEventResult _handleKey(FocusNode current, FocusNode? up, FocusNode? down, FocusNode? left, FocusNode? right, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown && down != null) { down.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp && up != null) { up.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && left != null) { left.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight && right != null) { right.requestFocus(); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
      if (current == fC) login();
      if (current == fX) setState(() => isXtream = true);
      if (current == fM) setState(() => isXtream = false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Center(
        child: SizedBox(
          width: 900,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('KAMEL TV', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
              const SizedBox(height: 40),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Focus(focusNode: fX, onKeyEvent: (n, e) => _handleKey(fX, null, f1, null, fM, e), child: Builder(builder: (c) { final h = Focus.of(c).hasFocus; return Container(width: 280, height: 65, decoration: BoxDecoration(color: isXtream ? Colors.pinkAccent : Colors.blue.shade900, borderRadius: BorderRadius.circular(30), border: h ? Border.all(color: Colors.white, width: 4) : null), child: const Center(child: Text('Xtream Codes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))); })),
                const SizedBox(width: 20),
                Focus(focusNode: fM, onKeyEvent: (n, e) => _handleKey(fM, null, f1, fX, null, e), child: Builder(builder: (c) { final h = Focus.of(c).hasFocus; return Container(width: 280, height: 65, decoration: BoxDecoration(color: !isXtream ? Colors.pinkAccent : Colors.blue.shade900, borderRadius: BorderRadius.circular(30), border: h ? Border.all(color: Colors.white, width: 4) : null), child: const Center(child: Text('M3U Playlist', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)))); })),
              ]),
              const SizedBox(height: 30),
              Focus(focusNode: f1, onKeyEvent: (n, e) => _handleKey(f1, fX, f2, null, null, e), child: TextField(controller: url, focusNode: f1, decoration: InputDecoration(hintText: isXtream ? 'رابط السيرفر http://...' : 'رابط M3U http://...', filled: true, fillColor: Colors.grey.shade900, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
              const SizedBox(height: 10),
              if (isXtream) ...[
                Focus(focusNode: f2, onKeyEvent: (n, e) => _handleKey(f2, f1, f3, null, null, e), child: TextField(controller: user, focusNode: f2, decoration: InputDecoration(hintText: 'اسم المستخدم', filled: true, fillColor: Colors.grey.shade900, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
                const SizedBox(height: 10),
                Focus(focusNode: f3, onKeyEvent: (n, e) => _handleKey(f3, f2, fC, null, null, e), child: TextField(controller: pass, focusNode: f3, obscureText: true, decoration: InputDecoration(hintText: 'كلمة المرور', filled: true, fillColor: Colors.grey.shade900, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
              ],
              const SizedBox(height: 25),
              Focus(focusNode: fC, onKeyEvent: (n, e) => _handleKey(fC, isXtream ? f3 : f1, null, null, null, e), child: Builder(builder: (c) { final h = Focus.of(c).hasFocus; return Container(width: 400, height: 65, decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(30), border: h ? Border.all(color: Colors.white, width: 4) : null), child: const Center(child: Text('اتصال', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))); })),
              const SizedBox(height: 15),
              Text(error, style: const TextStyle(color: Colors.red, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

// الصفحات اللي بعد الـ Login نخليهم مبسطين تو، المهم الـ Login يخدم
class HomePage extends StatelessWidget {
  final String host, user, pass;
  const HomePage({super.key, required this.host, required this.user, required this.pass});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('تم الدخول بنجاح\n$user', style: const TextStyle(fontSize: 40, color: Colors.white))),
    );
  }
}

class M3uPage extends StatelessWidget {
  final String m3uUrl;
  const M3uPage({super.key, required this.m3uUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('رابط M3U:\n$m3uUrl', style: const TextStyle(fontSize: 30, color: Colors.white))),
    );
  }
}

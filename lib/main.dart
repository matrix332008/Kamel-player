import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
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
  String msg = '';

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
    if (url.text.isEmpty) {
      setState(() => msg = 'اكتب الرابط');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(text: 'تم الاتصال بـ:\n${url.text}')));
  }

  KeyEventResult _handleKey(FocusNode current, FocusNode? up, FocusNode? down, FocusNode? left, FocusNode? right, KeyEvent event) {
    if (event is KeyDownEvent) {
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
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              Focus(focusNode: f1, onKeyEvent: (n, e) => _handleKey(f1, fX, isXtream ? f2 : fC, null, null, e), child: TextField(controller: url, focusNode: f1, decoration: InputDecoration(hintText: isXtream ? 'رابط السيرفر http://...' : 'رابط M3U http://...', filled: true, fillColor: Colors.grey.shade900, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
              const SizedBox(height: 10),
              if (isXtream) ...[
                Focus(focusNode: f2, onKeyEvent: (n, e) => _handleKey(f2, f1, f3, null, null, e), child: TextField(controller: user, focusNode: f2, decoration: InputDecoration(hintText: 'اسم المستخدم', filled: true, fillColor: Colors.grey.shade900, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
                const SizedBox(height: 10),
                Focus(focusNode: f3, onKeyEvent: (n, e) => _handleKey(f3, f2, fC, null, null, e), child: TextField(controller: pass, focusNode: f3, obscureText: true, decoration: InputDecoration(hintText: 'كلمة المرور', filled: true, fillColor: Colors.grey.shade900, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), style: const TextStyle(fontSize: 20))),
              ],
              const SizedBox(height: 25),
              Focus(focusNode: fC, onKeyEvent: (n, e) => _handleKey(fC, isXtream ? f3 : f1, null, null, null, e), child: Builder(builder: (c) { final h = Focus.of(c).hasFocus; return Container(width: 400, height: 65, decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(30), border: h ? Border.all(color: Colors.white, width: 4) : null), child: const Center(child: Text('اتصال', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)))); })),
              const SizedBox(height: 15),
              Text(msg, style: const TextStyle(color: Colors.red, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String text;
  const HomePage({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 40, color: Colors.white))),
    );
  }
}

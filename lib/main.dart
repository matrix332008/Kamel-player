import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KamelApp());
}

class KamelApp extends StatelessWidget {
  const KamelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0A0A1A)),
        home: const LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isXtream = true;
  final url = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  
  final fRadio1 = FocusNode();
  final fRadio2 = FocusNode();
  final f1 = FocusNode();
  final f2 = FocusNode();
  final f3 = FocusNode();
  final fBtn = FocusNode();

  @override
  void initState() {
    super.initState();
    fRadio1.requestFocus();
  }

  @override
  void dispose() {
    fRadio1.dispose(); fRadio2.dispose(); f1.dispose(); f2.dispose(); f3.dispose(); fBtn.dispose();
    super.dispose();
  }

  void login() {
    if (url.text.isEmpty) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => HomeScreen(
        serverUrl: url.text,
        username: isXtream ? user.text : 'M3U',
        expiry: '20/09/2026',
      ),
    ));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (node == fRadio1 || node == fRadio2) f1.requestFocus();
      else if (node == f1) isXtream ? f2.requestFocus() : fBtn.requestFocus();
      else if (node == f2) f3.requestFocus();
      else if (node == f3) fBtn.requestFocus();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (node == fBtn) isXtream ? f3.requestFocus() : f1.requestFocus();
      else if (node == f3) f2.requestFocus();
      else if (node == f2) f1.requestFocus();
      else if (node == f1) fRadio1.requestFocus();
      return KeyEventResult.handled;
    }
    
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (node == fRadio1) fRadio2.requestFocus();
      return KeyEventResult.handled;
    }
    
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (node == fRadio2) fRadio1.requestFocus();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
      if (node == fBtn) login();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1A2E), Color(0xFF0A0A1A)]),
        ),
        child: Center(
          child: SizedBox(
            width: 900,
            child: ListView( // هذا يخلي كل شي يبان والـ Scroll يخدم
              shrinkWrap: true,
              children: [
                const SizedBox(height: 20),
                const Center(child: Text('KAMEL TV', style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.red))),
                const SizedBox(height: 40),
                Focus(
                  focusNode: fRadio1,
                  onKeyEvent: _onKey,
                  child: RadioListTile(value: true, groupValue: isXtream, onChanged: (v) => setState(() => isXtream = v!), title: const Text('Xtream Codes', style: TextStyle(fontSize: 24))),
                ),
                Focus(
                  focusNode: fRadio2,
                  onKeyEvent: _onKey,
                  child: RadioListTile(value: false, groupValue: isXtream, onChanged: (v) => setState(() => isXtream = v!), title: const Text('M3U Playlist', style: TextStyle(fontSize: 24))),
                ),
                const SizedBox(height: 25),
                Focus(
                  focusNode: f1,
                  onKeyEvent: _onKey,
                  child: TextField(controller: url, focusNode: f1, decoration: InputDecoration(labelText: isXtream ? 'Server URL http://...' : 'M3U URL http://...', border: const OutlineInputBorder()), style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 15),
                if (isXtream) ...[
                  Focus(
                    focusNode: f2,
                    onKeyEvent: _onKey,
                    child: TextField(controller: user, focusNode: f2, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()), style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(height: 15),
                  Focus(
                    focusNode: f3,
                    onKeyEvent: _onKey,
                    child: TextField(controller: pass, focusNode: f3, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), style: const TextStyle(fontSize: 22), obscureText: true),
                  ),
                ],
                const SizedBox(height: 35),
                Focus(
                  focusNode: fBtn,
                  onKeyEvent: _onKey,
                  child: Builder(builder: (c) {
                    final has = Focus.of(c).hasFocus;
                    return SizedBox(
                      width: 450, height: 70,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          side: has ? const BorderSide(color: Colors.white, width: 4) : BorderSide.none,
                        ),
                        child: const Text('اتصال', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String serverUrl, username, expiry;
  const HomeScreen({super.key, required this.serverUrl, required this.username, required this.expiry});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;
  final f0 = FocusNode(), f1 = FocusNode(), f2 = FocusNode();

  @override
  void initState() {
    super.initState();
    f0.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (node == f0) f1.requestFocus();
        if (node == f1) f2.requestFocus();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (node == f2) f1.requestFocus();
        if (node == f1) f0.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A0033), Color(0xFF000), Color(0xFF001F3F)]),
            ),
          ),
          Positioned(
            top: 30, left: 40, right: 40,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person, size: 35)),
                const SizedBox(width: 15),
                const Text('Kamel TV', style: TextStyle(fontSize: 24, color: Colors.greenAccent)),
              ]),
              const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('20:31:26', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('22/05/2026', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ]),
            ]),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('+420777099379', style: TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text('BEST IPTV', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                const Text('Service Provider', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 60),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _btn(0, 'LIVE TV', Icons.live_tv, f0),
                  const SizedBox(width: 30),
                  _btn(1, 'SERIES', Icons.tv, f1),
                  const SizedBox(width: 30),
                  _btn(2, 'FILMS', Icons.movie, f2),
                ]),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                  child: Text('VOTRE ABONNEMENT EXPIRE LE : ${widget.expiry}', style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(int index, String title, IconData icon, FocusNode node) {
    final isSelected = selected == index;
    return Focus(
      focusNode: node,
      onKeyEvent: _onKey,
      onFocusChange: (hasFocus) {
        if (hasFocus) setState(() => selected = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280, height: 160,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: isSelected ? Colors.white : Colors.white30, width: isSelected ? 4 : 2),
          boxShadow: isSelected ? [BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)] : [],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 60, color: Colors.white),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      ),
    );
  }
}

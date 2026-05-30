import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KamelTVApp());
}

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
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
  final server = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();

  final fXtream = FocusNode();
  final fM3u = FocusNode();
  final fServer = FocusNode();
  final fUser = FocusNode();
  final fPass = FocusNode();
  final fLogin = FocusNode();

  @override
  void initState() {
    super.initState();
    fXtream.requestFocus();
  }

  @override
  void dispose() {
    fXtream.dispose(); fM3u.dispose(); fServer.dispose(); 
    fUser.dispose(); fPass.dispose(); fLogin.dispose();
    super.dispose();
  }

  void login() {
    if (server.text.isEmpty) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // تحت
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (node == fXtream || node == fM3u) fServer.requestFocus();
      else if (node == fServer) isXtream ? fUser.requestFocus() : fLogin.requestFocus();
      else if (node == fUser) fPass.requestFocus();
      else if (node == fPass) fLogin.requestFocus();
      return KeyEventResult.handled;
    }

    // فوق
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (node == fLogin) isXtream ? fPass.requestFocus() : fServer.requestFocus();
      else if (node == fPass) fUser.requestFocus();
      else if (node == fUser) fServer.requestFocus();
      else if (node == fServer) fXtream.requestFocus();
      return KeyEventResult.handled;
    }

    // يمين
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (node == fXtream) fM3u.requestFocus();
      return KeyEventResult.handled;
    }

    // يسار
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (node == fM3u) fXtream.requestFocus();
      return KeyEventResult.handled;
    }

    // OK
    if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
      if (node == fLogin) login();
      if (node == fXtream) setState(() => isXtream = true);
      if (node == fM3u) setState(() => isXtream = false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildTextField(String hint, TextEditingController ctrl, FocusNode node, {bool isPass = false}) {
    return Focus(
      focusNode: node,
      onKeyEvent: _handleKey,
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return Container(
          height: 65,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: hasFocus ? Colors.red : Colors.white54, width: hasFocus ? 3 : 1.5),
          ),
          child: TextField(
            controller: ctrl,
            focusNode: node,
            obscureText: isPass,
            style: const TextStyle(color: Colors.white, fontSize: 22),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0033), Color(0xFF000000), Color(0xFF001f3f)],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 700,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الصورة متاعك
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red.shade800,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text('Kamel TV', style: TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                
                // Xtream + M3U
                Row(children: [
                  Expanded(
                    child: Focus(
                      focusNode: fXtream,
                      onKeyEvent: _handleKey,
                      child: Builder(builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return GestureDetector(
                          onTap: () => setState(() => isXtream = true),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: isXtream ? Colors.red : Colors.blue.shade900.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                            ),
                            child: const Center(child: Text('Xtream Codes', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Focus(
                      focusNode: fM3u,
                      onKeyEvent: _handleKey,
                      child: Builder(builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return GestureDetector(
                          onTap: () => setState(() => isXtream = false),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: !isXtream ? Colors.red : Colors.blue.shade900.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                            ),
                            child: const Center(child: Text('M3U Playlist', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                          ),
                        );
                      }),
                    ),
                  ),
                ]),
                const SizedBox(height: 30),
                
                // الخانات
                _buildTextField('رابط السيرفر', server, fServer),
                if (isXtream) ...[
                  _buildTextField('اسم المستخدم', user, fUser),
                  _buildTextField('كلمة المرور', pass, fPass, isPass: true),
                ],
                
                const SizedBox(height: 30),
                
                // زر دخول
                Focus(
                  focusNode: fLogin,
                  onKeyEvent: _handleKey,
                  child: Builder(builder: (context) {
                    final hasFocus = Focus.of(context).hasFocus;
                    return SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          side: BorderSide(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                        ),
                        child: const Text('دخول', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selected = 0;
  final f1 = FocusNode(), f2 = FocusNode(), f3 = FocusNode();

  @override
  void initState() {
    super.initState();
    f1.requestFocus();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (node == f1) f2.requestFocus();
        if (node == f2) f3.requestFocus();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (node == f3) f2.requestFocus();
        if (node == f2) f1.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a0033), Color(0xFF000000), Color(0xFF001f3f)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('+420777099379', style: TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text('BEST IPTV', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
              const Text('Service Provider', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 60),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _buildBtn('LIVE TV', Icons.live_tv, f1, 0),
                const SizedBox(width: 30),
                _buildBtn('SERIES', Icons.tv, f2, 1),
                const SizedBox(width: 30),
                _buildBtn('FILMS', Icons.movie, f3, 2),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(String title, IconData icon, FocusNode node, int index) {
    return Focus(
      focusNode: node,
      onKeyEvent: _handleKey,
      onFocusChange: (hasFocus) {
        if (hasFocus) setState(() => selected = index);
      },
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280, height: 160,
          decoration: BoxDecoration(
            color: hasFocus ? Colors.red : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: hasFocus ? Colors.white : Colors.white30, width: hasFocus ? 4 : 2),
            boxShadow: hasFocus ? [BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)] : [],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ]),
        );
      }),
    );
  }
}

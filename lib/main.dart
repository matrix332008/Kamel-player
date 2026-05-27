import 'dart:async';
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
    Future.delayed(const Duration(milliseconds: 300), () async {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => p.getString('type') == null? const LoginPage() : const HomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// ==================== LOGIN ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isXtream = true;
  final s = TextEditingController(text: 'http://');
  final u = TextEditingController();
  final p = TextEditingController();
  final m = TextEditingController();

  Future<void> saveX() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('type', 'xtream');
    await sp.setString('server', s.text.trim());
    await sp.setString('user', u.text.trim());
    await sp.setString('pass', p.text.trim());
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<void> saveM() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('type', 'm3u');
    await sp.setString('m3u', m.text.trim());
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<String?> _ask(String title, String val, bool obs) {
    final c = TextEditingController(text: val);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: c,
          obscureText: obs,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('OK', style: TextStyle(color: Colors.red))),
        ],
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
                      autofocus: true,
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
                        _btn(s, 'رابط السيرفر', Icons.dns),
                        const SizedBox(height: 12),
                        _btn(u, 'اسم المستخدم', Icons.person),
                        const SizedBox(height: 12),
                        _btn(p, 'كلمة المرور', Icons.lock, true),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: saveX,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('دخول', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ] else...[
                        _btn(m, 'رابط M3U', Icons.link),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: saveM,
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

  Widget _btn(TextEditingController c, String h, IconData i, [bool obs = false]) {
    return Focus(
      child: Builder(builder: (ctx) {
        final has = Focus.of(ctx).hasFocus;
        return InkWell(
          onTap: () async {
            final v = await _ask(h, c.text, obs);
            if (v!= null) setState(() => c.text = v);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: has? Colors.red : Colors.transparent, width: 3),
            ),
            child: Row(
              children: [
                Icon(i, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.text.isEmpty? h : (obs? '••••••' : c.text),
                    style: TextStyle(color: c.text.isEmpty? Colors.grey : Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ==================== HOME + PLAYER ====================
// (خلي باقي الكود كيما عندك، المهم ما تمسش الأقواس)
// إذا تحب نبعثلك حتى Home و Player كاملين مرة أخرى قولي، أما الغلطة كانت كان في الـ Login

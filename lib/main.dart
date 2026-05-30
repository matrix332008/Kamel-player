import 'package:flutter/material.dart';

void main() {
  runApp(const KamelTVApp());
}

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Color(0xFF1A1A2E),
        ),
      ),
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
  final url = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();

  void login() {
    if (url.text.isEmpty) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => HomeScreen(
        serverUrl: url.text,
        username: isXtream ? user.text : 'M3U User',
        expiry: '20/09/2026',
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0A0A1A)],
          ),
        ),
        child: Center(
          child: Container(
            width: 900,
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('KAMEL TV', style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 40),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(child: RadioListTile(value: true, groupValue: isXtream, onChanged: (v) => setState(() => isXtream = v!), title: const Text('Xtream Codes', style: TextStyle(fontSize: 24)))),
                  Expanded(child: RadioListTile(value: false, groupValue: isXtream, onChanged: (v) => setState(() => isXtream = v!), title: const Text('M3U Playlist', style: TextStyle(fontSize: 24)))),
                ]),
                const SizedBox(height: 25),
                TextField(controller: url, autofocus: true, decoration: InputDecoration(labelText: isXtream ? 'Server URL http://...' : 'M3U URL http://...'), style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 15),
                if (isXtream) ...[
                  TextField(controller: user, decoration: const InputDecoration(labelText: 'Username'), style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 15),
                  TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password'), style: const TextStyle(fontSize: 22), obscureText: true),
                ],
                const SizedBox(height: 35),
                SizedBox(width: 450, height: 70, child: ElevatedButton(onPressed: login, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('اتصال', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)))),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A0033), Color(0xFF000), Color(0xFF001F3F)],
              ),
            ),
          ),
          // Top bar
          Positioned(
            top: 30, left: 40, right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person, size: 35)),
                  const SizedBox(width: 15),
                  Text('Kamel TV', style: TextStyle(fontSize: 24, color: Colors.greenAccent, shadows: [Shadow(blurRadius: 10, color: Colors.greenAccent)])),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('20:31:26', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('22/05/2026', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ]),
              ],
            ),
          ),
          // Center content
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
                  _buildButton(0, 'LIVE TV', Icons.live_tv, Colors.red),
                  const SizedBox(width: 30),
                  _buildButton(1, 'SERIES', Icons.tv, Colors.grey.shade900),
                  const SizedBox(width: 30),
                  _buildButton(2, 'FILMS', Icons.movie, Colors.grey.shade900),
                ]),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                  child: Text('VOTRE ABONNEMENT SERA EXPIRÉ LE : ${widget.expiry}', style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(int index, String title, IconData icon, Color color) {
    final isSelected = selected == index;
    return Focus(
      autofocus: index == 0,
      onFocusChange: (hasFocus) {
        if (hasFocus) setState(() => selected = index);
      },
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280, height: 160,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : color,
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
      ),
    );
  }
}

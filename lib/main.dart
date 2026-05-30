import 'package:flutter/material.dart';

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

  login() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => HomePage(
        title: isXtream ? 'Xtream' : 'M3U',
        data: url.text,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('KAMEL TV', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 40),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Expanded(child: RadioListTile(value: true, groupValue: isXtream, onChanged: (v) => setState(() => isXtream = v!), title: const Text('Xtream Codes', style: TextStyle(fontSize: 24)))),
                Expanded(child: RadioListTile(value: false, groupValue: isXtream, onChanged: (v) => setState(() => isXtream = v!), title: const Text('M3U Playlist', style: TextStyle(fontSize: 24)))),
              ]),
              const SizedBox(height: 20),
              TextField(controller: url, autofocus: true, decoration: InputDecoration(labelText: isXtream ? 'Server URL' : 'M3U URL', border: const OutlineInputBorder()), style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 15),
              if (isXtream) ...[
                TextField(controller: user, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()), style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 15),
                TextField(controller: pass, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), style: const TextStyle(fontSize: 22), obscureText: true),
              ],
              const SizedBox(height: 30),
              SizedBox(width: 400, height: 60, child: ElevatedButton(onPressed: login, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('اتصال', style: TextStyle(fontSize: 26)))),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title, data;
  const HomePage({super.key, required this.title, required this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('KAMEL TV', style: TextStyle(fontSize: 50, color: Colors.red)),
            const SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _btn('LIVE TV', Colors.red),
              const SizedBox(width: 20),
              _btn('SERIES', Colors.grey.shade800),
              const SizedBox(width: 20),
              _btn('FILMS', Colors.grey.shade800),
            ]),
            const SizedBox(height: 40),
            Text('تم الدخول بـ: $title', style: const TextStyle(fontSize: 24)),
            Text(data, style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _btn(String t, Color c) {
    return SizedBox(
      width: 250, height: 150,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: c, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.live_tv, size: 50),
          const SizedBox(height: 10),
          Text(t, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

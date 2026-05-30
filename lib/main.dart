import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KamelTVApp());
}

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamel TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
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

  _login() async {
    if (url.text.isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', true);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/background.jpeg"), fit: BoxFit.cover),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.75),
          child: Center(
            child: SizedBox(
              width: 700,
              // هذا هو السر: ListView يخدم بالريموت وحدو
              child: ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red, width: 3),
                        image: const DecorationImage(image: AssetImage("assets/icon.png"), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Center(child: Text('Kamel TV', style: TextStyle(fontSize: 36, color: Colors.red, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 50),
                  
                  // Xtream Codes
                  ElevatedButton(
                    autofocus: true, // اول زر ياخذ الفوكس
                    onPressed: () => setState(() => isXtream = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isXtream ? Colors.red : Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Xtream Codes', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(height: 20),
                  
                  // M3U Playlist  
                  ElevatedButton(
                    onPressed: () => setState(() => isXtream = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isXtream ? Colors.red : Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('M3U Playlist', style: TextStyle(fontSize: 26)),
                  ),
                  const SizedBox(height: 35),
                  
                  // URL
                  TextField(
                    controller: url,
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                    decoration: InputDecoration(
                      filled: true, fillColor: Colors.black54,
                      hintText: isXtream ? 'رابط السيرفر' : 'رابط M3U',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  
                  if (isXtream) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: user,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      decoration: InputDecoration(
                        filled: true, fillColor: Colors.black54,
                        hintText: 'اسم المستخدم',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: pass,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      decoration: InputDecoration(
                        filled: true, fillColor: Colors.black54,
                        hintText: 'كلمة المرور',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('دخول', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/background.jpeg"), fit: BoxFit.cover),
        ),
        child: const Center(child: Text('Home Screen', style: TextStyle(fontSize: 50))),
      ),
    );
  }
}

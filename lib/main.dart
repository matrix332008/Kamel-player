import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // هذا السطر هو اللي يخلي الريموت يخدم على اي Android TV
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          // FocusScope هو الحل متاع TV
          child: FocusScope(
            autofocus: true,
            child: Center(
              child: SizedBox(
                width: 700,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red, width: 3),
                        image: const DecorationImage(
                          image: AssetImage("assets/icon.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Kamel TV', style: TextStyle(fontSize: 36, color: Colors.red, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 50),

                    // الزر الاول لازم autofocus: true
                    ElevatedButton(
                      autofocus: true,
                      onPressed: () => setState(() => isXtream = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isXtream ? Colors.red : Colors.blue.shade900,
                        minimumSize: const Size(double.infinity, 70),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Xtream Codes', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () => setState(() => isXtream = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isXtream ? Colors.red : Colors.blue.shade900,
                        minimumSize: const Size(double.infinity, 70),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('M3U Playlist', style: TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(height: 35),

                    TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black54,
                        hintText: isXtream ? 'رابط السيرفر' : 'رابط M3U',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),

                    if (isXtream) ...[
                      const SizedBox(height: 20),
                      TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 22),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black54,
                          hintText: 'اسم المستخدم',
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        style: const TextStyle(color: Colors.white, fontSize: 22),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black54,
                          hintText: 'كلمة المرور',
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 70),
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
      ),
    );
  }
}

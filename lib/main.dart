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
      home: const LoginPage(),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
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
  final server = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    if (loggedIn) return const HomePage();
    
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(TraversalDirection.down),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionalFocusIntent(TraversalDirection.right),
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FocusTraversalGroup(
            child: SizedBox(
              width: 700,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    color: Colors.red,
                    child: const Icon(Icons.person, size: 70, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text('Kamel TV', style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  
                  // Xtream + M3U
                  Row(children: [
                    Expanded(
                      child: Focus(
                        autofocus: true,
                        child: Builder(builder: (context) {
                          final hasFocus = Focus.of(context).hasFocus;
                          return GestureDetector(
                            onTap: () => setState(() => isXtream = true),
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                color: isXtream ? Colors.red : Colors.blue.shade900,
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
                        child: Builder(builder: (context) {
                          final hasFocus = Focus.of(context).hasFocus;
                          return GestureDetector(
                            onTap: () => setState(() => isXtream = false),
                            child: Container(
                              height: 70,
                              decoration: BoxDecoration(
                                color: !isXtream ? Colors.red : Colors.blue.shade900,
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
                  
                  // Server URL
                  Focus(
                    child: Builder(builder: (context) {
                      final hasFocus = Focus.of(context).hasFocus;
                      return Container(
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: hasFocus ? Colors.red : Colors.white54, width: hasFocus ? 3 : 1.5),
                        ),
                        child: TextField(
                          controller: server,
                          style: const TextStyle(color: Colors.white, fontSize: 22),
                          decoration: InputDecoration(
                            hintText: isXtream ? 'رابط السيرفر' : 'رابط M3U',
                            hintStyle: const TextStyle(color: Colors.white54, fontSize: 22),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  if (isXtream) ...[
                    const SizedBox(height: 20),
                    Focus(
                      child: Builder(builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return Container(
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: hasFocus ? Colors.red : Colors.white54, width: hasFocus ? 3 : 1.5),
                          ),
                          child: TextField(
                            controller: user,
                            style: const TextStyle(color: Colors.white, fontSize: 22),
                            decoration: const InputDecoration(
                              hintText: 'اسم المستخدم',
                              hintStyle: TextStyle(color: Colors.white54, fontSize: 22),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Focus(
                      child: Builder(builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return Container(
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: hasFocus ? Colors.red : Colors.white54, width: hasFocus ? 3 : 1.5),
                          ),
                          child: TextField(
                            controller: pass,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white, fontSize: 22),
                            decoration: const InputDecoration(
                              hintText: 'كلمة المرور',
                              hintStyle: TextStyle(color: Colors.white54, fontSize: 22),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  // زر دخول
                  Focus(
                    child: Builder(builder: (context) {
                      final hasFocus = Focus.of(context).hasFocus;
                      return SizedBox(
                        width: double.infinity,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () {
                            if (server.text.isNotEmpty) setState(() => loggedIn = true);
                          },
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
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionalFocusIntent(TraversalDirection.right),
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FocusTraversalGroup(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('BEST IPTV', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                const SizedBox(height: 60),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _btn('LIVE TV', Icons.live_tv, true),
                  const SizedBox(width: 30),
                  _btn('SERIES', Icons.tv, false),
                  const SizedBox(width: 30),
                  _btn('FILMS', Icons.movie, false),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(String title, IconData icon, bool autofocus) {
    return Focus(
      autofocus: autofocus,
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return Container(
          width: 280, height: 160,
          decoration: BoxDecoration(
            color: hasFocus ? Colors.red : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: hasFocus ? Colors.white : Colors.white30, width: hasFocus ? 4 : 2),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KamelTV());
}

class KamelTV extends StatelessWidget {
  const KamelTV({super.key});
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(TraversalDirection.down),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const DirectionalFocusIntent(TraversalDirection.right),
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
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
  final url = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  bool logged = false;

  @override
  Widget build(BuildContext context) {
    if (logged) return const HomePage();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: FocusTraversalGroup(
              child: SizedBox(
                width: 700,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/avatar.jpg',
                        width: 120, height: 120, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Kamel TV', style: TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 40),
                    
                    Row(children: [
                      Expanded(
                        child: Focus(
                          autofocus: true,
                          child: Builder(builder: (context) {
                            final hasFocus = Focus.of(context).hasFocus;
                            return ElevatedButton(
                              onPressed: () => setState(() => isXtream = true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isXtream ? Colors.red : Colors.blue.shade900,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                side: BorderSide(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                              ),
                              child: const Text('Xtream Codes', style: TextStyle(fontSize: 24)),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Focus(
                          child: Builder(builder: (context) {
                            final hasFocus = Focus.of(context).hasFocus;
                            return ElevatedButton(
                              onPressed: () => setState(() => isXtream = false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !isXtream ? Colors.red : Colors.blue.shade900,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                side: BorderSide(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                              ),
                              child: const Text('M3U Playlist', style: TextStyle(fontSize: 24)),
                            );
                          }),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 30),
                    
                    Focus(
                      child: Builder(builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return TextField(
                          controller: url,
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black54,
                            hintText: isXtream ? 'رابط السيرفر' : 'رابط M3U',
                            hintStyle: const TextStyle(color: Colors.white54),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: hasFocus ? Colors.red : Colors.white54, width: 2)),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3)),
                          ),
                        );
                      }),
                    ),
                    
                    if (isXtream) ...[
                      const SizedBox(height: 20),
                      Focus(
                        child: Builder(builder: (context) {
                          final hasFocus = Focus.of(context).hasFocus;
                          return TextField(
                            controller: user,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black54,
                              hintText: 'اسم المستخدم',
                              hintStyle: const TextStyle(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: hasFocus ? Colors.red : Colors.white54, width: 2)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3)),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Focus(
                        child: Builder(builder: (context) {
                          final hasFocus = Focus.of(context).hasFocus;
                          return TextField(
                            controller: pass,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.black54,
                              hintText: 'كلمة المرور',
                              hintStyle: const TextStyle(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: hasFocus ? Colors.red : Colors.white54, width: 2)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 3)),
                            ),
                          );
                        }),
                      ),
                    ],
                    
                    const SizedBox(height: 30),
                    Focus(
                      child: Builder(builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              if (url.text.isNotEmpty) setState(() => logged = true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              side: BorderSide(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                            ),
                            child: const Text('دخول', style: TextStyle(fontSize: 28)),
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
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
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
            Icon(icon, size: 60),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ]),
        );
      }),
    );
  }
}

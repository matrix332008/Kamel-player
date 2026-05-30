import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  runApp(const KamelTVApp());
}

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
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
        title: 'Kamel TV',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogged = prefs.getBool('isLogged') ?? false;
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => isLogged ? const HomeScreen() : const LoginScreen(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.red),
              SizedBox(height: 20),
              Text('Kamel TV', style: TextStyle(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
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
  bool isLoading = false;

  _login() async {
    if (url.text.isEmpty) return;
    setState(() => isLoading = true);
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (isXtream) {
      // Xtream Codes API
      try {
        final response = await http.get(Uri.parse(
          '${url.text}/player_api.php?username=${user.text}&password=${pass.text}'
        ));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['user_info']['auth'] == 1) {
            await prefs.setBool('isLogged', true);
            await prefs.setString('serverUrl', url.text);
            await prefs.setString('username', user.text);
            await prefs.setString('password', pass.text);
            await prefs.setBool('isXtream', true);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else {
            _showError('بيانات الدخول غالطة');
          }
        }
      } catch (e) {
        _showError('مشكل في الاتصال بالسيرفر');
      }
    } else {
      // M3U
      await prefs.setBool('isLogged', true);
      await prefs.setString('m3uUrl', url.text);
      await prefs.setBool('isXtream', false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
    setState(() => isLoading = false);
  }

  _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.75),
          child: Center(
            child: FocusTraversalGroup(
              child: SingleChildScrollView(
                child: Container(
                  width: 700,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red, width: 3),
                          image: const DecorationImage(image: AssetImage("assets/avatar.jpg"), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text('Kamel TV', style: TextStyle(fontSize: 36, color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 50),
                      
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
                                  padding: const EdgeInsets.symmetric(vertical: 22),
                                  side: BorderSide(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                                ),
                                child: const Text('Xtream Codes', style: TextStyle(fontSize: 26)),
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
                                  padding: const EdgeInsets.symmetric(vertical: 22),
                                  side: BorderSide(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                                ),
                                child: const Text('M3U Playlist', style: TextStyle(fontSize: 26)),
                              );
                            }),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 35),
                      
                      Focus(
                        child: Builder(builder: (context) {
                          final hasFocus = Focus.of(context).hasFocus;
                          return TextField(
                            controller: url,
                            style: const TextStyle(color: Colors.white, fontSize: 22),
                            decoration: InputDecoration(
                              filled: true, fillColor: Colors.black54,
                              hintText: isXtream ? 'رابط السيرفر http://...' : 'رابط M3U http://...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: hasFocus ? Colors.red : Colors.white54, width: 2)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 3)),
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
                              style: const TextStyle(color: Colors.white, fontSize: 22),
                              decoration: InputDecoration(
                                filled: true, fillColor: Colors.black54,
                                hintText: 'اسم المستخدم',
                                hintStyle: const TextStyle(color: Colors.white54),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: hasFocus ? Colors.red : Colors.white54, width: 2)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 3)),
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
                              style: const TextStyle(color: Colors.white, fontSize: 22),
                              decoration: InputDecoration(
                                filled: true, fillColor: Colors.black54,
                                hintText: 'كلمة المرور',
                                hintStyle: const TextStyle(color: Colors.white54),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: hasFocus ? Colors.red : Colors.white54, width: 2)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 3)),
                              ),
                            );
                          }),
                        ),
                      ],
                      
                      const SizedBox(height: 40),
                      Focus(
                        child: Builder(builder: (context) {
                          final hasFocus = Focus.of(context).hasFocus;
                          return SizedBox(
                            width: double.infinity, height: 70,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                side: BorderSide(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                              ),
                              child: isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('دخول', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.75),
          child: Center(
            child: FocusTraversalGroup(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('+420777099379', style: TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('BEST IPTV', style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold)),
                  const Text('Service Provider', style: TextStyle(fontSize: 22, color: Colors.white70)),
                  const SizedBox(height: 80),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _buildBtn('LIVE TV', Icons.live_tv, true, () => _openPlayer()),
                    const SizedBox(width: 40),
                    _buildBtn('SERIES', Icons.tv, false, () {}),
                    const SizedBox(width: 40),
                    _buildBtn('FILMS', Icons.movie, false, () {}),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _openPlayer() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
  }

  Widget _buildBtn(String title, IconData icon, bool autofocus, VoidCallback onTap) {
    return Focus(
      autofocus: autofocus,
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 300, height: 180,
            decoration: BoxDecoration(
              color: hasFocus ? Colors.red : Colors.grey.shade900.withOpacity(0.8),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: hasFocus ? Colors.white : Colors.white30, width: hasFocus ? 5 : 2),
              boxShadow: hasFocus ? [BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 25, spreadRadius: 5)] : [],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 70, color: Colors.white),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
            ]),
          ),
        );
      }),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late BetterPlayerController _controller;
  
  @override
  void initState() {
    super.initState();
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", // Test stream
    );
    _controller = BetterPlayerController(
      const BetterPlayerConfiguration(autoPlay: true, fit: BoxFit.contain),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: BetterPlayer(controller: _controller)),
    );
  }
}

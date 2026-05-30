import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return MaterialApp(
      title: 'Kamel TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
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
  bool isLoading = false;

  // هذا اللي يخلي الريموت يخدم
  final FocusNode _xtreamFocus = FocusNode();
  final FocusNode _m3uFocus = FocusNode();
  final FocusNode _urlFocus = FocusNode();
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _loginFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // اول ما يفتح التطبيق، حط الفوكس على Xtream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_xtreamFocus);
    });
  }

  @override
  void dispose() {
    _xtreamFocus.dispose();
    _m3uFocus.dispose();
    _urlFocus.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    _loginFocus.dispose();
    super.dispose();
  }

  _login() async {
    if (url.text.isEmpty) return;
    setState(() => isLoading = true);
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    if (isXtream) {
      try {
        final response = await http.get(Uri.parse(
          '${url.text}/player_api.php?username=${user.text}&password=${pass.text}'
        ));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['user_info']['auth'] == 1) {
            await prefs.setBool('isLogged', true);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else {
            _showError('بيانات الدخول غالطة');
          }
        }
      } catch (e) {
        _showError('مشكل في الاتصال بالسيرفر');
      }
    } else {
      await prefs.setBool('isLogged', true);
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
          image: DecorationImage(image: AssetImage("assets/background.jpeg"), fit: BoxFit.cover),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.75),
          child: Center(
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
                      image: const DecorationImage(image: AssetImage("assets/icon.png"), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text('Kamel TV', style: TextStyle(fontSize: 36, color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 50),
                  
                  // Xtream Button
                  Focus(
                    focusNode: _xtreamFocus,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
                        FocusScope.of(context).requestFocus(_m3uFocus);
                        return KeyEventResult.handled;
                      }
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        FocusScope.of(context).requestFocus(_urlFocus);
                        return KeyEventResult.handled;
                      }
                      if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
                        setState(() => isXtream = true);
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Builder(builder: (context) {
                      final hasFocus = Focus.of(context).hasFocus;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: isXtream ? Colors.red : Colors.blue.shade900,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                        ),
                        child: const Center(child: Text('Xtream Codes', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  
                  // M3U Button
                  Focus(
                    focusNode: _m3uFocus,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        FocusScope.of(context).requestFocus(_xtreamFocus);
                        return KeyEventResult.handled;
                      }
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        FocusScope.of(context).requestFocus(_urlFocus);
                        return KeyEventResult.handled;
                      }
                      if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
                        setState(() => isXtream = false);
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Builder(builder: (context) {
                      final hasFocus = Focus.of(context).hasFocus;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: !isXtream ? Colors.red : Colors.blue.shade900,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                        ),
                        child: const Center(child: Text('M3U Playlist', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
                      );
                    }),
                  ),
                  const SizedBox(height: 35),
                  
                  // URL
                  Focus(
                    focusNode: _urlFocus,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        FocusScope.of(context).requestFocus(_xtreamFocus);
                        return KeyEventResult.handled;
                      }
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
                        FocusScope.of(context).requestFocus(isXtream ? _userFocus : _loginFocus);
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Builder(builder: (context) {
                      final hasFocus = Focus.of(context).hasFocus;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: hasFocus ? Colors.red : Colors.white54, width: hasFocus ? 3 : 2),
                        ),
                        child: TextField(
                          controller: url,
                          style: const TextStyle(color: Colors.white, fontSize: 22),
                          decoration: InputDecoration.collapsed(
                            hintText: isXtream ? 'رابط السيرفر' : 'رابط M3U',
                            hintStyle: const TextStyle(color: Colors.white54),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  if (isXtream) ...[
                    const SizedBox(height: 20),
                    // User
                    Focus(
                      focusNode: _userFocus,
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
                          FocusScope.of(context).requestFocus(_urlFocus);
                          return KeyEventResult.handled;
                        }
                        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
                          FocusScope.of(context).requestFocus(_passFocus);
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Builder(builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: hasFocus ? Colors.red : Colors.white54, width: hasFocus ? 3 : 2),
                          ),
                          child: TextField(
                            controller: user,
                            style: const TextStyle(color: Colors.white, fontSize: 22),
                            decoration: const InputDecoration.collapsed(
                              hintText: 'اسم المستخدم',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    // Pass
                    Focus(
                      focusNode: _passFocus,
                      onKeyEvent: (node, event) {
                        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
                          FocusScope.of(context).requestFocus(_userFocus);
                          return KeyEventResult.handled;
                        }
                        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowDown) {
                          FocusScope.of(context).requestFocus(_loginFocus);
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: Builder(builder: (context) {
                        final hasFocus = Focus.of(context).hasFocus;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: hasFocus ? Colors.red : Colors.white54, width: hasFocus ? 3 : 2),
                          ),
                          child: TextField(
                            controller: pass,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white, fontSize: 22),
                            decoration: const InputDecoration.collapsed(
                              hintText: 'كلمة المرور',
                              hintStyle: TextStyle(color: Colors.white54),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  // Login Button
                  Focus(
                    focusNode: _loginFocus,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        FocusScope.of(context).requestFocus(isXtream ? _passFocus : _urlFocus);
                        return KeyEventResult.handled;
                      }
                      if (event is KeyDownEvent && (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
                        if (!isLoading) _login();
                        return KeyEventResult.handled;
                      }
                      return KeyEventResult.ignored;
                    },
                    child: Builder(builder: (context) {
                      final hasFocus = Focus.of(context).hasFocus;
                      return Container(
                        width: double.infinity, height: 70,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: hasFocus ? Colors.white : Colors.transparent, width: 4),
                        ),
                        child: Center(
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
        child: Container(
          color: Colors.black.withOpacity(0.75),
          child: Center(child: Text('Home Screen', style: TextStyle(fontSize: 50))),
        ),
      ),
    );
  }
}

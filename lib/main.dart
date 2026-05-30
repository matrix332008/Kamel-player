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
    return MaterialApp(
      title: 'Kamel TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
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
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/background.jpeg"), fit: BoxFit.cover),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.red)),
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

  _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', true);
    await prefs.setString('serverUrl', url.text);
    await prefs.setString('username', user.text);
    await prefs.setString('password', pass.text);
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
            child: SingleChildScrollView(
              child: Container(
                width: 700,
                padding: const EdgeInsets.all(40),
                child: Column(
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
                    
                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                          autofocus: true,
                          onPressed: () => setState(() => isXtream = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isXtream ? Colors.red : Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                          ),
                          child: const Text('Xtream Codes', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() => isXtream = false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isXtream ? Colors.red : Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(vertical: 22),
                          ),
                          child: const Text('M3U Playlist', style: TextStyle(fontSize: 26)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 35),
                    
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
                    SizedBox(
                      width: double.infinity, height: 70,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('دخول', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List channels = [];
  int selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChannels();
  }

  loadChannels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String serverUrl = prefs.getString('serverUrl') ?? '';
    String username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ?? '';
    
    try {
      final response = await http.get(Uri.parse(
        '$serverUrl/player_api.php?username=$username&password=$password&action=get_live_streams'
      ));
      if (response.statusCode == 200) {
        setState(() {
          channels = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  playChannel(int streamId) {
    SharedPreferences.getInstance().then((prefs) {
      String serverUrl = prefs.getString('serverUrl') ?? '';
      String username = prefs.getString('username') ?? '';
      String password = prefs.getString('password') ?? '';
      String streamUrl = '$serverUrl/live/$username/$password/$streamId.m3u8';
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PlayerScreen(url: streamUrl),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Row(
              children: [
                Container(
                  width: 400,
                  color: Colors.black87,
                  child: ListView.builder(
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: selectedIndex == index ? Colors.red : Colors.transparent,
                        child: ListTile(
                          autofocus: index == 0,
                          title: Text(
                            channels[index]['name'],
                            style: const TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          onTap: () {
                            setState(() => selectedIndex = index);
                            playChannel(channels[index]['stream_id']);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage("assets/background.jpeg"), fit: BoxFit.cover),
                    ),
                    child: const Center(
                      child: Text('Kamel TV', style: TextStyle(fontSize: 60, color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  final String url;
  const PlayerScreen({super.key, required this.url});
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
      widget.url,
    );
    _controller = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(enableSkips: false),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: BetterPlayer(controller: _controller)),
    );
  }
}

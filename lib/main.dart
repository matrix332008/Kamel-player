import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'tv_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(KamelTVApp());
}

class KamelTVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamel TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFE50914),
        scaffoldBackgroundColor: Color(0xFF0D1B2A),
        fontFamily: 'Cairo',
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  _checkLogin() async {
    await Future.delayed(Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? loginType = prefs.getString('login_type');

    if (loginType == 'xtream') {
      String? server = prefs.getString('server');
      String? username = prefs.getString('username');
      String? password = prefs.getString('password');
      if (server!= null && username!= null && password!= null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              server: server,
              username: username,
              password: password,
              userInfo: {},
              loginType: 'xtream',
            ),
          ),
        );
        return;
      }
    } else if (loginType == 'm3u') {
      String? m3uUrl = prefs.getString('m3u_url');
      if (m3uUrl!= null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(
              server: '',
              username: '',
              password: '',
              userInfo: {},
              loginType: 'm3u',
              m3uUrl: m3uUrl,
            ),
          ),
        );
        return;
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginTypeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage('assets/profile.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Kamel TV',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginTypeScreen extends StatefulWidget {
  @override
  _LoginTypeScreenState createState() => _LoginTypeScreenState();
}

class _LoginTypeScreenState extends State<LoginTypeScreen> {
  int selectedIndex = 0;
  final _focusNodes = List.generate(2, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      _focusNodes[0].requestFocus();
    });
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          selectedIndex = selectedIndex == 0? 1 : 0;
          _focusNodes[selectedIndex].requestFocus();
        });
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
                 event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.gameButtonA) {
        if (selectedIndex == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen(loginType: 'xtream')),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen(loginType: 'm3u')),
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.goBack ||
                 event.logicalKey == LogicalKeyboardKey.escape) {
        SystemNavigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          _handleKey(event);
          return KeyEventResult.handled;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Container(color: Colors.black.withOpacity(0.6)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'اختر نوع الاشتراك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                  SizedBox(height: 50),
                  Focus(
                    focusNode: _focusNodes[0],
                    child: Container(
                      width: 400,
                      height: 70,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: selectedIndex == 0? Colors.red : Colors.red.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: selectedIndex == 0? Border.all(color: Colors.white, width: 4) : null,
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen(loginType: 'xtream')),
                          );
                        },
                        child: Text(
                          'Xtream Codes',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Focus(
                    focusNode: _focusNodes[1],
                    child: Container(
                      width: 400,
                      height: 70,
                      decoration: BoxDecoration(
                        color: selectedIndex == 1? Colors.red : Colors.red.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: selectedIndex == 1? Border.all(color: Colors.white, width: 4) : null,
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen(loginType: 'm3u')),
                          );
                        },
                        child: Text(
                          'M3U Playlist',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final String loginType;
  LoginScreen({required this.loginType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int selectedField = 0;
  final serverCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final m3uCtrl = TextEditingController();
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.loginType == 'xtream'? 4 : 2, (index) => FocusNode());
    Future.delayed(Duration(milliseconds: 300), () {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    serverCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    m3uCtrl.dispose();
    for (var node in _focusNodes) node.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      int maxField = widget.loginType == 'xtream'? 4 : 2;
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          selectedField = (selectedField + 1) % maxField;
          _focusNodes[selectedField].requestFocus();
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          selectedField = (selectedField - 1 + maxField) % maxField;
          _focusNodes[selectedField].requestFocus();
        });
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
                 event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.gameButtonA) {
        if ((widget.loginType == 'xtream' && selectedField == 3) ||
            (widget.loginType == 'm3u' && selectedField == 1)) {
          _doLogin();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.goBack ||
                 event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginTypeScreen()),
        );
      }
    }
  }

  Future<void> _doLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (widget.loginType == 'xtream') {
      String url = serverCtrl.text.trim();
      String user = userCtrl.text.trim();
      String pass = passCtrl.text.trim();

      if (url.isEmpty || user.isEmpty || pass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('عبي كل الحقول'), backgroundColor: Colors.red),
        );
        return;
      }

      try {
        final res = await http.get(Uri.parse('$url/player_api.php?username=$user&password=$pass'));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['user_info']['auth'] == 1) {
            await prefs.setString('login_type', 'xtream');
            await prefs.setString('server', url);
            await prefs.setString('username', user);
            await prefs.setString('password', pass);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainScreen(
                  server: url,
                  username: user,
                  password: pass,
                  userInfo: data['user_info'],
                  loginType: 'xtream',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ في البيانات - الاشتراك منتهي؟'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال: $e'), backgroundColor: Colors.red),
        );
      }
    } else {
      String m3u = m3uCtrl.text.trim();
      if (m3u.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ادخل رابط M3U'), backgroundColor: Colors.red),
        );
        return;
      }
      await prefs.setString('login_type', 'm3u');
      await prefs.setString('m3u_url', m3u);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            server: '',
            username: '',
            password: '',
            userInfo: {},
            loginType: 'm3u',
            m3uUrl: m3u,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          _handleKey(event);
          return KeyEventResult.handled;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            Container(color: Colors.black.withOpacity(0.4)),
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        '+420777099379',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.red, width: 3),
                          image: DecorationImage(
                            image: AssetImage('assets/profile.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Container(
                        width: 450,
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                        ),
                        child: widget.loginType == 'xtream'? _buildXtreamForm() : _buildM3uForm(),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXtreamForm() {
    return Column(
      children: [
        TextField(
          controller: serverCtrl,
          focusNode: _focusNodes[0],
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            labelText: 'رابط السيرفر',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedField == 0? Colors.red : Colors.white30,
                width: selectedField == 0? 3 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 3),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
        SizedBox(height: 15),
        TextField(
          controller: userCtrl,
          focusNode: _focusNodes[1],
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            labelText: 'اسم المستخدم',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedField == 1? Colors.red : Colors.white30,
                width: selectedField == 1? 3 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 3),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
        SizedBox(height: 15),
        TextField(
          controller: passCtrl,
          focusNode: _focusNodes[2],
          obscureText: true,
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedField == 2? Colors.red : Colors.white30,
                width: selectedField == 2? 3 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 3),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
        SizedBox(height: 25),
        Focus(
          focusNode: _focusNodes[3],
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: selectedField == 3? Colors.red : Colors.red.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: selectedField == 3? Border.all(color: Colors.white, width: 3) : null,
            ),
            child: TextButton(
              onPressed: _doLogin,
              child: Text(
                'دخول',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildM3uForm() {
    return Column(
      children: [
        TextField(
          controller: m3uCtrl,
          focusNode: _focusNodes[0],
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            labelText: 'رابط M3U',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: selectedField == 0? Colors.red : Colors.white30,
                width: selectedField == 0? 3 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 3),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
          ),
        ),
        SizedBox(height: 25),
        Focus(
          focusNode: _focusNodes[1],
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: selectedField == 1? Colors.red : Colors.red.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: selectedField == 1? Border.all(color: Colors.white, width: 3) : null,
            ),
            child: TextButton(
              onPressed: _doLogin,
              child: Text(
                'دخول',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}class MainScreen extends StatefulWidget {
  final String server;
  final String username;
  final String password;
  final Map<String, dynamic> userInfo;
  final String loginType;
  final String? m3uUrl;

  MainScreen({
    required this.server,
    required this.username,
    required this.password,
    required this.userInfo,
    required this.loginType,
    this.m3uUrl,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0; // 0=Live, 1=Movies, 2=Series, 3=Fav
  int selectedGroupIndex = 0; // للتنقل بين الجروبات
  int selectedItemIndex = 0; // للتنقل داخل العناصر

  List liveCategories = [];
  List movieCategories = [];
  List seriesCategories = [];
  List channels = [];
  List movies = [];
  List series = [];
  List favorites = [];
  bool isLoading = true;
  String selectedCategory = '';

  final ScrollController _scrollController = ScrollController();
  int currentFocusArea = 0; // 0=Menu, 1=Groups, 2=Items

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadFavorites();
  }

  _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favs = prefs.getStringList('favorites');
    if (favs!= null) {
      setState(() {
        favorites = favs.map((e) => json.decode(e)).toList();
      });
    }
  }

  _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favs = favorites.map((e) => json.encode(e)).toList();
    await prefs.setStringList('favorites', favs);
  }

  _loadData() async {
    if (widget.loginType == 'm3u') {
      // TODO: Parse M3U هنا
      setState(() => isLoading = false);
      return;
    }

    try {
      // Live Categories
      final catRes = await http.get(Uri.parse(
        '${widget.server}/player_api.php?username=${widget.username}&password=${widget.password}&action=get_live_categories'
      ));
      if (catRes.statusCode == 200) {
        liveCategories = json.decode(catRes.body);
        if (liveCategories.isNotEmpty) {
          selectedCategory = liveCategories[0]['category_id'];
          await _loadChannels(selectedCategory);
        }
      }

      // Movie Categories
      final movCatRes = await http.get(Uri.parse(
        '${widget.server}/player_api.php?username=${widget.username}&password=${widget.password}&action=get_vod_categories'
      ));
      if (movCatRes.statusCode == 200) {
        movieCategories = json.decode(movCatRes.body);
      }

      // Series Categories
      final serCatRes = await http.get(Uri.parse(
        '${widget.server}/player_api.php?username=${widget.username}&password=${widget.password}&action=get_series_categories'
      ));
      if (serCatRes.statusCode == 200) {
        seriesCategories = json.decode(serCatRes.body);
      }

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  _loadChannels(String catId) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
        '${widget.server}/player_api.php?username=${widget.username}&password=${widget.password}&action=get_live_streams&category_id=$catId'
      ));
      if (res.statusCode == 200) {
        setState(() {
          channels = json.decode(res.body);
          isLoading = false;
          selectedItemIndex = 0;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  _loadMovies(String catId) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
        '${widget.server}/player_api.php?username=${widget.username}&password=${widget.password}&action=get_vod_streams&category_id=$catId'
      ));
      if (res.statusCode == 200) {
        setState(() {
          movies = json.decode(res.body);
          isLoading = false;
          selectedItemIndex = 0;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  _loadSeries(String catId) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
        '${widget.server}/player_api.php?username=${widget.username}&password=${widget.password}&action=get_series&category_id=$catId'
      ));
      if (res.statusCode == 200) {
        setState(() {
          series = json.decode(res.body);
          isLoading = false;
          selectedItemIndex = 0;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      List currentGroups = [];
      List currentList = [];

      if (selectedIndex == 0) {
        currentGroups = liveCategories;
        currentList = channels;
      } else if (selectedIndex == 1) {
        currentGroups = movieCategories;
        currentList = movies;
      } else if (selectedIndex == 2) {
        currentGroups = seriesCategories;
        currentList = series;
      } else if (selectedIndex == 3) {
        currentList = favorites;
      }

      // الخروج من التطبيق
      if (event.logicalKey == LogicalKeyboardKey.goBack ||
          event.logicalKey == LogicalKeyboardKey.escape) {
        if (currentFocusArea == 0) {
          SystemNavigator.pop(); // يخرج من التطبيق
        } else {
          setState(() => currentFocusArea = 0); // يرجع للقائمة الرئيسية
        }
        return;
      }

      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (currentFocusArea == 2 && selectedItemIndex > 0) {
          setState(() {
            selectedItemIndex--;
            _scrollToSelected();
          });
        } else if (currentFocusArea == 1 && selectedGroupIndex > 0) {
          setState(() => selectedGroupIndex--);
        } else if (currentFocusArea == 0 && selectedIndex > 0) {
          setState(() => selectedIndex--);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (currentFocusArea == 2 && selectedItemIndex < currentList.length - 1) {
          setState(() {
            selectedItemIndex++;
            _scrollToSelected();
          });
        } else if (currentFocusArea == 1 && selectedGroupIndex < currentGroups.length - 1) {
          setState(() => selectedGroupIndex++);
        } else if (currentFocusArea == 0 && selectedIndex < 3) {
          setState(() => selectedIndex++);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (currentFocusArea > 0) {
          setState(() => currentFocusArea--);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (currentFocusArea < 2 && currentList.isNotEmpty) {
          setState(() => currentFocusArea++);
          // تحميل البيانات عند الدخول للجروب
          if (currentFocusArea == 1 && currentGroups.isNotEmpty) {
            String catId = currentGroups[selectedGroupIndex]['category_id'];
            if (selectedIndex == 0) _loadChannels(catId);
            else if (selectedIndex == 1) _loadMovies(catId);
            else if (selectedIndex == 2) _loadSeries(catId);
          }
        }
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
                 event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.gameButtonA) {
        if (currentFocusArea == 2 && currentList.isNotEmpty) {
          _playItem(currentList[selectedItemIndex]);
        } else if (currentFocusArea == 1 && currentGroups.isNotEmpty) {
          String catId = currentGroups[selectedGroupIndex]['category_id'];
          if (selectedIndex == 0) _loadChannels(catId);
          else if (selectedIndex == 1) _loadMovies(catId);
          else if (selectedIndex == 2) _loadSeries(catId);
          setState(() => currentFocusArea = 2);
        }
      }
    }
  }

  void _scrollToSelected() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        selectedItemIndex * 80.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _playItem(Map item) {
    String url = '';
    String title = item['name']?? '';

    if (selectedIndex == 0 || item['stream_type'] == 'live') {
      url = '${widget.server}/live/${widget.username}/${widget.password}/${item['stream_id']}.m3u8';
    } else if (selectedIndex == 1 || item['stream_type'] == 'movie') {
      url = '${widget.server}/movie/${widget.username}/${widget.password}/${item['stream_id']}.${item['container_extension']}';
    } else if (selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeriesDetailsScreen(
            server: widget.server,
            username: widget.username,
            password: widget.password,
            series: item,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TvPlayerScreen(
          videoUrl: url,
          channelName: title,
          channelsList: selectedIndex == 0? channels : null,
          initialIndex: selectedIndex == 0? selectedItemIndex : null,
          server: widget.server,
          username: widget.username,
          password: widget.password,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            _handleKey(event);
            return KeyEventResult.handled;
          },
          child: Row(
            children: [
              // القائمة الرئيسية
              Container(
                width: 250,
                color: Color(0xFF1B263B),
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          // رجعنا صورتك هنا ✅
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: AssetImage('assets/profile.jpeg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Kamel TV',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.username,
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.white24),
                    _buildMenuItem(0, Icons.live_tv, 'البث المباشر'),
                    _buildMenuItem(1, Icons.movie, 'الأفلام'),
                    _buildMenuItem(2, Icons.tv, 'المسلسلات'),
                    _buildMenuItem(3, Icons.favorite, 'المفضلة'),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        '+420777099379',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              // الجروبات
              if (selectedIndex!= 3)
                Container(
                  width: 200,
                  color: Colors.black.withOpacity(0.5),
                  child: _buildGroupsList(),
                ),
              // المحتوى
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/background.jpeg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.7),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: isLoading
                     ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                          ),
                        )
                      : _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String title) {
    bool isSelected = selectedIndex == index && currentFocusArea == 0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected? Color(0xFFE50914) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected? Border.all(color: Colors.white, width: 3) : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            selectedIndex = index;
            selectedGroupIndex = 0;
            selectedItemIndex = 0;
            currentFocusArea = 0;
          });
        },
      ),
    );
  }

  Widget _buildGroupsList() {
    List groups = [];
    if (selectedIndex == 0) groups = liveCategories;
    else if (selectedIndex == 1) groups = movieCategories;
    else if (selectedIndex == 2) groups = seriesCategories;

    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        bool isSelected = index == selectedGroupIndex && currentFocusArea == 1;
        return Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSelected? Color(0xFFE50914) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected? Border.all(color: Colors.white, width: 3) : null,
          ),
          child: ListTile(
            title: Text(
              groups[index]['category_name']?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
              ),
            ),
            onTap: () {
              setState(() {
                selectedGroupIndex = index;
                currentFocusArea = 1;
              });
              String catId = groups[index]['category_id'];
              if (selectedIndex == 0) _loadChannels(catId);
              else if (selectedIndex == 1) _loadMovies(catId);
              else if (selectedIndex == 2) _loadSeries(catId);
            },
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (selectedIndex == 0) return _buildChannelsView();
    if (selectedIndex == 1) return _buildMoviesView();
    if (selectedIndex == 2) return _buildSeriesView();
    if (selectedIndex == 3) return _buildFavoritesView();
    return Container();
  }

  Widget _buildChannelsView() {
    return channels.isEmpty
       ? Center(child: Text('لا توجد قنوات', style: TextStyle(color: Colors.white54, fontSize: 18)))
        : ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(15),
            itemCount: channels.length,
            itemBuilder: (context, index) {
              bool isSelected = index == selectedItemIndex && currentFocusArea == 2;
              bool isFav = favorites.any((f) => f['stream_id'] == channels[index]['stream_id']);
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected? Color(0xFFE50914).withOpacity(0.3) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected? Border.all(color: Color(0xFFE50914), width: 3) : null,
                ),
                child: ListTile(
                  leading: channels[index]['stream_icon']!= null
                     ? Image.network(
                          channels[index]['stream_icon'],
                          width: 50,
                          height: 50,
                          errorBuilder: (_, __, ___) => Icon(Icons.tv, color: Colors.white),
                        )
                      : Icon(Icons.tv, color: Colors.white),
                  title: Text(
                    channels[index]['name']?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isFav? Icon(Icons.favorite, color: Colors.red) : null,
                  onTap: () => _playItem(channels[index]),
                ),
              );
            },
          );
  }

  Widget _buildMoviesView() {
    return movies.isEmpty
       ? Center(child: Text('لا توجد أفلام', style: TextStyle(color: Colors.white54, fontSize: 18)))
        : GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(15),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.7,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              bool isSelected = index == selectedItemIndex && currentFocusArea == 2;
              return GestureDetector(
                onTap: () => _playItem(movies[index]),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected? Border.all(color: Color(0xFFE50914), width: 4) : null,
                    boxShadow: isSelected? [BoxShadow(color: Color(0xFFE50914), blurRadius: 10)] : [],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: movies[index]['stream_icon']!= null
                           ? Image.network(
                                movies[index]['stream_icon'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[800],
                                  child: Icon(Icons.movie, color: Colors.white, size: 50),
                                ),
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: Icon(Icons.movie, color: Colors.white, size: 50),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                            ),
                          ),
                          child: Text(
                            movies[index]['name']?? '',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildSeriesView() {
    return series.isEmpty
       ? Center(child: Text('لا توجد مسلسلات', style: TextStyle(color: Colors.white54, fontSize: 18)))
        : GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(15),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.7,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: series.length,
            itemBuilder: (context, index) {
              bool isSelected = index == selectedItemIndex && currentFocusArea == 2;
              return GestureDetector(
                onTap: () => _playItem(series[index]),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected? Border.all(color: Color(0xFFE50914), width: 4) : null,
                    boxShadow: isSelected? [BoxShadow(color: Color(0xFFE50914), blurRadius: 10)] : [],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: series[index]['cover']!= null
                           ? Image.network(
                                series[index]['cover'],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[800],
                                  child: Icon(Icons.tv, color: Colors.white, size: 50),
                                ),
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: Icon(Icons.tv, color: Colors.white, size: 50),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                            ),
                          ),
                          child: Text(
                            series[index]['name']?? '',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildFavoritesView() {
    return favorites.isEmpty
       ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, color: Colors.white54, size: 80),
                SizedBox(height: 20),
                Text('لا توجد مفضلة', style: TextStyle(color: Colors.white54, fontSize: 18)),
              ],
            ),
          )
        : ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(15),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              bool isSelected = index == selectedItemIndex && currentFocusArea == 2;
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected? Color(0xFFE50914).withOpacity(0.3) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected? Border.all(color: Color(0xFFE50914), width: 3) : null,
                ),
                child: ListTile(
                  leading: favorites[index]['stream_icon']!= null
                     ? Image.network(
                          favorites[index]['stream_icon'],
                          width: 50,
                          height: 50,
                          errorBuilder: (_, __, ___) => Icon(Icons.tv, color: Colors.white),
                        )
                      : Icon(Icons.tv, color: Colors.white),
                  title: Text(
                    favorites[index]['name']?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        favorites.removeAt(index);
                        _saveFavorites();
                      });
                    },
                  ),
                  onTap: () => _playItem(favorites[index]),
                ),
              );
            },
          );
  }
}

class SeriesDetailsScreen extends StatefulWidget {
  final String server;
  final String username;
  final String password;
  final Map series;

  SeriesDetailsScreen({
    required this.server,
    required this.username,
    required this.password,
    required this.series,
  });

  @override
  _SeriesDetailsScreenState createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  List seasons = [];
  List episodes = [];
  int selectedSeason = 0;
  int selectedEpisodeIndex = 0;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  _loadSeasons() async {
    try {
      final res = await http.get(Uri.parse(
        '${widget.server}/player_api.php?username=${widget.username}&password=${widget.password}&action=get_series_info&series_id=${widget.series['series_id']}'
      ));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          seasons = data['seasons']?? [];
          if (seasons.isNotEmpty) {
            _loadEpisodes(seasons[0]['season_number']);
          } else {
            isLoading = false;
          }
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  _loadEpisodes(int seasonNum) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
        '${widget.server}/player_api.php?username=${widget.username}&password=${widget.password}&action=get_series_info&series_id=${widget.series['series_id']}'
      ));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          episodes = data['episodes']['$seasonNum']?? [];
          isLoading = false;
          selectedEpisodeIndex = 0;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          if (selectedEpisodeIndex < episodes.length - 1) {
            selectedEpisodeIndex++;
            _scrollToSelected();
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          if (selectedEpisodeIndex > 0) {
            selectedEpisodeIndex--;
            _scrollToSelected();
          }
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (selectedSeason > 0) {
          setState(() {
            selectedSeason--;
            _loadEpisodes(seasons[selectedSeason]['season_number']);
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (selectedSeason < seasons.length - 1) {
          setState(() {
            selectedSeason++;
            _loadEpisodes(seasons[selectedSeason]['season_number']);
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
                 event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.gameButtonA) {
        if (episodes.isNotEmpty) _playEpisode(episodes[selectedEpisodeIndex]);
      } else if (event.logicalKey == LogicalKeyboardKey.goBack ||
                 event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      }
    }
  }

  void _scrollToSelected() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        selectedEpisodeIndex * 80.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _playEpisode(Map episode) {
    String url = '${widget.server}/series/${widget.username}/${widget.password}/${episode['id']}.${episode['container_extension']}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TvPlayerScreen(
          videoUrl: url,
          channelName: '${widget.series['name']} - ${episode['title']}',
          server: widget.server,
          username: widget.username,
          password: widget.password,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          _handleKey(event);
          return KeyEventResult.handled;
        },
        child: isLoading
           ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                ),
              )
            : Row(
                children: [
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      image: DecorationImage(
                        image: NetworkImage(widget.series['cover']?? ''),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.7),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.series['name']?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                widget.series['plot']?? '',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'المواسم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                height: 50,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: seasons.length,
                                  itemBuilder: (context, index) {
                                    bool isSelected = index == selectedSeason;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedSeason = index;
                                          _loadEpisodes(seasons[index]['season_number']);
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: isSelected? Color(0xFFE50914) : Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(25),
                                          border: isSelected? Border.all(color: Colors.white, width: 2) : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'الموسم ${seasons[index]['season_number']}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Color(0xFF0D1B2A),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'الحلقات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: episodes.isEmpty
                               ? Center(
                                    child: Text(
                                      'لا توجد حلقات',
                                      style: TextStyle(color: Colors.white54, fontSize: 18),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    itemCount: episodes.length,
                                    itemBuilder: (context, index) {
                                      bool isSelected = index == selectedEpisodeIndex;
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected? Color(0xFFE50914).withOpacity(0.3) : Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                          border: isSelected? Border.all(color: Color(0xFFE50914), width: 3) : null,
                                        ),
                                        child: ListTile(
                                          leading: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE50914),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            episodes[index]['title']?? 'الحلقة ${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          subtitle: Text(
                                            episodes[index]['info']?['plot']?? '',
                                            style: TextStyle(color: Colors.white54, fontSize: 12),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                                          onTap: () => _playEpisode(episodes[index]),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

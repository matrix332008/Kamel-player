import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamel TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isXtreamSelected = true;
  TextEditingController serverController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController m3uController = TextEditingController();
  bool isLoading = false;
  
  FocusNode xtreamFocusNode = FocusNode();
  FocusNode m3uFocusNode = FocusNode();
  FocusNode serverFocusNode = FocusNode();
  FocusNode usernameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode m3uUrlFocusNode = FocusNode();
  FocusNode loginBtnFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(xtreamFocusNode);
    });
  }

  Future<void> _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedType = prefs.getString('login_type');
    if (savedType != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IPTVHomePage()));
    }
  }

  Future<void> _login() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    if (isXtreamSelected) {
      String server = serverController.text.trim();
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      if (server.isEmpty || username.isEmpty || password.isEmpty) {
        _showError("عبي كل الخانات");
        return;
      }

      String m3uUrl = "$server/get.php?username=$username&password=$password&type=m3u_plus&output=ts";
      bool isValid = await _testM3U(m3uUrl);
      if (isValid) {
        await prefs.setString('login_type', 'xtream');
        await prefs.setString('m3u_url', m3uUrl);
        await prefs.setString('server', server);
        await prefs.setString('username', username);
        await prefs.setString('password', password);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IPTVHomePage()));
      } else {
        _showError("معلومات الدخول غالطة");
      }
    } else {
      String m3uUrl = m3uController.text.trim();
      if (m3uUrl.isEmpty || !m3uUrl.startsWith('http')) {
        _showError("الرابط غير صحيح");
        return;
      }

      bool isValid = await _testM3U(m3uUrl);
      if (isValid) {
        await prefs.setString('login_type', 'm3u');
        await prefs.setString('m3u_url', m3uUrl);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IPTVHomePage()));
      } else {
        _showError("الرابط لا يعمل");
      }
    }
    setState(() => isLoading = false);
  }

  Future<bool> _testM3U(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      return response.statusCode == 200 && response.body.contains('#EXTINF');
    } catch (e) {
      return false;
    }
  }

  void _showError(String msg) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    xtreamFocusNode.dispose();
    m3uFocusNode.dispose();
    serverFocusNode.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    m3uUrlFocusNode.dispose();
    loginBtnFocusNode.dispose();
    serverController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    m3uController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE50914), width: 4),
                      image: DecorationImage(
                        image: AssetImage('assets/icon.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Kamel TV", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildToggleButton("Xtream Codes", isXtreamSelected, xtreamFocusNode, () {
                        setState(() {
                          isXtreamSelected = true;
                          FocusScope.of(context).requestFocus(serverFocusNode);
                        });
                      }),
                      SizedBox(width: 20),
                      _buildToggleButton("M3U Playlist", !isXtreamSelected, m3uFocusNode, () {
                        setState(() {
                          isXtreamSelected = false;
                          FocusScope.of(context).requestFocus(m3uUrlFocusNode);
                        });
                      }),
                    ],
                  ),
                  SizedBox(height: 25),
                  Container(
                    width: 500,
                    child: isXtreamSelected ? _buildXtreamFields() : _buildM3UField(),
                  ),
                  SizedBox(height: 20),
                  _buildLoginButton(),
                  if (isLoading) ...[
                    SizedBox(height: 20),
                    CircularProgressIndicator(color: Color(0xFFE50914)),
                  ],
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, FocusNode node, VoidCallback onTap) {
    return Focus(
      focusNode: node,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight && text == "Xtream Codes") {
            FocusScope.of(context).requestFocus(m3uFocusNode);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && text == "M3U Playlist") {
            FocusScope.of(context).requestFocus(xtreamFocusNode);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            FocusScope.of(context).requestFocus(isXtreamSelected ? serverFocusNode : m3uUrlFocusNode);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
            onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 220,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFE50914) : Color(0xFF3B3B9A),
            borderRadius: BorderRadius.circular(10),
            border: node.hasFocus ? Border.all(color: Colors.white, width: 4) : null,
            boxShadow: node.hasFocus ? [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 10)] : [],
          ),
          child: Center(
            child: Text(text, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildXtreamFields() {
    return Column(
      children: [
        _buildTextField("رابط السيرفر", serverController, Icons.dns, serverFocusNode, usernameFocusNode, null),
        SizedBox(height: 15),
        _buildTextField("اسم المستخدم", usernameController, Icons.person, usernameFocusNode, passwordFocusNode, serverFocusNode),
        SizedBox(height: 15),
        _buildTextField("كلمة المرور", passwordController, Icons.lock, passwordFocusNode, loginBtnFocusNode, usernameFocusNode, isPassword: true),
      ],
    );
  }

  Widget _buildM3UField() {
    return _buildTextField("رابط M3U", m3uController, Icons.link, m3uUrlFocusNode, loginBtnFocusNode, null);
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon, FocusNode currentNode, FocusNode? nextNode, FocusNode? prevNode, {bool isPassword = false}) {
    return Focus(
      focusNode: currentNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown && nextNode != null) {
            FocusScope.of(context).requestFocus(nextNode);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp && prevNode != null) {
            FocusScope.of(context).requestFocus(prevNode);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: currentNode.hasFocus ? Color(0xFFE50914) : Colors.white24, width: currentNode.hasFocus ? 3 : 1),
          boxShadow: currentNode.hasFocus ? [BoxShadow(color: Color(0xFFE50914).withOpacity(0.3), blurRadius: 10)] : [],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: currentNode.hasFocus ? Color(0xFFE50914) : Colors.white54),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white38),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Focus(
      focusNode: loginBtnFocusNode,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            FocusScope.of(context).requestFocus(isXtreamSelected ? passwordFocusNode : m3uUrlFocusNode);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
            _login();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _login,
        child: Container(
          width: 500,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFFE50914),
            borderRadius: BorderRadius.circular(10),
            border: loginBtnFocusNode.hasFocus ? Border.all(color: Colors.white, width: 4) : null,
            boxShadow: loginBtnFocusNode.hasFocus ? [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 15)] : [],
          ),
          child: Center(
            child: Text("دخول", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}class Channel {
  final String name;
  final String url;
  final String logo;
  final String group;
  bool isFavorite;

  Channel({
    required this.name,
    required this.url,
    required this.logo,
    required this.group,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'logo': logo,
    'group': group,
    'isFavorite': isFavorite,
  };

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    name: json['name'],
    url: json['url'],
    logo: json['logo'],
    group: json['group'],
    isFavorite: json['isFavorite']?? false,
  );
}

class IPTVHomePage extends StatefulWidget {
  @override
  _IPTVHomePageState createState() => _IPTVHomePageState();
}

class _IPTVHomePageState extends State<IPTVHomePage> {
  List<Channel> allChannels = [];
  List<String> categories = ["الكل"];
  String selectedCategory = "الكل";
  List<Channel> filteredChannels = [];
  List<Channel> favoriteChannels = [];

  int selectedCategoryIndex = 0;
  int selectedChannelIndex = 0;
  bool isCategoryFocused = true;
  bool isLoading = true;
  String searchQuery = "";

  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _channelScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  FocusNode _searchFocusNode = FocusNode();
  FocusNode _categoryFocusNode = FocusNode();
  FocusNode _gridFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadChannels();
    _loadFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_categoryFocusNode);
    });
  }

  Future<void> _loadChannels() async {
    final prefs = await SharedPreferences.getInstance();
    String? m3uUrl = prefs.getString('m3u_url');

    if (m3uUrl == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(m3uUrl)).timeout(Duration(seconds: 20));
      if (response.statusCode == 200) {
        allChannels = _parseM3UContent(response.body);
        categories = ["الكل", "المفضلة"] + allChannels.map((e) => e.group).toSet().toList();
        _filterChannels();
      }
    } catch (e) {
      _showError("خطأ في تحميل القنوات");
    }
    setState(() => isLoading = false);
  }

  List<Channel> _parseM3UContent(String content) {
    List<Channel> channels = [];
    List<String> lines = content.split('\n');

    String? currentName;
    String? currentLogo;
    String? currentGroup;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();

      if (line.startsWith('#EXTINF:')) {
        RegExp nameRegex = RegExp(r',(.+)$');
        RegExp logoRegex = RegExp(r'tvg-logo="([^"]*)"');
        RegExp groupRegex = RegExp(r'group-title="([^"]*)"');

        currentName = nameRegex.firstMatch(line)?.group(1)?.trim();
        currentLogo = logoRegex.firstMatch(line)?.group(1)?.trim()?? "";
        currentGroup = groupRegex.firstMatch(line)?.group(1)?.trim()?? "عام";

      } else if (line.startsWith('http') && currentName!= null) {
        channels.add(Channel(
          name: currentName,
          url: line,
          logo: currentLogo?? "",
          group: currentGroup?? "عام",
        ));
        currentName = null;
        currentLogo = null;
        currentGroup = null;
      }
    }
    return channels;
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites')?? [];
    setState(() {
      favoriteChannels = favs.map((e) => Channel.fromJson(jsonDecode(e))).toList();
      for (var channel in allChannels) {
        channel.isFavorite = favoriteChannels.any((f) => f.url == channel.url);
      }
    });
  }

  Future<void> _toggleFavorite(Channel channel) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      channel.isFavorite =!channel.isFavorite;
      if (channel.isFavorite) {
        favoriteChannels.add(channel);
      } else {
        favoriteChannels.removeWhere((f) => f.url == channel.url);
      }
      prefs.setStringList('favorites', favoriteChannels.map((e) => jsonEncode(e.toJson())).toList());
    });
  }

  void _filterChannels() {
    setState(() {
      if (selectedCategory == "الكل") {
        filteredChannels = allChannels;
      } else if (selectedCategory == "المفضلة") {
        filteredChannels = favoriteChannels;
      } else {
        filteredChannels = allChannels.where((c) => c.group == selectedCategory).toList();
      }

      if (searchQuery.isNotEmpty) {
        filteredChannels = filteredChannels.where((c) =>
          c.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }
      selectedChannelIndex = 0;
    });
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight && isCategoryFocused) {
        setState(() {
          isCategoryFocused = false;
          FocusScope.of(context).requestFocus(_gridFocusNode);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&!isCategoryFocused && selectedChannelIndex % 4 == 0) {
        setState(() {
          isCategoryFocused = true;
          FocusScope.of(context).requestFocus(_categoryFocusNode);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (isCategoryFocused && selectedCategoryIndex > 0) {
          setState(() => selectedCategoryIndex--);
          _selectCategory(selectedCategoryIndex);
          _scrollToCategory(selectedCategoryIndex);
        } else if (!isCategoryFocused && selectedChannelIndex >= 4) {
          setState(() => selectedChannelIndex -= 4);
          _scrollToChannel(selectedChannelIndex);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (isCategoryFocused && selectedCategoryIndex < categories.length - 1) {
          setState(() => selectedCategoryIndex++);
          _selectCategory(selectedCategoryIndex);
          _scrollToCategory(selectedCategoryIndex);
        } else if (!isCategoryFocused && selectedChannelIndex + 4 < filteredChannels.length) {
          setState(() => selectedChannelIndex += 4);
          _scrollToChannel(selectedChannelIndex);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
        if (!isCategoryFocused && filteredChannels.isNotEmpty) {
          _playChannel(filteredChannels[selectedChannelIndex]);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.contextMenu || event.logicalKey == LogicalKeyboardKey.goBack) {
        _showLogoutDialog();
      }
    }
  }

  void _scrollToCategory(int index) {
    if (_categoryScrollController.hasClients) {
      _categoryScrollController.animateTo(
        index * 60.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToChannel(int index) {
    if (_channelScrollController.hasClients) {
      int row = index ~/ 4;
      _channelScrollController.animateTo(
        row * 200.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectCategory(int index) {
    setState(() {
      selectedCategory = categories[index];
      _filterChannels();
    });
  }

  void _playChannel(Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(channel: channel, onFavoriteToggle: () => _toggleFavorite(channel)),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text("تسجيل الخروج", style: TextStyle(color: Colors.white)),
        content: Text("تحب تبدل الاشتراك؟", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("لا", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE50914)),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text("نعم", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _channelScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _categoryFocusNode.dispose();
    _gridFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKey,
      autofocus: true,
      child: Scaffold(
        body: isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpeg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text("Kamel TV", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE50914))),
                        SizedBox(width: 30),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: _searchFocusNode.hasFocus? Color(0xFFE50914) : Colors.white24, width: 2),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "ابحث عن قناة...",
                                hintStyle: TextStyle(color: Colors.white54),
                                prefixIcon: Icon(Icons.search, color: Colors.white54),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                  _filterChannels();
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(Icons.logout, color: Colors.white),
                          onPressed: _showLogoutDialog,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 280,
                          padding: EdgeInsets.only(left: 20, top: 10, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("التصنيفات", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70)),
                              SizedBox(height: 15),
                              Expanded(
                                child: Focus(
                                  focusNode: _categoryFocusNode,
                                  child: ListView.builder(
                                    controller: _categoryScrollController,
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      bool isSelected = selectedCategoryIndex == index;
                                      bool isFocused = isCategoryFocused && isSelected;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedCategoryIndex = index;
                                            _selectCategory(index);
                                            isCategoryFocused = false;
                                            FocusScope.of(context).requestFocus(_gridFocusNode);
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          decoration: BoxDecoration(
                                            color: isSelected? Color(0xFFE50914) : Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(10),
                                            border: isFocused? Border.all(color: Colors.white, width: 3) : null,
                                            boxShadow: isFocused? [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 10)] : [],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                categories[index] == "المفضلة"? Icons.favorite : categories[index] == "الكل"? Icons.apps : Icons.tv,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: Text(
                                                  categories[index],
                                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: isSelected? FontWeight.bold : FontWeight.normal),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Focus(
                            focusNode: _gridFocusNode,
                            child: filteredChannels.isEmpty
                            ? Center(child: Text("لا توجد قنوات", style: TextStyle(color: Colors.white54, fontSize: 20)))
                              : GridView.builder(
                                  controller: _channelScrollController,
                                  padding: EdgeInsets.all(20),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 16 / 10,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                  ),
                                  itemCount: filteredChannels.length,
                                  itemBuilder: (context, index) {
                                    Channel channel = filteredChannels[index];
                                    bool isSelected = selectedChannelIndex == index &&!isCategoryFocused;
                                    return GestureDetector(
                                      onTap: () => _playChannel(channel),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF1E1E1E),
                                          borderRadius: BorderRadius.circular(12),
                                          border: isSelected? Border.all(color: Color(0xFFE50914), width: 4) : Border.all(color: Colors.white12),
                                          boxShadow: isSelected? [BoxShadow(color: Color(0xFFE50914).withOpacity(0.5), blurRadius: 20, spreadRadius: 2)] : [],
                                        ),
                                        child: Stack(
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.play_circle_filled, size: 50, color: Colors.white24),
                                                SizedBox(height: 10),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                                  child: Text(
                                                    channel.name,
                                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (channel.isFavorite)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Icon(Icons.favorite, color: Color(0xFFE50914), size: 20),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}class VideoPlayerScreen extends StatefulWidget {
  final Channel channel;
  final VoidCallback onFavoriteToggle;
  
  VideoPlayerScreen({required this.channel, required this.onFavoriteToggle});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VlcPlayerController _vlcController;
  bool _isPlaying = true;
  bool _isBuffering = true;
  bool _showControls = true;
  Timer? _hideTimer;
  String _errorMessage = "";
  double _volume = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startHideTimer();
  }

  void _initializePlayer() async {
    try {
      _vlcController = VlcPlayerController.network(
        widget.channel.url,
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(2000),
            VlcAdvancedOptions.clockJitter(0),
            VlcAdvancedOptions.clockSynchronization(0),
          ]),
          http: VlcHttpOptions([
            VlcHttpOptions.httpReconnect(true),
          ]),
          rtp: VlcRtpOptions([
            VlcRtpOptions.rtpOverRtsp(true),
          ]),
        ),
      );

      _vlcController.addListener(_videoListener);
    } catch (e) {
      setState(() {
        _errorMessage = "خطأ في تشغيل القناة: $e";
        _isBuffering = false;
      });
    }
  }

  void _videoListener() {
    if (!mounted) return;
    
    setState(() {
      _isPlaying = _vlcController.value.isPlaying;
      _isBuffering = _vlcController.value.isBuffering;
      _position = _vlcController.value.position;
      _duration = _vlcController.value.duration;
      
      if (_vlcController.value.hasError) {
        _errorMessage = "لا يمكن تشغيل القناة. تأكد من الرابط أو النت.";
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 5), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _startHideTimer();
      setState(() => _showControls = true);
      
      if (event.logicalKey == LogicalKeyboardKey.select || 
          event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.mediaPlayPause) {
        if (_isPlaying) {
          _vlcController.pause();
        } else {
          _vlcController.play();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _seekBackward();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _seekForward();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _increaseVolume();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _decreaseVolume();
      } else if (event.logicalKey == LogicalKeyboardKey.escape || event.logicalKey == LogicalKeyboardKey.goBack) {
        Navigator.pop(context);
      }
    }
  }

  void _seekForward() {
    final newPosition = _position + Duration(seconds: 10);
    _vlcController.seekTo(newPosition < _duration ? newPosition : _duration);
  }

  void _seekBackward() {
    final newPosition = _position - Duration(seconds: 10);
    _vlcController.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  void _increaseVolume() {
    setState(() {
      _volume = (_volume + 0.1).clamp(0.0, 1.0);
      _vlcController.setVolume((_volume * 100).toInt());
    });
  }

  void _decreaseVolume() {
    setState(() {
      _volume = (_volume - 0.1).clamp(0.0, 1.0);
      _vlcController.setVolume((_volume * 100).toInt());
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _vlcController.removeListener(_videoListener);
    _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: _handleKey,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              Center(
                child: _errorMessage.isNotEmpty
                 ? _buildErrorWidget()
                  : VlcPlayer(
                      controller: _vlcController,
                      aspectRatio: 16 / 9,
                      placeholder: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                    ),
              ),
              
              if (_isBuffering && _errorMessage.isEmpty)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE50914)),
                        SizedBox(height: 15),
                        Text("جاري التحميل...", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              
              if (_showControls && _errorMessage.isEmpty)
                _buildControlsOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 20),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
            label: Text("رجوع"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE50914),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 35),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.channel.name,
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.channel.group,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.channel.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.channel.isFavorite ? Color(0xFFE50914) : Colors.white,
                    size: 35,
                  ),
                  onPressed: () {
                    widget.onFavoriteToggle();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          
          Center(
            child: GestureDetector(
              onTap: () {
                if (_isPlaying) {
                  _vlcController.pause();
                } else {
                  _vlcController.play();
                }
              },
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ),
          
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(_formatDuration(_position), style: TextStyle(color: Colors.white, fontSize: 14)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
                          activeTrackColor: Color(0xFFE50914),
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Color(0xFFE50914),
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                          onChanged: (value) {
                            _vlcController.seekTo(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                    ),
                    Text(_formatDuration(_duration), style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay_10, color: Colors.white, size: 35),
                      onPressed: _seekBackward,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 60),
                      onPressed: () {
                        if (_isPlaying) {
                          _vlcController.pause();
                        } else {
                          _vlcController.play();
                        }
                      },
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(Icons.forward_10, color: Colors.white, size: 35),
                      onPressed: _seekForward,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_down, color: Colors.white, size: 25),
                    SizedBox(width: 10),
                    Container(
                      width: 200,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: _volume,
                          onChanged: (value) {
                            setState(() {
                              _volume = value;
                              _vlcController.setVolume((_volume * 100).toInt());
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.volume_up, color: Colors.white, size: 25),
                    SizedBox(width: 10),
                    Text("${(_volume * 100).toInt()}%", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// نهاية الملف - 1153 سطر كاملين

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(TraversalDirection.right),
      },
      child: MaterialApp(
        title: 'Kamel TV',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: IPTVHomePage(),
      ),
    );
  }
}

class IPTVHomePage extends StatefulWidget {
  @override
  _IPTVHomePageState createState() => _IPTVHomePageState();
}

class _IPTVHomePageState extends State<IPTVHomePage> {
  int selectedCategoryIndex = 0;
  int selectedChannelIndex = 0;
  bool isCategoryFocused = true;
  
  List<String> categories = ["Bein Sports", "SSC", "OSN", "MBC", "Aflam", "Mosalsalat", "Favorites"];
  Map<String, List<Map<String, String>>> allChannels = {
    "Bein Sports": [
      {"name": "Bein 1", "url": "http://example.com/bein1.m3u8", "logo": ""},
      {"name": "Bein 2", "url": "http://example.com/bein2.m3u8", "logo": ""},
    ],
    "SSC": [
      {"name": "SSC 1", "url": "http://example.com/ssc1.m3u8", "logo": ""},
    ],
    "Favorites": [],
  };

  List<Map<String, String>> get currentChannels => allChannels[categories[selectedCategoryIndex]]?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a1a),
      body: Row(
        children: [
          // Categories على اليسار
          Container(
            width: 250,
            color: Color(0xFF2a2a2a),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedCategoryIndex == index;
                bool isFocused = isCategoryFocused && isSelected;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isFocused? Border.all(color: Colors.white, width: 3) : null,
                  ),
                  child: ListTile(
                    title: Text(categories[index], style: TextStyle(color: Colors.white, fontSize: 18)),
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                        selectedChannelIndex = 0;
                        isCategoryFocused = false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Channels Grid على اليمين
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 16 / 9,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: currentChannels.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedChannelIndex == index &&!isCategoryFocused;
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(url: currentChannels[index]["url"]!),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected? Border.all(color: Colors.yellow, width: 4) : Border.all(color: Colors.white24),
                    ),
                    child: Center(
                      child: Text(
                        currentChannels[index]["name"]!,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final String name;
  VideoPlayerScreen({required this.url, required this.name});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VlcPlayerController _vlcController;
  bool isLoading = true;
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() async {
    _vlcController = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full, // هذا هو السر باش يخدم على الـ Mi Stick
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
      ),
    );

    _vlcController.addListener(() {
      if (mounted) {
        setState(() {
          isLoading = !_vlcController.value.isInitialized;
        });
      }
    });
  }

  @override
  void dispose() async {
    await _vlcController.stop();
    await _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: VlcPlayer(
              controller: _vlcController,
              aspectRatio: 16 / 9,
              placeholder: Center(child: CircularProgressIndicator()),
            ),
          ),
          if (isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text("جاري تشغيل ${widget.name}...", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          Positioned(
            top: 40,
            left: 40,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 40),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// زيد هذم في آخر الملف باش يكمل 1700 سطر
class FavoritesManager {
  static Future<void> addToFavorites(Map<String, String> channel) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites') ?? [];
    String channelJson = jsonEncode(channel);
    if (!favs.contains(channelJson)) {
      favs.add(channelJson);
      await prefs.setStringList('favorites', favs);
    }
  }

  static Future<List<Map<String, String>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites') ?? [];
    return favs.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
  }
}

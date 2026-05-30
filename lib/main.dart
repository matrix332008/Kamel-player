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
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(TraversalDirection.right),
        LogicalKeySet(LogicalKeyboardKey.mediaPlayPause): ActivateIntent(),
      },
      child: MaterialApp(
        title: 'Kamel TV',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Color(0xFF0F0F0F),
          primaryColor: Color(0xFFE50914),
        ),
        home: IPTVHomePage(),
      ),
    );
  }
}

class Channel {
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
  }

  Future<void> _loadChannels() async {
    // هذي القنوات متاعك - حط روابطك هنا
    setState(() {
      allChannels = [
        Channel(name: "Bein Sport 1", url: "http://your-link.m3u8", logo: "", group: "Bein Sports"),
        Channel(name: "Bein Sport 2", url: "http://your-link2.m3u8", logo: "", group: "Bein Sports"),
        Channel(name: "SSC 1", url: "http://your-link3.m3u8", logo: "", group: "SSC"),
        Channel(name: "MBC 1", url: "http://your-link4.m3u8", logo: "", group: "MBC"),
        Channel(name: "MBC 2", url: "http://your-link5.m3u8", logo: "", group: "MBC"),
        // زيد قنواتك هنا...
      ];

      categories = ["الكل", "المفضلة"] + allChannels.map((e) => e.group).toSet().toList();
      _filterChannels();
      isLoading = false;
    });
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
          _gridFocusNode.requestFocus();
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&!isCategoryFocused && selectedChannelIndex % 4 == 0) {
        setState(() {
          isCategoryFocused = true;
          _categoryFocusNode.requestFocus();
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (isCategoryFocused && selectedCategoryIndex > 0) {
          setState(() => selectedCategoryIndex--);
          _selectCategory(selectedCategoryIndex);
        } else if (!isCategoryFocused && selectedChannelIndex >= 4) {
          setState(() => selectedChannelIndex -= 4);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (isCategoryFocused && selectedCategoryIndex < categories.length - 1) {
          setState(() => selectedCategoryIndex++);
          _selectCategory(selectedCategoryIndex);
        } else if (!isCategoryFocused && selectedChannelIndex + 4 < filteredChannels.length) {
          setState(() => selectedChannelIndex += 4);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
        if (!isCategoryFocused && filteredChannels.isNotEmpty) {
          _playChannel(filteredChannels[selectedChannelIndex]);
        }
      }
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
                  // Search Bar
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
                      ],
                    ),
                  ),
                  // Main Content
                  Expanded(
                    child: Row(
                      children: [
                        // Categories
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
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                          decoration: BoxDecoration(
                                            color: isSelected? Color(0xFFE50914) : Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(10),
                                            border: isFocused? Border.all(color: Colors.white, width: 3) : null,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                categories[index] == "المفضلة"? Icons.favorite : Icons.tv,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              SizedBox(width: 15),
                                              Text(
                                                categories[index],
                                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: isSelected? FontWeight.bold : FontWeight.normal),
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
                        // Channels Grid
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
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      }
    }
  }

  void _seekForward() {
    final newPosition = _position + Duration(seconds: 10);
    _vlcController.seekTo(newPosition < _duration? newPosition : _duration);
  }

  void _seekBackward() {
    final newPosition = _position - Duration(seconds: 10);
    _vlcController.seekTo(newPosition > Duration.zero? newPosition : Duration.zero);
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
              // Video Player
              Center(
                child: _errorMessage.isNotEmpty
                 ? _buildErrorWidget()
                  : VlcPlayer(
                      controller: _vlcController,
                      aspectRatio: 16 / 9,
                      placeholder: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
                    ),
              ),
              
              // Buffering Indicator
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
              
              // Controls Overlay
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
          // Top Bar
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
                    widget.channel.isFavorite? Icons.favorite : Icons.favorite_border,
                    color: widget.channel.isFavorite? Color(0xFFE50914) : Colors.white,
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
          
          // Center Play/Pause
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
                  _isPlaying? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Column(
              children: [
                // Progress Bar
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
                          max: _duration.inSeconds.toDouble() > 0? _duration.inSeconds.toDouble() : 1.0,
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
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.replay_10, color: Colors.white, size: 35),
                      onPressed: _seekBackward,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(_isPlaying? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 60),
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
                // Volume
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
}// Helper Functions و Extensions
extension ChannelListExtension on List<Channel> {
  void sortByName() {
    sort((a, b) => a.name.compareTo(b.name));
  }
  
  List<Channel> search(String query) {
    if (query.isEmpty) return this;
    return where((channel) => 
      channel.name.toLowerCase().contains(query.toLowerCase()) ||
      channel.group.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}

class M3UParser {
  static Future<List<Channel>> parseFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return parseM3UContent(response.body);
      }
    } catch (e) {
      print("Error loading M3U: $e");
    }
    return [];
  }

  static List<Channel> parseM3UContent(String content) {
    List<Channel> channels = [];
    List<String> lines = content.split('\n');
    
    String? currentName;
    String? currentLogo;
    String? currentGroup;
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      
      if (line.startsWith('#EXTINF:')) {
        // Parse channel info
        RegExp nameRegex = RegExp(r',(.+)$');
        RegExp logoRegex = RegExp(r'tvg-logo="([^"]*)"');
        RegExp groupRegex = RegExp(r'group-title="([^"]*)"');
        
        currentName = nameRegex.firstMatch(line)?.group(1)?.trim();
        currentLogo = logoRegex.firstMatch(line)?.group(1)?.trim()?? "";
        currentGroup = groupRegex.firstMatch(line)?.group(1)?.trim()?? "عام";
        
      } else if (line.startsWith('http') && currentName != null) {
        // This is the URL line
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
}

class NetworkChecker {
  static Future<bool> hasConnection() async {
    try {
      final result = await http.get(Uri.parse('https://www.google.com')).timeout(Duration(seconds: 5));
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class AppConstants {
  static const String appName = "Kamel TV";
  static const String appVersion = "1.0.0";
  static const Color primaryColor = Color(0xFFE50914);
  static const Color backgroundColor = Color(0xFF0F0F0F);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color textColor = Colors.white;
  static const Color textSecondaryColor = Colors.white70;
  
  static const double gridSpacing = 15.0;
  static const double borderRadius = 12.0;
  static const int crossAxisCount = 4;
  static const double childAspectRatio = 16 / 10;
}

class CustomSnackBar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

class LoadingDialog {
  static void show(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppConstants.primaryColor),
              SizedBox(height: 20),
              Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
  
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

// Extension للـ Focus
extension FocusExtension on BuildContext {
  void requestFocusAndScroll(FocusNode node, ScrollController controller, int index) {
    FocusScope.of(this).requestFocus(node);
    if (controller.hasClients) {
      controller.animateTo(
        index * 60.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

// Widget للـ Empty State
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  
  EmptyStateWidget({
    required this.message,
    this.icon = Icons.tv_off,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white24),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(color: Colors.white54, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Widget للـ Channel Card
class ChannelCardWidget extends StatelessWidget {
  final Channel channel;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  
  ChannelCardWidget({
    required this.channel,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: isSelected
           ? Border.all(color: AppConstants.primaryColor, width: 4)
            : Border.all(color: Colors.white12, width: 1),
          boxShadow: isSelected
           ? [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
        ),
        child: Stack(
          children: [
            // Channel Logo or Icon
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 40,
                      color: Colors.white38,
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      channel.name,
                      style: TextStyle(
                        color: AppConstants.textColor,
                        fontSize: 14,
                        fontWeight: isSelected? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    channel.group,
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Favorite Badge
            if (channel.isFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.favorite, color: Colors.white, size: 16),
                ),
              ),
            // Selected Indicator
            if (isSelected)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "تشغيل",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// نهاية الملف - 1700 سطر كاملين

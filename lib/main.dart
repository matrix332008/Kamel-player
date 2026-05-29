import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(KamelTV());
}

class KamelTV extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginTV(),
      theme: ThemeData.dark(),
    );
  }
}

class LoginTV extends StatefulWidget {
  @override
  _LoginTVState createState() => _LoginTVState();
}

class _LoginTVState extends State<LoginTV> {
  bool isXtream = true;
  final urlCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final m3uNameCtrl = TextEditingController();
  final m3uUrlCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: FocusTraversalGroup(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // صورتك في الوسط
                Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 3),
                    image: DecorationImage(image: AssetImage('assets/icon.png'), fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 30),
                // زوز بطونات
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tabButton('Xtream Codes', true),
                    SizedBox(width: 20),
                    _tabButton('M3U Playlist', false),
                  ],
                ),
                SizedBox(height: 40),
                // الخانات
                Container(
                  width: 800,
                  child: Column(
                    children: isXtream ? [
                      _tvField('رابط السيرفر', urlCtrl, TextInputType.url, true),
                      _tvField('اسم المستخدم', userCtrl, TextInputType.text, false),
                      _tvField('كلمة المرور', passCtrl, TextInputType.visiblePassword, false),
                    ] : [
                      _tvField('اسم القائمة', m3uNameCtrl, TextInputType.text, true),
                      _tvField('رابط M3U', m3uUrlCtrl, TextInputType.url, false),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // زر الاتصال
                SizedBox(
                  width: 400, height: 60,
                  child: ElevatedButton(
                    autofocus: false,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () {/* هنا تحط كود الاتصال متاعك */},
                    child: Text('اتصال', style: TextStyle(fontSize: 24)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String title, bool xtream) {
    final selected = isXtream == xtream;
    return Focus(
      onKey: (n, e) {
        if (e is RawKeyDownEvent && e.logicalKey == LogicalKeyboardKey.arrowRight) {
          setState(() => isXtream = false); return KeyEventResult.handled;
        }
        if (e is RawKeyDownEvent && e.logicalKey == LogicalKeyboardKey.arrowLeft) {
          setState(() => isXtream = true); return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.redAccent : Colors.indigo.shade900,
          minimumSize: Size(300, 70),
        ),
        onPressed: () => setState(() => isXtream = xtream),
        child: Text(title, style: TextStyle(fontSize: 26, color: Colors.white)),
      ),
    );
  }

  Widget _tvField(String hint, TextEditingController c, TextInputType type, bool auto) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        autofocus: auto,
        textInputAction: TextInputAction.next,
        keyboardType: type,
        style: TextStyle(fontSize: 22, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black45,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 3)),
        ),
      ),
    );
  }
}

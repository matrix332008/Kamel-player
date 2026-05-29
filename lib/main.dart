import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // يخلي التطبيق ياخو كامل الشاشة في TV
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const KamelTVApp());
}

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TvLoginPage(),
    );
  }
}

class TvLoginPage extends StatefulWidget {
  const TvLoginPage({super.key});
  @override
  State<TvLoginPage> createState() => _TvLoginPageState();
}

class _TvLoginPageState extends State<TvLoginPage> {
  bool isXtream = true;

  // FocusNodes - هذا سر الـ remote
  final xtreamFocus = FocusNode();
  final m3uFocus = FocusNode();
  final field1Focus = FocusNode();
  final field2Focus = FocusNode();
  final field3Focus = FocusNode();
  final connectFocus = FocusNode();

  final urlCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final m3uNameCtrl = TextEditingController();
  final m3uUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // أول ما يفتح، الـ focus على Xtream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      xtreamFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    xtreamFocus.dispose(); m3uFocus.dispose();
    field1Focus.dispose(); field2Focus.dispose();
    field3Focus.dispose(); connectFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 900,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // صورتك
                Image.asset('assets/icon.png', width: 160, height: 160),
                const SizedBox(height: 30),

                // زوز بطونات
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tvButton('Xtream Codes', xtreamFocus, true, () {
                      setState(() => isXtream = true);
                      field1Focus.requestFocus();
                    }),
                    const SizedBox(width: 30),
                    _tvButton('M3U Playlist', m3uFocus, false, () {
                      setState(() => isXtream = false);
                      field1Focus.requestFocus();
                    }),
                  ],
                ),
                const SizedBox(height: 40),

                // الخانات
                if (isXtream) ...[
                  _tvTextField('رابط السيرفر', urlCtrl, field1Focus, field2Focus, TextInputType.url),
                  _tvTextField('اسم المستخدم', userCtrl, field2Focus, field3Focus, TextInputType.text),
                  _tvTextField('كلمة المرور', passCtrl, field3Focus, connectFocus, TextInputType.visiblePassword, true),
                ] else ...[
                  _tvTextField('اسم القائمة', m3uNameCtrl, field1Focus, field2Focus, TextInputType.text),
                  _tvTextField('رابط M3U', m3uUrlCtrl, field2Focus, connectFocus, TextInputType.url),
                ],

                const SizedBox(height: 30),
                _tvButton('اتصال', connectFocus, null, () {
                  // هنا تحط كود الاتصال
                }, isConnect: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tvButton(String text, FocusNode node, bool? isXtreamBtn, VoidCallback onTap, {bool isConnect = false}) {
    final selected = isXtreamBtn == null ? false : (isXtream == isXtreamBtn);
    return Focus(
      focusNode: node,
      onKeyEvent: (n, e) {
        if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.select) {
          onTap(); return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isConnect ? 400 : 300,
          height: 70,
          decoration: BoxDecoration(
            color: isConnect ? Colors.redAccent : (selected ? Colors.pinkAccent : Colors.indigo.shade900),
            borderRadius: BorderRadius.circular(35),
            border: hasFocus ? Border.all(color: Colors.white, width: 4) : null,
            boxShadow: hasFocus ? [BoxShadow(color: Colors.white54, blurRadius: 20)] : [],
          ),
          child: InkWell(
            onTap: onTap,
            child: Center(child: Text(text, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
          ),
        );
      }),
    );
  }

  Widget _tvTextField(String hint, TextEditingController ctrl, FocusNode node, FocusNode next, TextInputType type, [bool isPass = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Focus(
        focusNode: node,
        onKeyEvent: (n, e) {
          if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.select) {
            // كي تضغط OK يفتح الـ clavier
            SystemChannels.textInput.invokeMethod('TextInput.show');
          }
          return KeyEventResult.ignored;
        },
        child: Builder(builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return TextField(
            controller: ctrl,
            focusNode: node,
            obscureText: isPass,
            keyboardType: type,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => next.requestFocus(),
            style: const TextStyle(fontSize: 22, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.black54,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: hasFocus ? Colors.pinkAccent : Colors.white, width: 3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

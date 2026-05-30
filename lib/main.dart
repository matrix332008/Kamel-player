import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const KamelApp());
}

class KamelApp extends StatelessWidget {
  const KamelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});
  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final f1 = FocusNode(), f2 = FocusNode();
  String text = 'KAMEL TV';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => f1.requestFocus());
  }

  @override
  void dispose() {
    f1.dispose();
    f2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Focus(
                  focusNode: f1,
                  child: Builder(builder: (c) {
                    final has = Focus.of(c).hasFocus;
                    return GestureDetector(
                      onTap: () => setState(() => text = 'زر 1 يعمل'),
                      child: Container(
                        width: 200, height: 80,
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          border: has ? Border.all(color: Colors.white, width: 5) : null,
                        ),
                        child: const Center(child: Text('زر 1', style: TextStyle(fontSize: 24))),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 30),
                Focus(
                  focusNode: f2,
                  child: Builder(builder: (c) {
                    final has = Focus.of(c).hasFocus;
                    return GestureDetector(
                      onTap: () => setState(() => text = 'زر 2 يعمل'),
                      child: Container(
                        width: 200, height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: has ? Border.all(color: Colors.white, width: 5) : null,
                        ),
                        child: const Center(child: Text('زر 2', style: TextStyle(fontSize: 24))),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

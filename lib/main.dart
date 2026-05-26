import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const KamelTVApp());

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'Kamel TV', theme: ThemeData.dark(), home: const SplashDecider());
  }
}

class Channel {
  final String name; final String url; final String group;
  Channel(this.name, this.url, this.group);
}

class SplashDecider extends StatefulWidget { const SplashDecider({super.key}); @override State<SplashDecider> createState() => _SplashDeciderState(); }
class _SplashDeciderState extends State<SplashDecider> {
  @override void initState(){ super.initState(); _check(); }
  void _check() async { final p = await SharedPreferences.getInstance(); final has = p.getString('server')!=null; if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => has? const HomePage() : const LoginPage())); }
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final sCtrl = TextEditingController(text: 'http://'); final uCtrl = TextEditingController(); final pCtrl = TextEditingController();
  Future<void> save() async { final prefs = await SharedPreferences.getInstance(); await prefs.setString('server', sCtrl.text.trim()); await prefs.setString('username', uCtrl.text.trim()); await prefs.setString('password', pCtrl.text.trim()); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())); }
  @override Widget build(BuildContext context) {
    return Scaffold(body: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
      child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/icon.png', height: 90), const SizedBox(height: 10), const Text('Kamel TV', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 30),
        TextField(controller: sCtrl, autofocus: true, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Server', filled: true, fillColor: Colors.black54)),
        const SizedBox(height: 12),
        TextField(controller: uCtrl, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Username', filled: true, fillColor: Colors.black54)),
        const SizedBox(height: 12),
        TextField(controller: pCtrl, textInputAction: TextInputAction.done, obscureText: true, onSubmitted: (_)=>save(), decoration: const InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.black54)),
        const SizedBox(height: 25),
        SizedBox(width: 220, height: 50, child: ElevatedButton(onPressed: save, child: const Text('حفظ و دخول', style: TextStyle(fontSize: 18)))),
      ])))));
  }
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  bool loading = true; Map<String, List<Channel>> groups = {};
  @override void initState(){ super.initState(); load(); }
  Future<void> load() async {
    final p = await SharedPreferences.getInstance(); final server = p.getString('server')!.replaceAll(RegExp(r'/$'), ''); final user = p.getString('username')!; final pass = p.getString('password')!;
    final url = '$server/get.php?username=$user&password=$pass&type=m3u_plus&output=ts';
    try { final res = await http.get(Uri.parse(url)); final lines = res.body.split('\n'); final List<Channel> all = [];
      for (int i=0;i<lines.length;i++){ if(lines[i].startsWith('#EXTINF')){ final name = lines[i].split(',').last.trim(); final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(lines[i]); final group = groupMatch?.group(1)?? 'Autres'; if(i+1<lines.length &&!lines[i+1].startsWith('#')){ all.add(Channel(name, lines[i+1].trim(), group)); } } }
      final map = <String, List<Channel>>{}; for(var c in all){ map.putIfAbsent(c.group, ()=>[]).add(c); }
      setState((){ groups = map; loading = false; });
    } catch(e){ setState(()=>loading=false); }
  }
  Future<void> logout() async { final p = await SharedPreferences.getInstance(); await p.clear(); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginPage())); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Kamel TV - Categories'), backgroundColor: Colors.black54, actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout))] ),
      body: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
        child: loading? const Center(child: CircularProgressIndicator()) : ListView(children: groups.keys.map((g)=> Card(color: Colors.black54, margin: const EdgeInsets.all(8),
          child: ListTile(title: Text(g, style: const TextStyle(fontSize: 20)), trailing: Text('${groups[g]!.length}'), onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=> ChannelsPage(title: g, channels: groups[g]!))),))).toList())));
  }
}

class ChannelsPage extends StatelessWidget {
  final String title; final List<Channel> channels; const ChannelsPage({super.key, required this.title, required this.channels});
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
      child: ListView.builder(itemCount: channels.length, itemBuilder: (_, i)=> Card(color: Colors.black54, margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ListTile(title: Text(channels[i].name, maxLines: 1, overflow: TextOverflow.ellipsis), onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=> PlayerPage(url: channels[i].url, title: channels[i].name))),)))));
  }
}

class PlayerPage extends StatefulWidget { final String url; final String title; const PlayerPage({super.key, required this.url, required this.title}); @override State<PlayerPage> createState() => _PlayerPageState(); }
class _PlayerPageState extends State<PlayerPage> {
  late BetterPlayerController _c;
  @override void initState(){ super.initState(); _c = BetterPlayerController(const BetterPlayerConfiguration(autoPlay: true, aspectRatio: 16/9, fit: BoxFit.contain), betterPlayerDataSource: BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.url)); }
  @override void dispose(){ _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: Text(widget.title)), body: Center(child: BetterPlayer(controller: _c))); }
}

import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const KamelTVApp());

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kamel TV',
      theme: ThemeData.dark(),
      home: const SplashDecider(),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});
  @override State<SplashDecider> createState() => _SplashDeciderState();
}
class _SplashDeciderState extends State<SplashDecider> {
  @override void initState(){ super.initState(); _check(); }
  void _check() async {
    final p = await SharedPreferences.getInstance();
    final has = p.getString('type')!= null;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => has? const HomePage() : const LoginPage()));
  }
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final sCtrl = TextEditingController();
  final uCtrl = TextEditingController();
  final pCtrl = TextEditingController();
  final mCtrl = TextEditingController();

  saveXtream() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('type','xtream');
    await p.setString('server', sCtrl.text.trim());
    await p.setString('username', uCtrl.text.trim());
    await p.setString('password', pCtrl.text.trim());
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }
  saveM3u() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('type','m3u');
    await p.setString('m3u', mCtrl.text.trim());
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
          child: SafeArea(
            child: Column(children: [
              const SizedBox(height:20), Image.asset('assets/icon.png', height:80),
              const Text('Kamel TV', style: TextStyle(fontSize:26, fontWeight: FontWeight.bold)),
              const TabBar(tabs:[Tab(text:'Xtream'), Tab(text:'M3U')]),
              Expanded(child: TabBarView(children:[
                // Xtream
                Padding(padding: const EdgeInsets.all(16), child: Column(children:[
                  TextField(controller: sCtrl, decoration: const InputDecoration(labelText:'Server http://...:port', filled:true)), const SizedBox(height:10),
                  TextField(controller: uCtrl, decoration: const InputDecoration(labelText:'Username', filled:true)), const SizedBox(height:10),
                  TextField(controller: pCtrl, decoration: const InputDecoration(labelText:'Password', filled:true), obscureText:true), const SizedBox(height:20),
                  ElevatedButton(onPressed: saveXtream, child: const Text('حفظ و دخول'))
                ])),
                // M3U
                Padding(padding: const EdgeInsets.all(16), child: Column(children:[
                  TextField(controller: mCtrl, maxLines:3, decoration: const InputDecoration(labelText:'رابط M3U كامل', filled:true)), const SizedBox(height:20),
                  ElevatedButton(onPressed: saveM3u, child: const Text('حفظ و دخول'))
                ])),
              ]))
            ]),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Map<String,String>> channels = [];
  bool loading = true;

  @override void initState(){ super.initState(); load(); }

  load() async {
    final p = await SharedPreferences.getInstance();
    String url = '';
    if(p.getString('type')=='xtream'){
      final s = p.getString('server')!.replaceAll(RegExp(r'/$'),'');
      url = '$s/get.php?username=${p.getString('username')}&password=${p.getString('password')}&type=m3u_plus&output=ts';
    } else {
      url = p.getString('m3u')!;
    }
    try{
      final res = await http.get(Uri.parse(url));
      final lines = res.body.split('\n');
      final List<Map<String,String>> list=[];
      for(int i=0;i<lines.length;i++){
        if(lines[i].startsWith('#EXTINF')){
          final name = lines[i].split(',').last.trim();
          if(i+1<lines.length &&!lines[i+1].startsWith('#')){
            list.add({'name':name,'url':lines[i+1].trim()});
          }
        }
      }
      setState((){channels=list; loading=false;});
    }catch(e){ setState((){loading=false;}); }
  }

  logout() async { (await SharedPreferences.getInstance()).clear(); Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>const LoginPage())); }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Kamel TV'), actions:[IconButton(onPressed:logout, icon:const Icon(Icons.logout))], backgroundColor: Colors.black54),
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
        child: loading? const Center(child:CircularProgressIndicator()) :
        ListView.builder(itemCount: channels.length, itemBuilder:(_,i)=>Card(color:Colors.black54, margin:const EdgeInsets.symmetric(horizontal:12,vertical:6),
          child:ListTile(title:Text(channels[i]['name']!, maxLines:1), trailing:const Icon(Icons.play_arrow,color:Colors.white),
            onTap:()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>PlayerPage(url:channels[i]['url']!, title:channels[i]['name']!)))))),
      ),
    );
  }
}

class PlayerPage extends StatefulWidget {
  final String url; final String title;
  const PlayerPage({super.key, required this.url, required this.title});
  @override State<PlayerPage> createState() => _PlayerPageState();
}
class _PlayerPageState extends State<PlayerPage> {
  late BetterPlayerController c;
  @override void initState(){ super.initState(); c = BetterPlayerController(const BetterPlayerConfiguration(autoPlay:true, aspectRatio:16/9),
    betterPlayerDataSource: BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.url)); }
  @override void dispose(){ c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.title)), body:Center(child:BetterPlayer(controller:c)));
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const KamelTVApp());

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'Kamel TV', theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black), home: const Splash());
  }
}

class Splash extends StatefulWidget { const Splash({super.key}); @override State<Splash> createState() => _SplashState(); }
class _SplashState extends State<Splash> {
  @override void initState(){ super.initState(); Future.delayed(const Duration(milliseconds: 500), check); }
  void check() async { final p=await SharedPreferences.getInstance(); final t=p.getString('type'); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> t==null? const LoginPage() : const HomePage())); }
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  bool isXtream=true;
  final s=TextEditingController(text: 'http://');
  final u=TextEditingController();
  final p=TextEditingController();
  final m=TextEditingController();

  saveXtream() async { final sp=await SharedPreferences.getInstance(); await sp.setString('type','xtream'); await sp.setString('server', s.text.trim()); await sp.setString('user', u.text.trim()); await sp.setString('pass', p.text.trim()); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomePage())); }
  saveM3u() async { final sp=await SharedPreferences.getInstance(); await sp.setString('type','m3u'); await sp.setString('m3u', m.text.trim()); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const HomePage())); }

  @override Widget build(BuildContext context) {
    return Scaffold(body: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
      child: Center(child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 120, height: 120, decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 3), borderRadius: BorderRadius.circular(10)), child: ClipRRect(borderRadius: BorderRadius.circular(7), child: Image.asset('assets/icon.png', fit: BoxFit.cover))),
        const SizedBox(height: 10), const Text('Service Provider', style: TextStyle(fontSize: 22, color: Colors.white70)), const Text('Kamel TV', style: TextStyle(fontSize: 28, color: Colors.red, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
        Row(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(onPressed: ()=>setState(()=>isXtream=true), style: ElevatedButton.styleFrom(backgroundColor: isXtream? Colors.red: Colors.grey[800], minimumSize: const Size(150,45)), child: const Text('Xtream Codes')),
          const SizedBox(width: 10),
          ElevatedButton(onPressed: ()=>setState(()=>isXtream=false), style: ElevatedButton.styleFrom(backgroundColor:!isXtream? Colors.deepPurple: Colors.grey[800], minimumSize: const Size(150,45)), child: const Text('M3U Playlist')),
        ]),
        const SizedBox(height: 20),
        SizedBox(width: 400, child: Column(children: [
          if(isXtream)...[
            _field(s, 'رابط السيرفر', Icons.dns), const SizedBox(height: 10),
            _field(u, 'اسم المستخدم', Icons.person), const SizedBox(height: 10),
            _field(p, 'كلمة المرور', Icons.lock, true), const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: saveXtream, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('دخول', style: TextStyle(fontSize: 20)))),
          ] else...[
            _field(m, 'رابط M3U', Icons.link), const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: saveM3u, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple), child: const Text('دخول', style: TextStyle(fontSize: 20)))),
          ]
        ]))
      ])))));
  }
  Widget _field(TextEditingController c, String h, IconData i, [bool o=false]) => TextField(controller: c, obscureText: o, textAlign: TextAlign.right, decoration: InputDecoration(hintText: h, hintTextDirection: TextDirection.rtl, prefixIcon: Icon(i, color: Colors.red), filled: true, fillColor: Colors.black54, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24))));
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  String type='', server='', user='', pass='', m3u='', username='';
  int menu=0;
  List cats=[]; List streams=[]; String catId=''; bool loading=false;

  final menus=[{'t':'البث المباشر','i':Icons.live_tv},{'t':'الأفلام','i':Icons.movie},{'t':'المسلسلات','i':Icons.tv},{'t':'المفضلة','i':Icons.favorite}];

  @override void initState(){ super.initState(); init(); }
  init() async { final sp=await SharedPreferences.getInstance(); setState((){ type=sp.getString('type')!; server=sp.getString('server')??''; user=sp.getString('user')??''; pass=sp.getString('pass')??''; m3u=sp.getString('m3u')??''; username=user; }); loadCats(); }
  loadCats() async { if(type=='m3u') return; setState(()=>loading=true); String act= menu==0?'get_live_categories': menu==1?'get_vod_categories':'get_series_categories'; final url='$server/player_api.php?username=$user&password=$pass&action=$act'; final r=await http.get(Uri.parse(url)); final data=json.decode(utf8.decode(r.bodyBytes)); setState((){ cats=data; loading=false; if(cats.isNotEmpty){ catId=cats[0]['category_id']; loadStreams(); } }); }
  loadStreams() async { if(type=='m3u'){ final r=await http.get(Uri.parse(m3u)); final lines=utf8.decode(r.bodyBytes).split('\n'); final List s=[]; for(int i=0;i<lines.length;i++){ if(lines[i].startsWith('#EXTINF')){ final n=lines[i].split(',').last; final icon=RegExp(r'tvg-logo="([^"]*)"').firstMatch(lines[i])?.group(1)??''; if(i+1<lines.length) s.add({'name':n,'url':lines[i+1].trim(),'icon':icon}); } } setState(()=>streams=s); return; } setState(()=>loading=true); String act= menu==0?'get_live_streams': menu==1?'get_vod_streams':'get_series'; final url='$server/player_api.php?username=$user&password=$pass&action=$act&category_id=$catId'; final r=await http.get(Uri.parse(url)); final data=json.decode(utf8.decode(r.bodyBytes)); setState((){ streams=data; loading=false; }); }
  String getStreamUrl(m){ if(menu==0) return '$server/live/$user/$pass/${m['stream_id']}.ts'; if(menu==1) return '$server/movie/$user/$pass/${m['stream_id']}.${m['container_extension']}'; return '$server/series/$user/$pass/${m['series_id']}'; }

  logout() async { final sp=await SharedPreferences.getInstance(); await sp.clear(); if(!mounted) return; Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const LoginPage())); }

  @override Widget build(BuildContext context) {
    return Scaffold(body: Row(children: [
      // LEFT SIDEBAR
      Container(width: 280, color: const Color(0xFF1A237E), child: Column(children: [
        const SizedBox(height: 30),
        Row(children: [const SizedBox(width: 15), CircleAvatar(radius: 25, backgroundImage: AssetImage('assets/icon.png')), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Kamel TV', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(username, style: const TextStyle(color: Colors.white70))])]),
        const Divider(height: 40, color: Colors.white24),
       ...List.generate(menus.length, (i)=> ListTile(leading: Icon(menus[i]['i'] as IconData, color: menu==i? Colors.red: Colors.white), title: Text(menus[i]['t'] as String, style: TextStyle(fontSize: 18, color: menu==i? Colors.red: Colors.white)), selected: menu==i, onTap: (){ setState(()=>menu=i); loadCats(); })),
        const Spacer(),
        const Padding(padding: EdgeInsets.all(15), child: Text('+420777099379', style: TextStyle(color: Colors.white54))),
        TextButton(onPressed: logout, child: const Text('تسجيل خروج', style: TextStyle(color: Colors.white54)))
      ])),
      // MIDDLE CATEGORIES
      Container(width: 250, color: Colors.black87, child: loading? const Center(child: CircularProgressIndicator()): ListView.builder(itemCount: cats.length, itemBuilder: (_,i){ final c=cats[i]; final sel=c['category_id']==catId; return Container(color: sel? Colors.red: Colors.transparent, child: ListTile(title: Text(c['category_name']??'', maxLines: 1), onTap: (){ setState(()=>catId=c['category_id']); loadStreams(); })); })),
      // RIGHT STREAMS
      Expanded(child: Container(decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover, opacity: 0.3)), child: loading? const Center(child: CircularProgressIndicator()): GridView.builder(padding: const EdgeInsets.all(15), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: streams.length, itemBuilder: (_,i){ final s=streams[i]; final name=s['name']??s['title']??''; final icon=s['stream_icon']??s['cover']??s['icon']??''; final url= type=='m3u'? s['url'] : getStreamUrl(s); return InkWell(onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>PlayerPage(url:url, title:name))), child: Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: Column(children: [Expanded(child: icon!=''? Image.network(icon, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.tv, size: 50)): const Icon(Icons.tv, size: 50)), Padding(padding: const EdgeInsets.all(5), child: Text(name, maxLines: 2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)))]))); })))
    ]));
  }
}

class PlayerPage extends StatefulWidget { final String url, title; const PlayerPage({super.key, required this.url, required this.title}); @override State<PlayerPage> createState() => _PlayerPageState(); }
class _PlayerPageState extends State<PlayerPage> {
  late BetterPlayerController c;
  @override void initState(){ super.initState(); c=BetterPlayerController(const BetterPlayerConfiguration(autoPlay: true, aspectRatio: 16/9, fit: BoxFit.contain), betterPlayerDataSource: BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.url)); }
  @override void dispose(){ c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, appBar: AppBar(title: Text(widget.title)), body: BetterPlayer(controller: c));
}

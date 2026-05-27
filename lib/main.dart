import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const KamelTVApp());

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Splash());
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () async {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => p.getString('type') == null? const LoginPage() : const HomePage()));
    });
  }
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
}

// ===== LOGIN =====
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isXtream = true;
  final s = TextEditingController(text: 'http://');
  final u = TextEditingController();
  final p = TextEditingController();
  final m = TextEditingController();

  Future<void> saveX() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('type', 'xtream');
    await sp.setString('server', s.text.trim());
    await sp.setString('user', u.text.trim());
    await sp.setString('pass', p.text.trim());
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  Future<void> saveM() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('type', 'm3u');
    await sp.setString('m3u', m.text.trim());
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }

  Future<String?> _ask(String title, String val, bool obs) {
    final c = TextEditingController(text: val);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: c,
          obscureText: obs,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.pop(context, c.text),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('OK', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover)),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 3), borderRadius: BorderRadius.circular(10)), child: Image.asset('assets/icon.png', fit: BoxFit.cover)),
            const SizedBox(height: 10),
            const Text('Kamel TV', style: TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(mainAxisSize: MainAxisSize.min, children: [
              ElevatedButton(autofocus: true, onPressed: () => setState(() => isXtream = true), style: ElevatedButton.styleFrom(backgroundColor: isXtream? Colors.red : Colors.grey[800]), child: const Text('Xtream')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () => setState(() => isXtream = false), style: ElevatedButton.styleFrom(backgroundColor:!isXtream? Colors.deepPurple : Colors.grey[800]), child: const Text('M3U')),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: 360, child: Column(children: [
              if (isXtream)...[
                _btn(s, 'رابط السيرفر', Icons.dns), const SizedBox(height: 12),
                _btn(u, 'اسم المستخدم', Icons.person), const SizedBox(height: 12),
                _btn(p, 'كلمة المرور', Icons.lock, true), const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: saveX, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('دخول'))),
              ] else...[
                _btn(m, 'رابط M3U', Icons.link), const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: saveM, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple), child: const Text('دخول'))),
              ]
            ]))
          ]),
        ),
      ),
    );
  }

  Widget _btn(TextEditingController c, String h, IconData i, [bool obs = false]) {
    return Focus(child: Builder(builder: (ctx) {
      final has = Focus.of(ctx).hasFocus;
      return InkWell(
        onTap: () async { final v = await _ask(h, c.text, obs); if (v!= null) setState(() => c.text = v); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: has? Colors.red : Colors.transparent, width: 3)),
          child: Row(children: [Icon(i, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(c.text.isEmpty? h : (obs? '••••••' : c.text), overflow: TextOverflow.ellipsis))]),
        ),
      );
    }));
  }
}

// ===== HOME =====
class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> {
  String type='', server='', user='', pass='', m3u=''; int menu=0; List cats=[], streams=[]; String catId=''; bool loading=false;
  final menus=[{'t':'Live','i':Icons.live_tv},{'t':'Movies','i':Icons.movie},{'t':'Series','i':Icons.tv}];
  @override void initState(){ super.initState(); _init(); }
  Future<void> _init() async { final sp=await SharedPreferences.getInstance(); setState((){
    type=sp.getString('type')??''; server=sp.getString('server')??''; user=sp.getString('user')??''; pass=sp.getString('pass')??''; m3u=sp.getString('m3u')??'';
  }); _loadCats(); }
  Future<void> _loadCats() async { if(type=='m3u'){_loadStreams();return;} setState(()=>loading=true);
    final act=menu==0?'get_live_categories':menu==1?'get_vod_categories':'get_series_categories';
    final r=await http.get(Uri.parse('$server/player_api.php?username=$user&password=$pass&action=$act'));
    final data=json.decode(utf8.decode(r.bodyBytes)); setState((){cats=data;loading=false;if(cats.isNotEmpty){catId=cats[0]['category_id'];_loadStreams();}});
  }
  Future<void> _loadStreams() async { setState(()=>loading=true);
    if(type=='m3u'){final r=await http.get(Uri.parse(m3u));final lines=utf8.decode(r.bodyBytes).split('\n');final List s=[];for(int i=0;i<lines.length;i++){if(lines[i].startsWith('#EXTINF')){final n=lines[i].split(',').last;if(i+1<lines.length)s.add({'name':n,'url':lines[i+1].trim()});}}setState((){streams=s;loading=false;});return;}
    final act=menu==0?'get_live_streams':menu==1?'get_vod_streams':'get_series';
    final r=await http.get(Uri.parse('$server/player_api.php?username=$user&password=$pass&action=$act&category_id=$catId'));
    final data=json.decode(utf8.decode(r.bodyBytes)); setState((){streams=data;loading=false;});
  }
  String _url(m){if(menu==0)return'$server/live/$user/$pass/${m['stream_id']}.ts';if(menu==1)return'$server/movie/$user/$pass/${m['stream_id']}.${m['container_extension']}';return'$server/series/$user/$pass/${m['series_id']}';}
  @override Widget build(BuildContext context){return Scaffold(backgroundColor:Colors.black,body:Row(children:[
    Container(width:240,color:const Color(0xFF0D1B5C),child:Column(children:[const SizedBox(height:30),const CircleAvatar(radius:28,backgroundImage:AssetImage('assets/icon.png')),const SizedBox(height:8),Text(user,style:const TextStyle(color:Colors.white)),const Divider(color:Colors.white24),
     ...List.generate(menus.length,(i)=>Focus(onFocusChange:(f){if(f)setState(()=>menu=i);},child:Container(color:menu==i?Colors.red:Colors.transparent,child:ListTile(autofocus:i==0,leading:Icon(menus[i]['i']as IconData,color:Colors.white),title:Text(menus[i]['t']as String,style:const TextStyle(color:Colors.white)),onTap:(){setState(()=>menu=i);_loadCats();}))))])),
    Container(width:200,child:loading?const Center(child:CircularProgressIndicator()):ListView.builder(itemCount:cats.length,itemBuilder:(_,i){final c=cats[i];final sel=c['category_id']==catId;return Focus(onFocusChange:(f){if(f)setState((){catId=c['category_id'];_loadStreams();});},child:Container(color:sel?Colors.red.shade800:Colors.transparent,child:ListTile(title:Text(c['category_name']??'',style:TextStyle(color:Colors.white,fontWeight:sel?FontWeight.bold:FontWeight.normal)))));})),
    Expanded(child:loading?const Center(child:CircularProgressIndicator()):GridView.builder(padding:const EdgeInsets.all(8),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,childAspectRatio:0.8,crossAxisSpacing:6,mainAxisSpacing:6),itemCount:streams.length,itemBuilder:(_,i){final s=streams[i];final name=s['name']??s['title']??'';final icon=s['stream_icon']??s['cover']??'';return Focus(autofocus:i==0,onKey:(n,e){if(e is RawKeyDownEvent&&e.logicalKey==LogicalKeyboardKey.select){final list=streams.map((e)=>{'name':e['name']??e['title']??'','url':type=='m3u'?e['url']:_url(e)}).toList();Navigator.push(context,MaterialPageRoute(builder:(_)=>PlayerPage(streams:list,index:i)));return KeyEventResult.handled;}return KeyEventResult.ignored;},child:Builder(builder:(ctx){final has=Focus.of(ctx).hasFocus;return Container(decoration:BoxDecoration(color:Colors.grey[900],border:Border.all(color:has?Colors.red:Colors.transparent,width:3),borderRadius:BorderRadius.circular(5)),child:Column(children:[Expanded(child:icon!=''?Image.network(icon,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Icon(Icons.tv,color:Colors.white)):const Icon(Icons.tv,color:Colors.white)),Padding(padding:const EdgeInsets.all(3),child:Text(name,maxLines:2,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:11)))]));}));}))
  ]));}
}

// ===== PLAYER =====
class PlayerPage extends StatefulWidget { final List streams; final int index; const PlayerPage({super.key,required this.streams,required this.index}); @override State<PlayerPage> createState()=>_PlayerPageState(); }
class _PlayerPageState extends State<PlayerPage> {
  late BetterPlayerController ctrl; int idx=0; bool show=true; Timer? t;
  @override void initState(){super.initState();idx=widget.index;_play();}
  void _play(){ctrl=BetterPlayerController(const BetterPlayerConfiguration(autoPlay:true,fit:BoxFit.contain,controlsConfiguration:BetterPlayerControlsConfiguration(showControls:false)),betterPlayerDataSource:BetterPlayerDataSource(BetterPlayerDataSourceType.network,widget.streams[idx]['url']));setState(()=>show=true);t?.cancel();t=Timer(const Duration(seconds:2),()=>setState(()=>show=false));}
  void _next(){if(idx<widget.streams.length-1){setState(()=>idx++);ctrl.dispose();_play();}}
  void _prev(){if(idx>0){setState(()=>idx--);ctrl.dispose();_play();}}
  @override void dispose(){ctrl.dispose();t?.cancel();super.dispose();}
  @override Widget build(BuildContext context){final s=widget.streams[idx];return Scaffold(backgroundColor:Colors.black,body:Focus(autofocus:true,onKey:(n,e){if(e is RawKeyDownEvent){if(e.logicalKey==LogicalKeyboardKey.arrowUp){_next();return KeyEventResult.handled;}if(e.logicalKey==LogicalKeyboardKey.arrowDown){_prev();return KeyEventResult.handled;}if(e.logicalKey==LogicalKeyboardKey.goBack){Navigator.pop(context);return KeyEventResult.handled;}}return KeyEventResult.ignored;},child:Stack(children:[BetterPlayer(controller:ctrl),AnimatedOpacity(opacity:show?1:0,duration:const Duration(milliseconds:300),child:Container(alignment:Alignment.bottomCenter,padding:const EdgeInsets.all(20),child:Text(s['name'],style:const TextStyle(color:Colors.white,fontSize:20))))])));}
}

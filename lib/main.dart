import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const KamelTVApp());

class KamelTVApp extends StatelessWidget {
  const KamelTVApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
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
    Future.delayed(const Duration(milliseconds: 400), () async {
      final p = await SharedPreferences.getInstance();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => p.getString('type') == null? const LoginPage() : const HomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

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

  Future<void> saveXtream() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('type', 'xtream');
    await sp.setString('server', s.text.trim());
    await sp.setString('user', u.text.trim());
    await sp.setString('pass', p.text.trim());
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  Future<void> saveM3u() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('type', 'm3u');
    await sp.setString('m3u', m.text.trim());
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset('assets/icon.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Kamel TV', style: TextStyle(fontSize: 26, color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => isXtream = true),
                      style: ElevatedButton.styleFrom(backgroundColor: isXtream? Colors.red : Colors.grey[800]),
                      child: const Text('Xtream Codes'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => setState(() => isXtream = false),
                      style: ElevatedButton.styleFrom(backgroundColor:!isXtream? Colors.deepPurple : Colors.grey[800]),
                      child: const Text('M3U Playlist'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 380,
                  child: Column(
                    children: [
                      if (isXtream)...[
                        _whiteField(s, 'رابط السيرفر', Icons.dns, false, true),
                        const SizedBox(height: 12),
                        _whiteField(u, 'اسم المستخدم', Icons.person),
                        const SizedBox(height: 12),
                        _whiteField(p, 'كلمة المرور', Icons.lock, true),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: saveXtream,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('دخول', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ] else...[
                        _whiteField(m, 'رابط M3U', Icons.link, false, true),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: saveM3u,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                            child: const Text('دخول', style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // الخانة البيضاء الجديدة
  Widget _whiteField(TextEditingController c, String hint, IconData icon, [bool obscure = false, bool auto = false]) {
    return TextField(
      controller: c,
      obscureText: obscure,
      autofocus: auto,
      style: const TextStyle(color: Colors.black, fontSize: 16),
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.red),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 3),
        ),
      ),
    );
  }
}

// --- باقي التطبيق (نفس النسخة اللي خدمت عندك) ---
class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{String type='',server='',user='',pass='',m3u='';int menu=0;List cats=[],streams=[];String catId='';bool loading=false;final menus=[{'t':'البث المباشر','i':Icons.live_tv},{'t':'الأفلام','i':Icons.movie},{'t':'المسلسلات','i':Icons.tv},{'t':'المفضلة','i':Icons.favorite}];@override void initState(){super.initState();_init();}Future<void>_init()async{final sp=await SharedPreferences.getInstance();setState((){type=sp.getString('type')!;server=sp.getString('server')??'';user=sp.getString('user')??'';pass=sp.getString('pass')??'';m3u=sp.getString('m3u')??'';});_loadCats();}Future<void>_loadCats()async{if(type=='m3u'){_loadStreams();return;}setState(()=>loading=true);final act=menu==0?'get_live_categories':menu==1?'get_vod_categories':'get_series_categories';final r=await http.get(Uri.parse('$server/player_api.php?username=$user&password=$pass&action=$act'));final data=json.decode(utf8.decode(r.bodyBytes));setState((){cats=data;loading=false;if(cats.isNotEmpty){catId=cats[0]['category_id'];_loadStreams();}});}Future<void>_loadStreams()async{setState(()=>loading=true);if(type=='m3u'){final r=await http.get(Uri.parse(m3u));final lines=utf8.decode(r.bodyBytes).split('\n');final List s=[];for(int i=0;i<lines.length;i++){if(lines[i].startsWith('#EXTINF')){final n=lines[i].split(',').last;final ic=RegExp(r'tvg-logo="([^"]*)"').firstMatch(lines[i])?.group(1)??'';if(i+1<lines.length)s.add({'name':n,'url':lines[i+1].trim(),'icon':ic});}}setState((){streams=s;loading=false;});return;}final act=menu==0?'get_live_streams':menu==1?'get_vod_streams':'get_series';final r=await http.get(Uri.parse('$server/player_api.php?username=$user&password=$pass&action=$act&category_id=$catId'));final data=json.decode(utf8.decode(r.bodyBytes));setState((){streams=data;loading=false;});}String _getUrl(m){if(menu==0)return'$server/live/$user/$pass/${m['stream_id']}.ts';if(menu==1)return'$server/movie/$user/$pass/${m['stream_id']}.${m['container_extension']}';return'$server/series/$user/$pass/${m['series_id']}';}@override Widget build(BuildContext context){return Scaffold(backgroundColor:Colors.black,body:Row(children:[Container(width:260,color:const Color(0xFF0D1B5C),child:Column(children:[const SizedBox(height:20),Row(children:[const SizedBox(width:12),const CircleAvatar(radius:22,backgroundImage:AssetImage('assets/icon.png')),const SizedBox(width:8),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Kamel TV',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),Text(user,style:const TextStyle(color:Colors.white70,fontSize:12))])]),const Divider(height:25,color:Colors.white24),...List.generate(menus.length,(i)=>Container(color:menu==i?Colors.red:Colors.transparent,child:ListTile(leading:Icon(menus[i]['i']as IconData,color:Colors.white),title:Text(menus[i]['t']as String,style:TextStyle(color:Colors.white,fontWeight:menu==i?FontWeight.bold:FontWeight.normal)),onTap:(){setState(()=>menu=i);_loadCats();}))),const Spacer(),TextButton(onPressed:()async{final sp=await SharedPreferences.getInstance();await sp.clear();if(mounted)Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const LoginPage()));},child:const Text('تسجيل خروج',style:TextStyle(color:Colors.white54)))]),Container(width:220,color:Colors.black,child:loading?const Center(child:CircularProgressIndicator()):ListView.builder(itemCount:cats.length,itemBuilder:(_,i){final c=cats[i];final sel=c['category_id']==catId;return Container(color:sel?const Color(0xFFB71C1C):Colors.transparent,child:ListTile(dense:true,title:Text(c['category_name']??'',style:const TextStyle(color:Colors.white)),onTap:(){setState(()=>catId=c['category_id']);_loadStreams();}));})),Expanded(child:Container(color:Colors.black,child:loading?const Center(child:CircularProgressIndicator()):GridView.builder(padding:const EdgeInsets.all(10),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,childAspectRatio:0.75,crossAxisSpacing:8,mainAxisSpacing:8),itemCount:streams.length,itemBuilder:(_,i){final s=streams[i];final name=s['name']??s['title']??'';final ic=s['stream_icon']??s['cover']??s['icon']??'';final url=type=='m3u'?s['url']:_getUrl(s);return InkWell(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>PlayerPage(url:url,title:name))),child:Container(decoration:BoxDecoration(color:Colors.grey[900],borderRadius:BorderRadius.circular(6)),child:Column(children:[Expanded(child:ic!=''?Image.network(ic,fit:BoxFit.cover,width:double.infinity,errorBuilder:(_,__,___)=>const Icon(Icons.tv,color:Colors.white70)):const Icon(Icons.tv,color:Colors.white70)),Padding(padding:const EdgeInsets.all(4),child:Text(name,maxLines:2,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:11)))])));})))]));}}

class PlayerPage extends StatefulWidget {final String url,title;const PlayerPage({super.key,required this.url,required this.title});@override State<PlayerPage> createState()=>_PlayerPageState();}
class _PlayerPageState extends State<PlayerPage>{late BetterPlayerController c;@override void initState(){super.initState();c=BetterPlayerController(const BetterPlayerConfiguration(autoPlay:true,fit:BoxFit.contain,controlsConfiguration:BetterPlayerControlsConfiguration(showControlsOnInitialize:false)),betterPlayerDataSource:BetterPlayerDataSource(BetterPlayerDataSourceType.network,widget.url));}@override void dispose(){c.dispose();super.dispose();}@override Widget build(BuildContext context){return Scaffold(backgroundColor:Colors.black,appBar:AppBar(backgroundColor:Colors.black,title:Text(widget.title)),body:Center(child:BetterPlayer(controller:c)));}}

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
  @override Widget build(BuildContext context) => const MaterialApp(debugShowCheckedModeBanner: false, home: Splash());
}

class Splash extends StatefulWidget { const Splash({super.key}); @override State<Splash> createState()=>_SplashState();}
class _SplashState extends State<Splash>{ @override void initState(){super.initState();Future.delayed(const Duration(milliseconds:300),()async{final p=await SharedPreferences.getInstance();if(!mounted)return;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>p.getString('type')==null?const LoginPage():const HomePage()));});} @override Widget build(BuildContext context)=>const Scaffold(backgroundColor:Colors.black,body:Center(child:CircularProgressIndicator()));}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState()=>_LoginPageState();}
class _LoginPageState extends State<LoginPage>{
  bool isXtream=true;
  final s=TextEditingController(text:'http://'),u=TextEditingController(),p=TextEditingController(),m=TextEditingController();
  _saveX() async {final sp=await SharedPreferences.getInstance();await sp.setString('type','xtream');await sp.setString('server',s.text.trim());await sp.setString('user',u.text.trim());await sp.setString('pass',p.text.trim());if(mounted)Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const HomePage()));}
  _saveM() async {final sp=await SharedPreferences.getInstance();await sp.setString('type','m3u');await sp.setString('m3u',m.text.trim());if(mounted)Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const HomePage()));}
  @override Widget build(BuildContext context){
    return Scaffold(body:Container(decoration:const BoxDecoration(image:DecorationImage(image:AssetImage('assets/background.jpeg'),fit:BoxFit.cover)),child:Center(child:SingleChildScrollView(child:Column(children:[
      Container(width:100,height:100,decoration:BoxDecoration(border:Border.all(color:Colors.red,width:3),borderRadius:BorderRadius.circular(10)),child:Image.asset('assets/icon.png',fit:BoxFit.cover)),
      const SizedBox(height:10),const Text('Kamel TV',style:TextStyle(color:Colors.red,fontSize:28,fontWeight:FontWeight.bold)),const SizedBox(height:20),
      Row(mainAxisSize:MainAxisSize.min,children:[ElevatedButton(onPressed:()=>setState(()=>isXtream=true),style:ElevatedButton.styleFrom(backgroundColor:isXtream?Colors.red:Colors.grey[800]),child:const Text('Xtream Codes')),const SizedBox(width:10),ElevatedButton(onPressed:()=>setState(()=>isXtream=false),style:ElevatedButton.styleFrom(backgroundColor:!isXtream?Colors.deepPurple:Colors.grey[800]),child:const Text('M3U Playlist'))]),
      const SizedBox(height:20),
      SizedBox(width:380,child:Column(children:[
        if(isXtream)...[
          _field(s,'رابط السيرفر',Icons.dns,true),const SizedBox(height:12),
          _field(u,'اسم المستخدم',Icons.person),const SizedBox(height:12),
          _field(p,'كلمة المرور',Icons.lock,false,true),const SizedBox(height:20),
          SizedBox(width:double.infinity,height:50,child:ElevatedButton(onPressed:_saveX,style:ElevatedButton.styleFrom(backgroundColor:Colors.red),child:const Text('دخول',style:TextStyle(fontSize:20)))),
        ]else...[
          _field(m,'رابط M3U',Icons.link,true),const SizedBox(height:20),
          SizedBox(width:double.infinity,height:50,child:ElevatedButton(onPressed:_saveM,style:ElevatedButton.styleFrom(backgroundColor:Colors.deepPurple),child:const Text('دخول',style:TextStyle(fontSize:20)))),
        ]
      ]))
    ]))))));
  }
  Widget _field(TextEditingController c,String h,IconData i,[bool auto=false,bool obs=false])=>TextField(controller:c,obscureText:obs,autofocus:auto,style:const TextStyle(color:Colors.black),decoration:InputDecoration(hintText:h,prefixIcon:Icon(i,color:Colors.red),filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:const BorderSide(color:Colors.red,width:3))));
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState();}
class _HomePageState extends State<HomePage>{
  String type='',server='',user='',pass='',m3u='';int menu=0;List cats=[],streams=[];String catId='';bool loading=false;int focusedCat=0,focusedChan=0;
  final menus=[{'t':'البث المباشر','i':Icons.live_tv},{'t':'الأفلام','i':Icons.movie},{'t':'المسلسلات','i':Icons.tv}];
  @override void initState(){super.initState();_init();}
  _init() async {final sp=await SharedPreferences.getInstance();setState((){type=sp.getString('type')!;server=sp.getString('server')??'';user=sp.getString('user')??'';pass=sp.getString('pass')??'';m3u=sp.getString('m3u')??'';});_loadCats();}
  _loadCats() async {if(type=='m3u'){_loadStreams();return;}setState(()=>loading=true);final act=menu==0?'get_live_categories':menu==1?'get_vod_categories':'get_series_categories';final r=await http.get(Uri.parse('$server/player_api.php?username=$user&password=$pass&action=$act'));final data=json.decode(utf8.decode(r.bodyBytes));setState((){cats=data;loading=false;if(cats.isNotEmpty){catId=cats[0]['category_id'];focusedCat=0;_loadStreams();}});}
  _loadStreams() async {setState(()=>loading=true);if(type=='m3u'){final r=await http.get(Uri.parse(m3u));final lines=utf8.decode(r.bodyBytes).split('\n');final List s=[];for(int i=0;i<lines.length;i++){if(lines[i].startsWith('#EXTINF')){final n=lines[i].split(',').last;if(i+1<lines.length)s.add({'name':n,'url':lines[i+1].trim()});}}setState((){streams=s;loading=false;focusedChan=0;});return;}final act=menu==0?'get_live_streams':menu==1?'get_vod_streams':'get_series';final r=await http.get(Uri.parse('$server/player_api.php?username=$user&password=$pass&action=$act&category_id=$catId'));final data=json.decode(utf8.decode(r.bodyBytes));setState((){streams=data;loading=false;focusedChan=0;});}
  String _getUrl(m){if(menu==0)return'$server/live/$user/$pass/${m['stream_id']}.ts';if(menu==1)return'$server/movie/$user/$pass/${m['stream_id']}.${m['container_extension']}';return'$server/series/$user/$pass/${m['series_id']}';}
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor:Colors.black,body:Row(children:[
      Container(width:250,color:const Color(0xFF0D1B5C),child:Column(children:[const SizedBox(height:30),const CircleAvatar(radius:30,backgroundImage:AssetImage('assets/icon.png')),const SizedBox(height:10),Text(user,style:const TextStyle(color:Colors.white)),const Divider(color:Colors.white24,height:30),...List.generate(menus.length,(i)=>Focus(onFocusChange:(f){if(f)setState(()=>menu=i);},child:Container(color:menu==i?Colors.red:Colors.transparent,child:ListTile(autofocus:i==0,leading:Icon(menus[i]['i']as IconData,color:Colors.white),title:Text(menus[i]['t']as String,style:const TextStyle(color:Colors.white)),onTap:(){setState(()=>menu=i);_loadCats();}))))])),
      Container(width:220,color:Colors.black,child:loading?const Center(child:CircularProgressIndicator()):ListView.builder(itemCount:cats.length,itemBuilder:(_,i){final c=cats[i];final sel=c['category_id']==catId;return Focus(onFocusChange:(f){if(f)setState((){catId=c['category_id'];focusedCat=i;_loadStreams();});},child:Container(color:sel?Colors.red.shade800:Colors.transparent,child:ListTile(title:Text(c['category_name']??'',style:TextStyle(color:Colors.white,fontWeight:sel?FontWeight.bold:FontWeight.normal))))); })),
      Expanded(child:loading?const Center(child:CircularProgressIndicator()):GridView.builder(padding:const EdgeInsets.all(10),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4,childAspectRatio:0.8,crossAxisSpacing:8,mainAxisSpacing:8),itemCount:streams.length,itemBuilder:(_,i){final s=streams[i];final name=s['name']??s['title']??'';final icon=s['stream_icon']??s['cover']??'';final url=type=='m3u'?s['url']:_getUrl(s);final isFocus=i==focusedChan;return Focus(autofocus:i==0,onFocusChange:(f){if(f)setState(()=>focusedChan=i);},onKey:(n,e){if(e is RawKeyDownEvent && e.logicalKey==LogicalKeyboardKey.select){final list=streams.map((e)=>{'name':e['name']??e['title']??'','url':type=='m3u'?e['url']:_getUrl(e)}).toList();Navigator.push(context,MaterialPageRoute(builder:(_)=>PlayerPage(streams:list,index:i)));return KeyEventResult.handled;}return KeyEventResult.ignored;},child:Container(decoration:BoxDecoration(color:Colors.grey[900],border:Border.all(color:isFocus?Colors.red:Colors.transparent,width:3),borderRadius:BorderRadius.circular(6)),child:Column(children:[Expanded(child:icon!=''?Image.network(icon,fit:BoxFit.cover,width:double.infinity,errorBuilder:(_,__,___)=>const Icon(Icons.tv,color:Colors.white)):const Icon(Icons.tv,color:Colors.white)),Padding(padding:const EdgeInsets.all(4),child:Text(name,maxLines:2,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white,fontSize:11)))])));}))),
    ]));
  }
}

class PlayerPage extends StatefulWidget {final List streams;final int index;const PlayerPage({super.key,required this.streams,required this.index});@override State<PlayerPage> createState()=>_PlayerPageState();}
class _PlayerPageState extends State<PlayerPage>{
  late BetterPlayerController ctrl;int idx=0;bool showInfo=true;Timer? t;
  @override void initState(){super.initState();idx=widget.index;_play();}
  void _play(){ctrl=BetterPlayerController(const BetterPlayerConfiguration(autoPlay:true,fit:BoxFit.contain,controlsConfiguration:BetterPlayerControlsConfiguration(showControls:false)),betterPlayerDataSource:BetterPlayerDataSource(BetterPlayerDataSourceType.network,widget.streams[idx]['url']));setState(()=>showInfo=true);t?.cancel();t=Timer(const Duration(seconds:2),()=>setState(()=>showInfo=false));}
  void _next(){if(idx<widget.streams.length-1){setState(()=>idx++);ctrl.dispose();_play();}}
  void _prev(){if(idx>0){setState(()=>idx--);ctrl.dispose();_play();}}
  void _showList(){showModalBottomSheet(context:context,backgroundColor:Colors.black87,builder:(_)=>ListView.builder(itemCount:widget.streams.length,itemBuilder:(_,i)=>ListTile(title:Text(widget.streams[i]['name'],style:TextStyle(color:i==idx?Colors.red:Colors.white)),onTap:(){Navigator.pop(context);setState(()=>idx=i);ctrl.dispose();_play();})));}
  @override void dispose(){ctrl.dispose();t?.cancel();super.dispose();}
  String _time(){final now=DateTime.now();return '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')} ${now.day}/${now.month}/${now.year}';}
  @override Widget build(BuildContext context){
    final s=widget.streams[idx];
    return Scaffold(backgroundColor:Colors.black,body:Focus(autofocus:true,onKey:(n,e){if(e is RawKeyDownEvent){if(e.logicalKey==LogicalKeyboardKey.arrowUp){_next();return KeyEventResult.handled;}if(e.logicalKey==LogicalKeyboardKey.arrowDown){_prev();return KeyEventResult.handled;}if(e.logicalKey==LogicalKeyboardKey.select){_showList();return KeyEventResult.handled;}if(e.logicalKey==LogicalKeyboardKey.goBack){Navigator.pop(context);return KeyEventResult.handled;}}return KeyEventResult.ignored;},child:Stack(children:[BetterPlayer(controller:ctrl),AnimatedOpacity(opacity:showInfo?1:0,duration:const Duration(milliseconds:300),child:Container(decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.black54,Colors.transparent,Colors.transparent,Colors.black54])),child:Stack(children:[Positioned(top:20,right:20,child:Text(_time(),style:const TextStyle(color:Colors.white,fontSize:16))),Positioned(bottom:30,left:20,right:20,child:Text(s['name'],style:const TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.bold),textAlign:TextAlign.center))])))]))));
  }
}

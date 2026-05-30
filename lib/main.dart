import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(const KamelApp());
}

class KamelApp extends StatelessWidget {
  const KamelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const Splash());
  }
}

class Splash extends StatefulWidget { const Splash({super.key}); @override State<Splash> createState()=>_SplashState();}
class _SplashState extends State<Splash>{
  @override initState(){super.initState(); _check();}
  _check() async { final p=await SharedPreferences.getInstance(); final h=p.getString('host'); await Future.delayed(const Duration(seconds:1));
    if(!mounted)return; Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=> h==null? const TvLogin(): HomePage(host:h!, user:p.getString('user')!, pass:p.getString('pass')!)));}
  @override Widget build(BuildContext context)=>Scaffold(body: Container(decoration:const BoxDecoration(image:DecorationImage(image:AssetImage('assets/background.jpeg'),fit:BoxFit.cover)),child:Center(child:Image.asset('assets/icon.png',width:180))));
}

// ========== LOGIN TV ==========
class TvLogin extends StatefulWidget{const TvLogin({super.key});@override State<TvLogin>createState()=>_TvLoginState();}
class _TvLoginState extends State<TvLogin>{
  bool isXtream=true;
  final url=TextEditingController(), user=TextEditingController(), pass=TextEditingController();
  final f1=FocusNode(), f2=FocusNode(), f3=FocusNode(), f4=FocusNode(), f5=FocusNode();
  @override initState(){super.initState(); WidgetsBinding.instance.addPostFrameCallback((_){f1.requestFocus();});}
  @override dispose(){f1.dispose();f2.dispose();f3.dispose();f4.dispose();f5.dispose();super.dispose();}

  login() async { if(url.text.isEmpty||user.text.isEmpty)return; final p=await SharedPreferences.getInstance();
    await p.setString('host',url.text); await p.setString('user',user.text); await p.setString('pass',pass.text);
    if(!mounted)return; Navigator.pushReplacement(context, MaterialPageRoute(builder:(_)=>HomePage(host:url.text,user:user.text,pass:pass.text)));}

  @override Widget build(BuildContext context){
    return Scaffold(body:Container(decoration:const BoxDecoration(image:DecorationImage(image:AssetImage('assets/background.jpeg'),fit:BoxFit.cover,colorFilter:ColorFilter.mode(Colors.black54,BlendMode.darken))),child:Center(child:SizedBox(width:850,child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Image.asset('assets/icon.png',width:150,height:150),const SizedBox(height:25),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[_btn('Xtream Codes',f1,true),const SizedBox(width:20),_btn('M3U Playlist',f2,false)]),
      const SizedBox(height:30),
      _field('رابط السيرفر http://...',url,f3,f4,TextInputType.url),_field('اسم المستخدم',user,f4,f5,TextInputType.text),_field('كلمة المرور',pass,f5,f5,TextInputType.visiblePassword,true),
      const SizedBox(height:25),_btn('اتصال',f5,null,login,isBig:true)
    ])))));}
  Widget _btn(String t,FocusNode n,bool? sel,[VoidCallback? a,bool isBig=false]){return Focus(focusNode:n,child:Builder(builder:(c){final f=Focus.of(c).hasFocus;return AnimatedContainer(duration:const Duration(milliseconds:150),width:isBig?380:260,height:65,decoration:BoxDecoration(color:sel==null?Colors.redAccent:(sel?Colors.pinkAccent:Colors.indigo.shade900),borderRadius:BorderRadius.circular(30),border:f?Border.all(color:Colors.white,width:3):null),child:InkWell(onTap:a??(){setState(()=>isXtream=t.contains('Xtream'));},child:Center(child:Text(t,style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)))));}));}
  Widget _field(String h,TextEditingController c,FocusNode n,FocusNode nx,TextInputType t,[bool p=false])=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Focus(focusNode:n,child:Builder(builder:(ctx){final f=Focus.of(ctx).hasFocus;return TextField(controller:c,focusNode:n,obscureText:p,keyboardType:t,textInputAction:TextInputAction.next,onSubmitted:(_)=>nx.requestFocus(),style:const TextStyle(fontSize:20),decoration:InputDecoration(hintText:h,filled:true,fillColor:Colors.black54,contentPadding:const EdgeInsets.symmetric(horizontal:18,vertical:14),border:OutlineInputBorder(borderRadius:BorderRadius.circular(10)),focusedBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(10),borderSide:BorderSide(color:f?Colors.pinkAccent:Colors.white,width:2))));})));
}

// ========== HOME ==========
class HomePage extends StatefulWidget{final String host,user,pass;const HomePage({super.key,required this.host,required this.user,required this.pass});@override State<HomePage>createState()=>_HomeState();}
class _HomeState extends State<HomePage>{List cats=[];bool load=true;
  @override initState(){super.initState();_load();}
  _load()async{try{final u='${widget.host}/player_api.php?username=${widget.user}&password=${widget.pass}&action=get_live_categories';final r=await http.get(Uri.parse(u));setState((){cats=json.decode(r.body);load=false;});}catch(e){setState(()=>load=false);}}
  @override Widget build(BuildContext context)=>Scaffold(body:Container(decoration:const BoxDecoration(image:DecorationImage(image:AssetImage('assets/background.jpeg'),fit:BoxFit.cover)),child:load?const Center(child:CircularProgressIndicator()):ListView.builder(padding:const EdgeInsets.all(40),itemCount:cats.length,itemBuilder:(_,i){final c=cats[i];return Card(color:Colors.black54,child:ListTile(autofocus:i==0,title:Text(c['category_name'],style:const TextStyle(fontSize:24)),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ChannelsPage(host:widget.host,user:widget.user,pass:widget.pass,catId:c['category_id'],name:c['category_name'])))));})));}
}

// ========== CHANNELS ==========
class ChannelsPage extends StatefulWidget{final String host,user,pass,catId,name;const ChannelsPage({super.key,required this.host,required this.user,required this.pass,required this.catId,required this.name});@override State<ChannelsPage>createState()=>_ChState();}
class _ChState extends State<ChannelsPage>{List ch=[];bool load=true;
  @override initState(){super.initState();_load();}
  _load()async{final u='${widget.host}/player_api.php?username=${widget.user}&password=${widget.pass}&action=get_live_streams&category_id=${widget.catId}';final r=await http.get(Uri.parse(u));setState((){ch=json.decode(r.body);load=false;});}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.name),backgroundColor:Colors.black54),body:load?const Center(child:CircularProgressIndicator()):GridView.builder(padding:const EdgeInsets.all(20),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:5,childAspectRatio:0.75),itemCount:ch.length,itemBuilder:(_,i){final s=ch[i];return Focus(autofocus:i==0,child:Builder(builder:(ctx){final f=Focus.of(ctx).hasFocus;return GestureDetector(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>Player(url:s['stream_id'].toString(),host:widget.host,user:widget.user,pass:widget.pass,name:s['name']))),child:AnimatedContainer(duration:const Duration(milliseconds:150),margin:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.black54,border:f?Border.all(color:Colors.pinkAccent,width:3):null,borderRadius:BorderRadius.circular(12)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.tv,size:50,color:f?Colors.pinkAccent:Colors.white),const SizedBox(height:10),Padding(padding:const EdgeInsets.all(6),child:Text(s['name'],textAlign:TextAlign.center,maxLines:2,style:TextStyle(color:f?Colors.pinkAccent:Colors.white)))])));}));}));}
}

// ========== PLAYER ==========
class Player extends StatefulWidget{final String url,host,user,pass,name;const Player({super.key,required this.url,required this.host,required this.user,required this.pass,required this.name});@override State<Player>createState()=>_PState();}
class _PState extends State<Player>{late VideoPlayerController c;bool ok=false;
  @override initState(){super.initState();final link='${widget.host}/live/${widget.user}/${widget.pass}/${widget.url}.ts';c=VideoPlayerController.networkUrl(Uri.parse(link))..initialize().then((_){setState(()=>ok=true);c.play();});}
  @override dispose(){c.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.black,body:Center(child:ok?AspectRatio(aspectRatio:c.value.aspectRatio,child:VideoPlayer(c)):const CircularProgressIndicator()),);
}

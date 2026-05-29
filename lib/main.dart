import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_player/better_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WakelockPlus.enable();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(KamelTVApp());
}

final Map<String, Map<String,String>> T = {
  'fr': {'app':'Kamel TV','live':'Canal','films':'Films','series':'Séries','settings':'Paramètres','account':'Compte','change':'Changer de liste','reload':'Recharger','exit':'SORTIR','login':'Connexion','host':'Hôte Xtream','user':'Utilisateur','pass':'Mot de passe','save':'Enregistrer','exp':'Expiration'},
  'ar': {'app':'كمال تيفي','live':'قنوات','films':'أفلام','series':'مسلسلات','settings':'إعدادات','account':'الحساب','change':'تغيير القائمة','reload':'إعادة تحميل','exit':'خروج','login':'تسجيل الدخول','host':'رابط اكستريم','user':'المستخدم','pass':'كلمة السر','save':'حفظ','exp':'انتهاء'},
  'cs': {'app':'Kamel TV','live':'Kanály','films':'Filmy','series':'Seriály','settings':'Nastavení','account':'Účet','change':'Změnit seznam','reload':'Obnovit','exit':'KONEC','login':'Přihlášení','host':'Xtream host','user':'Uživatel','pass':'Heslo','save':'Uložit','exp':'Expirace'},
};
String lang = 'fr';
String t(String k) => T[lang]?[k]?? k;

class KamelTVApp extends StatelessWidget {
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner:false, home:SplashPro(), theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0B0E2A)));
  }
}

class SplashPro extends StatefulWidget { @override _SplashProState createState()=>_SplashProState(); }
class _SplashProState extends State<SplashPro> {
  @override void initState(){ super.initState(); _init(); }
  _init() async {
    final p = await SharedPreferences.getInstance();
    lang = p.getString('lang')?? 'fr';
    await Future.delayed(Duration(seconds:2));
    final has = p.getString('host')!= null;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => has? HomePro() : LoginPro()));
  }
  @override Widget build(BuildContext context){
    return Scaffold(body: Container(decoration: BoxDecoration(gradient: LinearGradient(colors:[Color(0xFF1a1a4a), Color(0xFF0B0E2A)])), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children:[ Image.asset('assets/icon.png', width:140), SizedBox(height:20), Text('Kamel TV', style: TextStyle(fontSize:32, fontWeight: FontWeight.bold)), Text('PRO', style: TextStyle(color: Colors.purpleAccent, letterSpacing: 4)) ]))));
  }
}

class LoginPro extends StatefulWidget { @override _LoginProState createState()=>_LoginProState(); }
class _LoginProState extends State<LoginPro> {
  final host = TextEditingController(); final user = TextEditingController(); final pass = TextEditingController();
  _save() async { final p = await SharedPreferences.getInstance(); await p.setString('host', host.text); await p.setString('user', user.text); await p.setString('pass', pass.text); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomePro())); }
  @override Widget build(BuildContext context){
    return Scaffold(body: Stack(fit: StackFit.expand, children:[ Image.asset('assets/background.jpeg', fit: BoxFit.cover), Container(color: Colors.black54), Center(child: Container(width:500, padding: EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, children:[ Text(t('login'), style: TextStyle(fontSize:28)), SizedBox(height:20), TextField(controller: host, decoration: InputDecoration(labelText: t('host'), filled:true)), SizedBox(height:12), TextField(controller: user, decoration: InputDecoration(labelText: t('user'), filled:true)), SizedBox(height:12), TextField(controller: pass, obscureText:true, decoration: InputDecoration(labelText: t('pass'), filled:true)), SizedBox(height:20), ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, minimumSize: Size(double.infinity,50)), child: Text(t('save'))) ]))) ]));
  }
}

class HomePro extends StatefulWidget { @override _HomeProState createState()=>_HomeProState(); }
class _HomeProState extends State<HomePro> {
  String exp = '2025-12-31';
  @override void initState(){ super.initState(); _load(); }
  _load() async { final p = await SharedPreferences.getInstance(); setState((){ lang = p.getString('lang')?? 'fr'; }); }
  @override Widget build(BuildContext context){
    final items = [
      {'k':'live','icon':Icons.live_tv,'page':()=>LiveProPage()},
      {'k':'films','icon':Icons.movie,'page':()=>FilmsPage()},
      {'k':'series','icon':Icons.tv,'page':()=>SeriesPage()},
      {'k':'settings','icon':Icons.settings,'page':()=>SettingsPage()},
      {'k':'account','icon':Icons.person,'page':null},
      {'k':'change','icon':Icons.swap_horiz,'page':null},
      {'k':'reload','icon':Icons.refresh,'page':null},
      {'k':'exit','icon':Icons.power_settings_new,'page':null},
    ];
    return Scaffold(body: Container(decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/background.jpeg'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken))), child: Column(children:[
      Container(padding: EdgeInsets.symmetric(horizontal:24, vertical:16), color: Colors.black54, child: Row(children:[ Image.asset('assets/icon.png', width:40), SizedBox(width:12), Text(t('app'), style: TextStyle(fontSize:24, fontWeight: FontWeight.bold)), Spacer(), Text('${t('exp')}: $exp', style: TextStyle(color: Colors.amber)) ])),
      Expanded(child: Padding(padding: EdgeInsets.all(32), child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:4, childAspectRatio:1.6, crossAxisSpacing:20, mainAxisSpacing:20), itemCount: items.length, itemBuilder: (_,i){ final it=items[i]; return InkWell(onTap:(){ if(it['page']!=null) Navigator.push(context, MaterialPageRoute(builder: (_)=>(it['page'] as Function)())); }, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors:[Colors.purple.shade800, Colors.indigo.shade900]), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[ Icon(it['icon'] as IconData, size:48), SizedBox(height:12), Text(t(it['k'] as String), style: TextStyle(fontSize:18)) ]))); })))
    ])));
  }
}

class LiveProPage extends StatefulWidget { @override _LiveProPageState createState()=>_LiveProPageState(); }
class _LiveProPageState extends State<LiveProPage> {
  List cats=[]; List chans=[]; int ci=0; int si=0; BetterPlayerController? pc; String host=''; String user=''; String pass='';
  @override void initState(){ super.initState(); _init(); }
  _init() async { final p=await SharedPreferences.getInstance(); host=p.getString('host')??''; user=p.getString('user')??''; pass=p.getString('pass')??''; _loadCats(); }
  _loadCats() async { try{ final r=await http.get(Uri.parse('$host/player_api.php?username=$user&password=$pass&action=get_live_categories')); cats=json.decode(r.body); setState((){}); if(cats.isNotEmpty) _loadChans(cats[0]['category_id']); }catch(e){} }
  _loadChans(id) async { final r=await http.get(Uri.parse('$host/player_api.php?username=$user&password=$pass&action=get_live_streams&category_id=$id')); chans=json.decode(r.body); si=0; setState((){}); if(chans.isNotEmpty) _play(chans[0]); }
  _play(ch) { final url='$host/live/$user/$pass/${ch['stream_id']}.m3u8'; pc?.dispose(); pc = BetterPlayerController(BetterPlayerConfiguration(autoPlay:true, aspectRatio:16/9)); pc!.setupDataSource(BetterPlayerDataSource(BetterPlayerDataSourceType.network, url, liveStream:true)); setState((){}); }
  @override void dispose(){ pc?.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color(0xFF0B0E2A), body: Row(children:[
      Container(width:280, color: Colors.black45, child: ListView.builder(itemCount:cats.length, itemBuilder:(_,i)=> ListTile(selected:i==ci, selectedTileColor: Colors.purple.shade800, title: Text(cats[i]['category_name']??''), onTap:(){ setState(()=>ci=i); _loadChans(cats[i]['category_id']); }))),
      Container(width:380, color: Colors.black26, child: ListView.builder(itemCount:chans.length, itemBuilder:(_,i)=> ListTile(selected:i==si, selectedTileColor: Colors.indigo.shade700, title: Text(chans[i]['name']??'', maxLines:1, overflow:TextOverflow.ellipsis), onTap:(){ setState(()=>si=i); _play(chans[i]); }))),
      Expanded(child: Column(children:[ Expanded(child: Container(margin: EdgeInsets.all(16), child: pc==null? Center(child: Text('Select channel')): BetterPlayer(controller: pc!))), Container(padding: EdgeInsets.all(12), color: Colors.black54, child: Text(si<chans.length? chans[si]['name']??'':'', style: TextStyle(fontSize:20))) ]))
    ]));
  }
}

class FilmsPage extends StatelessWidget { @override Widget build(BuildContext context)=> Scaffold(appBar: AppBar(title: Text(t('films'))), body: Center(child: Text('Films'))); }
class SeriesPage extends StatelessWidget { @override Widget build(BuildContext context)=> Scaffold(appBar: AppBar(title: Text(t('series'))), body: Center(child: Text('Series'))); }
class SettingsPage extends StatefulWidget { @override _SettingsPageState createState()=>_SettingsPageState(); }
class _SettingsPageState extends State<SettingsPage> {
  _set(l) async { final p=await SharedPreferences.getInstance(); await p.setString('lang', l); setState(()=>lang=l); }
  @override Widget build(BuildContext context)=> Scaffold(appBar: AppBar(title: Text(t('settings'))), body: ListView(children:[ ListTile(title:Text('Français'), onTap:()=>_set('fr')), ListTile(title:Text('العربية'), onTap:()=>_set('ar')), ListTile(title:Text('Čeština'), onTap:()=>_set('cs')) ]));
}

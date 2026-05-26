import 'dart:convert';
import 'package:http/http.dart' as http;

class XtreamAPI {
  final String baseUrl;
  final String username;
  final String password;
  
  XtreamAPI({required this.baseUrl, required this.username, required this.password});

  // يجيب كل القنوات live
  Future<List<XtreamChannel>> getLiveStreams() async {
    final url = Uri.parse('$baseUrl/player_api.php?username=$username&password=$password&action=get_live_streams');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => XtreamChannel.fromJson(e)).toList();
    }
    throw Exception('فشل في جلب القنوات');
  }

  // يجيب الفئات متاع live
  Future<List<XtreamCategory>> getLiveCategories() async {
    final url = Uri.parse('$baseUrl/player_api.php?username=$username&password=$password&action=get_live_categories');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => XtreamCategory.fromJson(e)).toList();
    }
    throw Exception('فشل في جلب الفئات');
  }

  // يبني رابط التشغيل
  String getStreamUrl(int streamId, String extension) {
    return '$baseUrl/live/$username/$password/$streamId.$extension';
  }
}

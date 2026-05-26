import 'package:http/http.dart' as http;

class M3UChannel {
  final String name;
  final String url;
  final String? logo;
  final String? group;
  
  M3UChannel({required this.name, required this.url, this.logo, this.group});
  
  Map toJson() => {
    'name': name,
    'stream_icon': logo,
    'category_name': group,
    'url': url,
    'stream_type': 'live',
    'stream_id': url.hashCode,
  };
}

class M3UParser {
  static Future<List<M3UChannel>> parseFromUrl(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode!= 200) throw Exception('فشل تحميل M3U');
    return parse(res.body);
  }

  static List<M3UChannel> parse(String content) {
    List<M3UChannel> channels = [];
    final lines = content.split('\n');
    String? name, logo, group;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#EXTINF:')) {
        name = line.split(',').last;
        logo = _extract(line, 'tvg-logo');
        group = _extract(line, 'group-title');
      } else if (line.startsWith('http') && name!= null) {
        channels.add(M3UChannel(name: name, url: line, logo: logo, group: group));
        name = logo = group = null;
      }
    }
    return channels;
  }

  static String? _extract(String line, String attr) {
    final regex = RegExp('$attr="(.*?)"');
    return regex.firstMatch(line)?.group(1);
  }
}

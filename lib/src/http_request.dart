import 'package:http/http.dart' as http;

class HttpRequest {
  final http.BaseClient _httpClient = http.Client();

  Future<Map<String, String>> requestToRequestToken(
    String url,
    String headerString,
  ) async {
    final http.Response res = await _httpClient.post(
      url,
      headers: <String, String>{
        'Authorization': headerString,
      },
    );

    if (res.statusCode != 200) {
      throw StateError(res.body);
    }

    final Map<String, String> params = Uri.splitQueryString(res.body);
    if (params['oauth_callback_confirmed'].toLowerCase() != 'true') {
      throw StateError('oauth_callback_confirmed mast be true');
    }
    return params;
  }

  Future<Map<String, String>> requestToAccessToken(
      String url, String headerString) async {
    final http.Response res =
        await _httpClient.post(url, headers: <String, String>{
      'Authorization': headerString,
    });

    if (res.statusCode != 200) {
      throw StateError(res.body);
    }

    final Map<String, String> params = Uri.splitQueryString(res.body);
    return params;
  }
}

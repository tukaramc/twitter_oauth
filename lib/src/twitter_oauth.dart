import 'http_header_builder.dart';
import 'http_request.dart';
import 'signature.dart';

class TwitterOauth {
  TwitterOauth(
    this.apiKey,
    this.apiSecretKey,
    this.callbackUri,
  );

  final String apiKey;
  final String apiSecretKey;
  final String callbackUri;

  final HttpHeaderBuilder _httpHeaderBuilder = HttpHeaderBuilder();
  final HttpRequest _httpRequest = HttpRequest();
  final int dtNow = DateTime.now().millisecondsSinceEpoch;
  Signature _signature;
  String _oauthToken = '';
  String _oauthTokenSecret = '';

  final Map<String, String> _twitterUri = <String, String>{
    'requestToken': 'https://api.twitter.com/oauth/request_token',
    'authorize': 'https://api.twitter.com/oauth/authorize',
    'accessToken': 'https://api.twitter.com/oauth/access_token',
  };

  /// Returns a `Future<String>`
  ///
  /// Return authorizeUri
  Future<String> getAuthorizeUri() async {
    final Map<String, String> params = <String, String>{
      'oauth_consumer_key': apiKey,
      'oauth_token': _oauthToken,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': (dtNow / 1000).floor().toString(),
      'oauth_nonce': dtNow.toString(),
      'oauth_version': '1.0',
      'oauth_callback': callbackUri,
    };

    _signature = Signature(
      url: _twitterUri['requestToken'],
      method: 'POST',
      params: params,
      apiKey: apiKey,
      apiSecretKey: apiSecretKey,
      tokenSecretKey: _oauthTokenSecret,
    );

    params['oauth_signature'] = _signature.signatureHmacSha1(
      _signature.createSignatureKey(),
      _signature.signatureDate().toString(),
    );

    final Map<String, String> res = await _httpRequest.requestToRequestToken(
      _twitterUri['requestToken'],
      _httpHeaderBuilder.authHeaer(params),
    );

    _oauthToken = res['oauth_token'];
    _oauthTokenSecret = res['oauht_token_secret'];

    return '${_twitterUri['authorize']}?oauth_token=$_oauthToken';
  }

  /// Returns a `Future<Map<String, String>>`
  ///
  /// Returns [oauthToken] and [authTokenSecret]
  Future<Map<String, String>> getAccessToken(Map<String, String> token) async {
    final Map<String, String> params = <String, String>{
      'oauth_consumer_key': apiKey,
      'oauth_token': token['oauth_token'],
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': (dtNow / 1000).floor().toString(),
      'oauth_verifier': token['oauth_verifier'],
      'oauth_nonce': dtNow.toString(),
      'oauth_version': '1.0',
    };

    _signature = Signature(
      url: _twitterUri['accessToken'],
      method: 'POST',
      params: params,
      apiKey: apiKey,
      apiSecretKey: apiSecretKey,
      tokenSecretKey: _oauthTokenSecret,
    );

    params['oauth_signature'] = _signature.signatureHmacSha1(
      _signature.createSignatureKey(),
      _signature.signatureDate().toString(),
    );

    final Map<String, String> res = await _httpRequest.requestToAccessToken(
      _twitterUri['accessToken'],
      _httpHeaderBuilder.authHeaer(params),
    );
    return res;
  }
}

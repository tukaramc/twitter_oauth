class HttpHeaderBuilder {
  String authHeaderParams(String apiKey, String signatureDate) {
    final Map<String, String> params = <String, String>{};
    final int milSeconde = DateTime.now().millisecondsSinceEpoch;
    params['oauth_nonce'] = milSeconde.toString();
    params['oauth_signature_method'] = 'HMAC-SHA1';
    params['oauth_timestamp'] = (milSeconde / 1000).floor().toString();
    params['oauth_consumer_key'] = apiKey;
    params['oauth_version'] = '1.0';

    if (!params.containsKey('oauth_signature')) {
      params['oauth_signature'] = signatureDate;
    }
    return authHeaer(params);
  }

  String authHeaer(Map<String, String> params) {
    final String authHeader = 'OAuth ' +
        params.keys.map((String k) {
          return '$k="${Uri.encodeComponent(params[k])}"';
        }).join(', ');
    return authHeader;
  }
}

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' show sha256, Hmac, Digest;

class AuthorizationSDKService {
  static String hmac(
    String uri,
    String method,
    // 含端口不含协议，如: 127.0.0.1:8080
    String host,
    String macKey,
  ) {
    AuthorizationRequest request = new AuthorizationRequest(
      uri,
      method,
      host,
      Nonce.makeNonce(),
    );
    StringBuffer sb = StringBuffer();
    sb.write("MAC ");
    sb.write("id=" + macKey);
    sb.write(",nonce=" + request.nonce.toString());
    sb.write(",mac=" + generalMac(request, macKey));

    return sb.toString();
  }

  static String hmacUrl(
    String url,
    String method,
    String macKey,
  ) {
    Uri uri = Uri.parse(url);
    return hmac(
        uri.path + (_StringWrap.isBlank(uri.query) ? '' : '?${uri.query}'),
        method,
        uri.host + (uri.hasPort ? ':${uri.port.toString()}' : ''),
        macKey);
  }

  static AuthorizationEntity getAuthorization(
    String uri,
    String method,
    String host,
    String macKey,
  ) {
    AuthorizationEntity entity = AuthorizationEntity(
      hmacUrl(uri, method, macKey),
      host,
      method,
      uri,
    );
    return entity;
  }

  static AuthorizationEntity getAuthorizationUrl(
    String url,
    String method,
    String macKey,
  ) {
    Uri uri = Uri.parse(url);
    return getAuthorization(
        uri.path + (_StringWrap.isBlank(uri.query) ? '' : '?' + uri.query),
        method,
        uri.host,
        macKey);
  }

  static String generalMac(AuthorizationRequest request, String macKey) {
    return _StringWrap.encryptHMac256(
        request.nonce.toString() +
            AuthorizationConstant.STR_SYMBOL +
            request.method +
            AuthorizationConstant.STR_SYMBOL +
            request.uri +
            AuthorizationConstant.STR_SYMBOL +
            request.host +
            AuthorizationConstant.STR_SYMBOL,
        macKey);
  }
}

class AuthorizationConstant {
  static const String STR_SYMBOL = "\n";
  static const String AUTHORIZATION = "Authorization";
  static const String AUTHORIZATION_METHOD = "AuthorizationMethod";
  static const String AUTHORIZATION_HOST = "AuthorizationHost";
  static const String AUTHORIZATION_URI = "AuthorizationUri";
}

class AuthorizationEntity {
  String authorization;
  String authorizationUri;
  String authorizationMethod;
  String authorizationHost;

  AuthorizationEntity(
    this.authorization,
    this.authorizationUri,
    this.authorizationMethod,
    this.authorizationHost,
  );

  String getEncodeAuthorization() {
    return _StringWrap.isBlank(authorization)
        ? ""
        : base64.encode(authorization.codeUnits);
  }

  String getEncodeAuthorizationUri() {
    return _StringWrap.isBlank(authorizationUri)
        ? ""
        : base64.encode(authorizationUri.codeUnits);
  }

  String getEncodeAuthorizationMethod() {
    return _StringWrap.isBlank(authorizationMethod)
        ? ""
        : base64.encode(authorizationMethod.codeUnits);
  }

  String getEncodeAuthorizationHost() {
    return _StringWrap.isBlank(authorizationHost)
        ? ""
        : base64.encode(authorizationHost.codeUnits);
  }

  String toQuery() {
    StringBuffer sb = StringBuffer();
    sb.write(
        AuthorizationConstant.AUTHORIZATION + "=" + getEncodeAuthorization());
    sb.write("&");
    sb.write(AuthorizationConstant.AUTHORIZATION_METHOD +
        "=" +
        getEncodeAuthorizationMethod());
    sb.write("&");
    sb.write(AuthorizationConstant.AUTHORIZATION_URI +
        "=" +
        getEncodeAuthorizationUri());
    sb.write("&");
    sb.write(AuthorizationConstant.AUTHORIZATION_HOST +
        "=" +
        getEncodeAuthorizationHost());
    return sb.toString();
  }
}

class Nonce {
  int timestamp;
  String nonce;

  Nonce(this.timestamp, this.nonce);
  static Nonce makeNonce() {
    Nonce nonceInstance = new Nonce(
        DateTime.now().millisecondsSinceEpoch, _StringWrap.general(8));
    return nonceInstance;
  }

  @override
  String toString() {
    return timestamp.toString() + ":" + nonce;
  }
}

class AuthorizationRequest {
  String uri;
  String method;
  String host;
  Nonce nonce;

  AuthorizationRequest(
    this.uri,
    this.method,
    this.host,
    this.nonce,
  ) {
    setUri(uri);
    setMethod(method);
    setHost(host);
  }

  setUri(String uri) {
    if (!_StringWrap.isBlank(uri)) {
      this.uri = _StringWrap.translateUri(uri);
    } else {
      this.uri = "";
    }
  }

  setMethod(String method) {
    if (!_StringWrap.isBlank(method)) {
      this.method = method.toUpperCase();
    } else {
      this.method = "";
    }
  }

  setHost(String host) {
    if (!_StringWrap.isBlank(host) && host.endsWith(":80")) {
      this.host = host.replaceAll(":80", "");
    } else {
      this.host = host;
    }
  }
}

class _StringWrap {
  static String general(int length) {
    String alphabet = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(alphabet[Random().nextInt(alphabet.length)]);
    }
    return sb.toString();
  }

  static bool isBlank(String str) {
    return str.isEmpty;
  }

  static String translateUri(String uri) {
    if (!_StringWrap.isBlank(uri)) {
      List<String> uris = uri.split("?");
      if (uris.length > 1) {
        StringBuffer sb = StringBuffer();
        sb.write(uris[0] + "?");

        List<String> paramList = uris[1].split("&");
        paramList.sort();

        paramList.forEach((param) {
          sb.write(param);
          sb.write("&");
        });
        if (sb.toString().endsWith("&")) {
          return sb.toString().substring(0, sb.length - 1);
        } else {
          return sb.toString();
        }
      } else {
        return uri;
      }
    }
    return uri;
  }

  static String encryptHMac256(String message, String macKey) {
    List<int> messageBytes = utf8.encode(message);
    List<int> key = utf8.encode(macKey);
    Hmac hmac = new Hmac(sha256, key);
    Digest digest = hmac.convert(messageBytes);
    return base64.encode(digest.bytes);
  }
}

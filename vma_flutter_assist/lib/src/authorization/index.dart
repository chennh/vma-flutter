import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart' show sha256, Hmac, Digest;

class AuthorizationSDKService {
  static String hmac(
    String uri,
    String method,
    String host,
    String macKey,
  ) {
    AuthorizationRequest request = new AuthorizationRequest(
      uri: uri,
      method: method,
      host: host,
      nonce: Nonce.makeNonce(),
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
        uri.path + (StringWrap.isBlank(uri.query) ? '' : '?' + uri.query),
        method,
        uri.host,
        macKey);
  }

  static AuthorizationEntity getAuthorization(
    String uri,
    String method,
    String host,
    String macKey,
  ) {
    AuthorizationEntity entity = AuthorizationEntity(
      authorization: hmacUrl(uri, method, macKey),
      authorizationHost: host,
      authorizationMethod: method,
      authorizationUri: uri,
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
        uri.path + (StringWrap.isBlank(uri.query) ? '' : '?' + uri.query),
        method,
        uri.host,
        macKey);
  }

  static String generalMac(AuthorizationRequest request, String macKey) {
    return StringWrap.encryptHMac256(
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

  AuthorizationEntity({
    String authorization,
    String authorizationUri,
    String authorizationMethod,
    String authorizationHost,
  })  : this.authorization = authorization,
        this.authorizationHost = authorizationHost,
        this.authorizationMethod = authorizationMethod,
        this.authorizationUri = authorizationUri;

  String getEncodeAuthorization() {
    return StringWrap.isBlank(authorization)
        ? ""
        : base64.encode(authorization.codeUnits);
  }

  String getEncodeAuthorizationUri() {
    return StringWrap.isBlank(authorizationUri)
        ? ""
        : base64.encode(authorizationUri.codeUnits);
  }

  String getEncodeAuthorizationMethod() {
    return StringWrap.isBlank(authorizationMethod)
        ? ""
        : base64.encode(authorizationMethod.codeUnits);
  }

  String getEncodeAuthorizationHost() {
    return StringWrap.isBlank(authorizationHost)
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

  Nonce({num timestamp, String nonce})
      : this.timestamp = timestamp,
        this.nonce = nonce;

  static Nonce makeNonce() {
    Nonce nonceInstance = new Nonce(
        timestamp: DateTime.now().microsecondsSinceEpoch,
        nonce: StringWrap.general(8));
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

  AuthorizationRequest({
    String uri,
    String method,
    String host,
    Nonce nonce,
  }) : this.nonce = nonce {
    setUri(uri);
    setMethod(method);
    setHost(host);
  }

  setUri(String uri) {
    if (!StringWrap.isBlank(uri)) {
      this.uri = StringWrap.translateUri(uri);
    } else {
      this.uri = "";
    }
  }

  setMethod(String method) {
    if (!StringWrap.isBlank(method)) {
      this.method = method.toUpperCase();
    } else {
      this.method = "";
    }
  }

  setHost(String host) {
    if (!StringWrap.isBlank(host) && host.endsWith(":80")) {
      this.host = host.replaceAll(":80", "");
    } else {
      this.host = host;
    }
  }
}

class StringWrap {
  static String general(int length) {
    String alphabet = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(alphabet[Random().nextInt(alphabet.length)]);
    }
    return sb.toString();
  }

  static bool isBlank(String str) {
    return str == null || str.isNotEmpty;
  }

  static String translateUri(String uri) {
    if (!StringWrap.isBlank(uri)) {
      List<String> uris = uri.split("\\?");
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

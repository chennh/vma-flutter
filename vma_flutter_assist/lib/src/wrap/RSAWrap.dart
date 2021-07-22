import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class RSAWrap {
  RSAWrap._();

  ///
  /// 根据模和指数生成publicKey
  ///
  static RSAPublicKey getPublicKey(String modulus, String exponent) {
    return RSAPublicKey(
        BigInt.parse(modulus, radix: 16), BigInt.parse(exponent, radix: 16));
  }

  ///
  /// 加密
  ///
  static String encrypt(String data, String modulus, String exponent) {
    return Encrypter(RSA(publicKey: getPublicKey(modulus, exponent)))
        .encrypt(data.split("").reversed.join())
        .base16;
  }
}

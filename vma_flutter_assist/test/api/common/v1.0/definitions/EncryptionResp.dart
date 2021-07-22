import 'dart:convert' as dartConvert;
import 'package:vma_flutter_assist/vma_flutter_assist.dart';

class EncryptionResp extends Model {
  /// exponent
  String exponent;

  /// modulus
  String modulus;

  /// randomIndex
  String randomIndex;

  EncryptionResp({
    exponent,
    modulus,
    randomIndex,
  }) : this.fromJson({
          'exponent': exponent,
          'modulus': modulus,
          'randomIndex': randomIndex,
        });

  EncryptionResp.fromJson(Map<String, dynamic> map)
      : exponent = map['exponent'],
        modulus = map['modulus'],
        randomIndex = map['randomIndex'];

  EncryptionResp.fromJsonString(String jsonStr)
      : this.fromJson(dartConvert.json.decode(jsonStr));

  Map<String, dynamic> toJson() => {
        'exponent': exponent,
        'modulus': modulus,
        'randomIndex': randomIndex,
      };

  @override
  String toString() {
    return dartConvert.json.encode(this);
  }

  @override
  fromJson(Map<String, dynamic> map) => fromJson(map);

  @override
  fromJsonString(String jsonStr) => fromJsonString(jsonStr);
}

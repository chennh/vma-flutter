import 'dart:convert' as dartConvert;
import 'Model.dart';

class IPage<T> extends Model {
  int current;
  int size;
  int pages;
  int total;

  List<T>? records;

  IPage({
    int? current,
    int? size,
    int? pages,
    int? total,
    List<T>? records,
  }) : this.fromJson({
          'current': current,
          'size': size,
          'pages': pages,
          'total': total,
          'records': records,
        });

  IPage.fromJson(Map<String, dynamic> map)
      : current = map['current'],
        size = map['size'],
        pages = map['pages'],
        total = map['total'],
        records = map['records'];

  IPage.fromJsonString(String jsonStr)
      : this.fromJson(dartConvert.json.decode(jsonStr));

  Map<String, dynamic> toJson() => {
        'current': current,
        'size': size,
        'pages': pages,
        'total': total,
        'records': records,
      };

  @override
  String toString() {
    return dartConvert.json.encode(this);
  }

  @override
  fromJson(Map<String, dynamic> map) => Page.fromJson(map);

  @override
  fromJsonString(String jsonStr) => Page.fromJsonString(jsonStr);
}

class Page<T> extends IPage<T> {
  Page({
    int? current,
    int? size,
    int? pages,
    int? total,
    List<T>? records,
  }) : super(
          current: current,
          size: size,
          pages: pages,
          total: total,
          records: records,
        );

  Page.fromJson(Map<String, dynamic> map) : super.fromJson(map);

  Page.fromJsonString(String jsonStr)
      : super.fromJson(dartConvert.json.decode(jsonStr));
}

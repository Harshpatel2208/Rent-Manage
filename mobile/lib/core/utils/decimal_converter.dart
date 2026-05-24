import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class DecimalConverter implements JsonConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromJson(String json) => Decimal.parse(json);

  @override
  String toJson(Decimal object) => object.toString();
}

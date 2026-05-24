import 'package:freezed_annotation/freezed_annotation.dart';

part 'borrower.freezed.dart';
part 'borrower.g.dart';

@freezed
class Borrower with _$Borrower {
  const factory Borrower({
    required String id,
    required String fullName,
    required String phone,
    required String address,
    String? notes,
    required DateTime createdAt,
  }) = _Borrower;

  factory Borrower.fromJson(Map<String, dynamic> json) => _$BorrowerFromJson(json);
}

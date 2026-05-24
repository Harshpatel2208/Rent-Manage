import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';

part 'reports_provider.g.dart';

@riverpod
class SelectedReportDate extends _$SelectedReportDate {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setDate(DateTime date) {
    state = date;
  }
}

@riverpod
class MonthlyReportData extends _$MonthlyReportData {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    final date = ref.watch(selectedReportDateProvider);
    final dio = ref.watch(dioClientProvider);
    final response = await dio.get(
      ApiEndpoints.reportsMonthly,
      queryParameters: {
        'year': date.year,
        'month': date.month,
      },
    );
    // The response is usually wrapped in success response wrapper (with { data: ... })
    // In node controllers success response: success(res, { period, summary, loan_payments, rent_payments, expenses })
    // Let's inspect the response. It should contain 'data' containing the payload.
    // If the dio client's response interceptor or backend returns { status: 'success', data: ... }, we get response.data['data']
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>;
    }
    return data as Map<String, dynamic>;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final date = ref.read(selectedReportDateProvider);
      final dio = ref.read(dioClientProvider);
      final response = await dio.get(
        ApiEndpoints.reportsMonthly,
        queryParameters: {
          'year': date.year,
          'month': date.month,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data as Map<String, dynamic>;
    });
  }
}

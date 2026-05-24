import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_metrics_model.dart';

part 'dashboard_remote_datasource.g.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardMetricsModel> getMetrics();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<DashboardMetricsModel> getMetrics() async {
    final response = await _dio.get(ApiEndpoints.dashboard);
    // Backend wraps all responses as { success: true, data: {...} }
    final envelope = response.data as Map<String, dynamic>;
    final payload = envelope['data'] as Map<String, dynamic>;
    return DashboardMetricsModel.fromJson(payload);
  }
}

@Riverpod(keepAlive: true)
DashboardRemoteDataSource dashboardRemoteDataSource(Ref ref) =>
    DashboardRemoteDataSourceImpl(ref.watch(dioClientProvider));

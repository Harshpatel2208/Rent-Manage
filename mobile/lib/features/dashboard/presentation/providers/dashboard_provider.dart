import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/use_cases/get_dashboard_metrics.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  FutureOr<DashboardMetrics> build() async {
    final repository = ref.watch(dashboardRepositoryProvider);
    final useCase = GetDashboardMetricsUseCase(repository);
    return useCase.call();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.watch(dashboardRepositoryProvider);
      final useCase = GetDashboardMetricsUseCase(repository);
      return useCase.call();
    });
  }
}

import '../../domain/entities/dashboard_metrics.dart';
import '../../domain/repositories/dashboard_repository.dart';

class GetDashboardMetricsUseCase {
  const GetDashboardMetricsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardMetrics> call() => _repository.getMetrics();
}

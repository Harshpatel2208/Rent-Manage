// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedReportDateHash() =>
    r'502f65cef784943f6a45970e36f812cb4d53578f';

/// See also [SelectedReportDate].
@ProviderFor(SelectedReportDate)
final selectedReportDateProvider =
    AutoDisposeNotifierProvider<SelectedReportDate, DateTime>.internal(
  SelectedReportDate.new,
  name: r'selectedReportDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedReportDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedReportDate = AutoDisposeNotifier<DateTime>;
String _$monthlyReportDataHash() => r'9baa9ed8676462a9244aeabd96417c6f1d16d984';

/// See also [MonthlyReportData].
@ProviderFor(MonthlyReportData)
final monthlyReportDataProvider = AutoDisposeAsyncNotifierProvider<
    MonthlyReportData, Map<String, dynamic>>.internal(
  MonthlyReportData.new,
  name: r'monthlyReportDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthlyReportDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MonthlyReportData = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

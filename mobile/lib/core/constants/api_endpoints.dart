/// All API endpoint constants for the MoneyManager backend.
///
/// Base URL is configured via the [baseUrl] constant which can be
/// overridden per environment by rebuilding with --dart-define.
library;

class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL for all API calls. Override with --dart-define=BASE_URL=...
  /// 10.0.2.2 is the Android emulator's alias for the host machine's localhost.
  static const String baseUrl = 'https://rent-manager-api-5on4.onrender.com';

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authOtpSend = '/api/v1/auth/otp/send';
  static const String authOtpVerify = '/api/v1/auth/otp/verify';
  static const String authGoogle = '/api/v1/auth/google';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authLogout = '/api/v1/auth/logout';
  static const String userFcmToken = '/api/v1/users/fcm-token';

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------
  static const String dashboard = '/api/v1/dashboard';

  // ---------------------------------------------------------------------------
  // Loans / Lending
  // ---------------------------------------------------------------------------
  static const String loans = '/api/v1/loans';
  static const String loanCreate = '/api/v1/loans';
  static const String loanBorrowers = '/api/v1/loans/borrowers';

  /// Returns the endpoint for a specific loan by [id].
  static String loanDetail(String id) => '/api/v1/loans/$id';

  /// Returns the endpoint for recording payments on a loan by [id].
  static String loanPayments(String id) => '/api/v1/loans/$id/payments';

  /// Returns the endpoint for the interest schedule of a loan by [id].
  static String loanSchedule(String id) => '/api/v1/loans/$id/schedule';

  // ---------------------------------------------------------------------------
  // Rental
  // ---------------------------------------------------------------------------
  static const String rentalUnits = '/api/v1/rental/units';
  static const String rentalTenants = '/api/v1/rental/tenants';
  static const String rentalPayments = '/api/v1/rental/payments';

  /// Returns the rent ledger endpoint for a tenant by [tenantId].
  static String tenantLedger(String tenantId) =>
      '/api/v1/rental/tenants/$tenantId';

  // ---------------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------------
  static const String expenses = '/api/v1/expenses';

  // ---------------------------------------------------------------------------
  // Sync
  // ---------------------------------------------------------------------------
  static const String syncBatch = '/api/v1/sync/batch';
  static const String syncConflicts = '/api/v1/sync/conflicts';

  // ---------------------------------------------------------------------------
  // Reports
  // ---------------------------------------------------------------------------
  static const String reportsMonthly = '/api/v1/reports/monthly';
  static const String reportsPdf = '/api/v1/reports/export/pdf';
  static const String reportsCsv = '/api/v1/reports/export/csv';
}

/// All UI string constants for MoneyManager.
///
/// Centralising strings here makes localisation trivial — replace with
/// an ARB-backed [AppLocalizations] when multi-language support is needed.
class AppStrings {
  AppStrings._();

  // ---------------------------------------------------------------------------
  // App
  // ---------------------------------------------------------------------------
  static const String appName = 'MoneyManager';
  static const String appTagline = 'Your financial command centre';

  // ---------------------------------------------------------------------------
  // Auth — Login
  // ---------------------------------------------------------------------------
  static const String login = 'Login';
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to your account';
  static const String loginWithOtp = 'Login with OTP';
  static const String continueWithGoogle = 'Continue with Google';
  static const String noAccount = "Don't have an account? ";
  static const String register = 'Register';
  static const String registerTitle = 'Create Account';
  static const String registerSubtitle = 'Start managing your finances';
  static const String logout = 'Logout';

  // ---------------------------------------------------------------------------
  // Auth — OTP
  // ---------------------------------------------------------------------------
  static const String otpTitle = 'Verify Phone';
  static const String otpSubtitle = 'Enter the 6-digit code sent to your phone';
  static const String sendOtp = 'Send OTP';
  static const String verifyOtp = 'Verify OTP';
  static const String resendOtp = 'Resend OTP';
  static const String resendIn = 'Resend in ';

  // ---------------------------------------------------------------------------
  // Form Fields
  // ---------------------------------------------------------------------------
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String phone = 'Phone Number';
  static const String name = 'Full Name';
  static const String businessName = 'Business / Full Name';
  static const String amount = 'Amount';
  static const String date = 'Date';
  static const String notes = 'Notes';
  static const String description = 'Description';
  static const String category = 'Category';

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------
  static const String dashboardTitle = 'Dashboard';
  static const String totalCapitalLent = 'Total Capital Lent';
  static const String expectedMonthlyIncome = 'Expected Monthly Income';
  static const String thisMonthExpenses = "This Month's Expenses";
  static const String activeLoans = 'Active Loans';
  static const String activeTenants = 'Active Tenants';
  static const String pendingSync = 'Pending Sync Items';
  static const String pendingSyncBanner = 'items pending sync — tap to view';
  static const String newLoan = '+ New Loan';
  static const String recordRent = '+ Record Rent';
  static const String addExpense = '+ Add Expense';

  // ---------------------------------------------------------------------------
  // Loans
  // ---------------------------------------------------------------------------
  static const String loansTitle = 'Loans';
  static const String addLoan = 'Add Loan';
  static const String loanDetail = 'Loan Detail';
  static const String borrowerName = 'Borrower Name';
  static const String borrowerPhone = 'Borrower Phone';
  static const String borrowerAddress = 'Borrower Address';
  static const String principal = 'Principal Amount';
  static const String interestRate = 'Interest Rate (% p.m.)';
  static const String registrationDate = 'Registration Date';
  static const String loanStatus = 'Status';
  static const String outstandingBalance = 'Outstanding Balance';
  static const String firstCycleDate = 'First Cycle Date';
  static const String interestSchedule = 'Interest Schedule';
  static const String paymentHistory = 'Payment History';
  static const String recordInterestPayment = 'Record Interest Payment';
  static const String repayPrincipal = 'Repay Principal (Close Loan)';
  static const String closeLoanWarning =
      '⚠️ This will permanently close the loan. Confirm?';
  static const String selectPaymentType = 'Payment Type';
  static const String interestPayment = 'Interest';
  static const String principalPayment = 'Principal';
  static const String searchLoans = 'Search loans...';
  static const String filterByStatus = 'Filter by status';
  static const String allLoans = 'All';
  static const String activeLoansFilter = 'Active';
  static const String closedLoansFilter = 'Closed';
  static const String nextInterestDue = 'Next due';

  // ---------------------------------------------------------------------------
  // Rental
  // ---------------------------------------------------------------------------
  static const String rentalTitle = 'Rental';
  static const String unitsTitle = 'Shop Units';
  static const String tenantsTitle = 'Tenants';
  static const String addUnit = 'Add Unit';
  static const String addTenant = 'Add Tenant';
  static const String unitName = 'Unit Name';
  static const String unitAddress = 'Address';
  static const String leaseStart = 'Lease Start Date';
  static const String rentAmount = 'Monthly Rent (₹)';
  static const String tenantLedger = 'Tenant Ledger';
  static const String totalOutstanding = 'Total Outstanding';
  static const String cycleMonth = 'Cycle Month';
  static const String amountDue = 'Amount Due';
  static const String amountPaying = 'Amount Paying';
  static const String remainingBalance = 'Remaining Balance';
  static const String recordPayment = 'Record Payment';
  static const String occupied = 'Occupied';
  static const String vacant = 'Vacant';
  static const String statusPaid = 'PAID';
  static const String statusPartiallyPaid = 'PARTIALLY PAID';
  static const String statusPending = 'PENDING';

  // ---------------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------------
  static const String expensesTitle = 'Expenses';
  static const String addExpenseTitle = 'Add Expense';
  static const String totalExpenses = 'Total';
  static const String catFood = 'Food';
  static const String catMaintenance = 'Maintenance';
  static const String catTravel = 'Travel';
  static const String catBusiness = 'Business';
  static const String catOther = 'Other';

  // ---------------------------------------------------------------------------
  // Sync / Conflicts
  // ---------------------------------------------------------------------------
  static const String syncTitle = 'Sync Conflicts';
  static const String retrySync = 'Retry';
  static const String dismissConflict = 'Dismiss';
  static const String syncingMessage = 'Syncing data...';
  static const String syncSuccessMessage = 'All data synced successfully';

  // ---------------------------------------------------------------------------
  // Reports
  // ---------------------------------------------------------------------------
  static const String reportsTitle = 'Reports';
  static const String exportPdf = 'Export PDF';
  static const String exportCsv = 'Export CSV';
  static const String loanSummary = 'Loan Summary';
  static const String rentSummary = 'Rent Summary';
  static const String expenseBreakdown = 'Expense Breakdown';
  static const String profitLoss = 'Profit & Loss';

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String invalidPhone = 'Enter a valid 10-digit phone number';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String invalidAmount = 'Enter a valid amount';
  static const String amountMustBePositive = 'Amount must be greater than 0';

  // ---------------------------------------------------------------------------
  // Empty states
  // ---------------------------------------------------------------------------
  static const String noLoans = 'No loans yet. Tap + to add one.';
  static const String noTenants = 'No tenants yet. Tap + to add one.';
  static const String noExpenses = 'No expenses recorded yet.';
  static const String noConflicts = 'No sync conflicts. You are all caught up!';
  static const String noPayments = 'No payments recorded yet.';

  // ---------------------------------------------------------------------------
  // Generic
  // ---------------------------------------------------------------------------
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String close = 'Close';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String back = 'Back';
  static const String share = 'Share';
  static const String ok = 'OK';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String noInternet = 'No internet connection. Working offline.';
  static const String offlineMode = 'Offline mode — data will sync when connected.';
}

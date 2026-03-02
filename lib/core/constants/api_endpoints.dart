class ApiEndpoints {
  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String profile = '/profile';
  static const String avatar = '/profile/avatar';
  static const String lookupAccount = '/lookup-account';
  static const String sendResetOtp = '/send-reset-otp';
  static const String verifyResetOtp = '/verify-reset-otp';
  static const String resetPassword = '/reset-password';
  static const String resendVerification = '/email/verify/resend';
  static const String resendByEmail = '/email/verify/resend-by-email';

  // Phone OTP
  static const String sendPhoneOtp = '/phone/send-otp';
  static const String verifyPhone = '/phone/verify';

  // Locations
  static const String divisions = '/locations/divisions';
  static String districtsByDivision(String divisionId) =>
      '/locations/divisions/$divisionId/districts';
  static String upazilasByDistrict(String districtId) =>
      '/locations/districts/$districtId/upazilas';

  // Writers
  static const String dolilWriters = '/dolil-writers';
  static String writerProfile(String userId) => '/dolil-writers/$userId';
  static String bookAppointment(String userId) => '/dolil-writers/$userId/appointments';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';

  // Dolils
  static const String dolils = '/dolils';
  static String dolil(int id) => '/dolils/$id';
  static String dolilActivities(int id) => '/dolils/$id/activities';

  // Payments
  static String payments(int dolilId) => '/dolils/$dolilId/payments';
  static String payment(int id) => '/payments/$id';

  // Comments
  static String comments(int dolilId) => '/dolils/$dolilId/comments';
  static String comment(int id) => '/comments/$id';

  // Reviews
  static String reviews(int dolilId) => '/dolils/$dolilId/reviews';
  static String review(int id) => '/reviews/$id';

  // Documents
  static String documents(int dolilId) => '/dolils/$dolilId/documents';
  static String document(int id) => '/documents/$id';
  static String documentDownload(int id) => '/documents/$id/download';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static String notificationMarkRead(int id) => '/notifications/$id/read';
  static String notificationsStream(String token) =>
      '/notifications/stream?token=${Uri.encodeComponent(token)}';

  // Appointments
  static const String appointments = '/appointments';
  static String appointment(int id) => '/appointments/$id';

  // Referrals
  static const String referrals = '/referrals';

  // Admin
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
  static String adminUser(int id) => '/admin/users/$id';
  static const String adminDolils = '/admin/dolils';
}

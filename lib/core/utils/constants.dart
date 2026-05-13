class AppConstants {
  // App Info
  static const String appName = 'App Skeleton';
  static const String appVersion = '1.0.0';

  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5);

  // Pagination
  static const int defaultPageSize = 20;

  // Debounce/Throttle durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration buttonThrottle = Duration(milliseconds: 500);

  // Cache durations
  static const Duration cacheDuration = Duration(hours: 24);

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
}

class AppRegex {
  static final email = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final phone = RegExp(r'^[\d\s\-\+\(\)]+$');
  static final password = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$');
}

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String settings = '/settings';
  static const String profile = '/profile';
}

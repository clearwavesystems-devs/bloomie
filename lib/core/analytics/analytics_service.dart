import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Router observer for automatic screen tracking
  late final observer = FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserId(String id) async {
    await _analytics.setUserId(id: id);
  }

  Future<void> setUserProperty({required String name, String? value}) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}

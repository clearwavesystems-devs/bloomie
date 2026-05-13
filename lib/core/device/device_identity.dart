import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentity {
  DeviceIdentity._();
  static const _prefsKey = 'device_id';

  static Future<String> get id async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_prefsKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_prefsKey, deviceId);
    }

    return deviceId;
  }
}

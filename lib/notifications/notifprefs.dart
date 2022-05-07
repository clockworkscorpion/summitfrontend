import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPreference {
  static const NOTIF_STATUS = "NOTIFICATIONSTATUS";

  setNotifStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(NOTIF_STATUS, value);
  }

  Future<bool> getNotifStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(NOTIF_STATUS) ?? true;
  }

}

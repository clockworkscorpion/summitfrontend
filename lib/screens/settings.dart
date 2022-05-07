import 'dart:io' show Platform;

import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fuji/screens/newsfeed.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:provider/provider.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:fuji/global.dart';
import 'package:fuji/theme/themedata.dart';
import 'package:fuji/theme/darkthemeprovider.dart';
import 'package:fuji/notifications/notifprefs.dart';

class SettingsDrawer extends StatefulWidget {
  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {

  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  final InAppReview _inAppReview = InAppReview.instance;
  String _appStoreId = '';

  String privacyURL =
      'https://docs.google.com/document/d/1n2mGANHzCznQ2zVhMnxZM7nEPfj7j0Nh2KBwex0iUSw/';
  String termsURL =
      'https://docs.google.com/document/d/1Rsytg4qtShrO_zQRviMMJfArBrSKtiudO3nySOvtyso/';
  String versiontext = '1.0.0';

  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  NotificationsPreference notifprefs = NotificationsPreference();
  bool _NotificationSwitch = true;

  bool get NotificationSwitch => _NotificationSwitch;
  FirebaseMessaging _fcm = FirebaseMessaging();

  set NotificationSwitch(bool value) {
    _NotificationSwitch = value;
    notifprefs.setNotifStatus(value);
  }

  void getCurrentNotifStatus() async {
    _NotificationSwitch = await notifprefs.getNotifStatus();
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentNotifStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    var localizationDelegate = LocalizedApp.of(context).delegate;
    var locale = localizationDelegate.currentLocale;
    var todayEn = DateFormat("EEEE, MMMM d, yyyy").format(DateTime.now());
    locale.toString() == 'ar' ? initializeDateFormatting("ar_SA", null) : null;
    var todayAr = DateFormat.yMMMd('ar_SA').format(DateTime.now());
    locale.toString() == 'ar' ? HijriCalendar.setLocal('ar') : HijriCalendar.setLocal('en');

    return Material(
        child: Theme(
          data: Styles.themeData(themeChangeProvider.darkTheme, context),
          child: ListView(
            children: [
              // CALENDAR
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 10.0 * normalizedHeight(context)),
                height: 40.0 * normalizedHeight(context),
                child: Text(
                  translate('navigation.settings'),
                  style: TextStyle(
                      fontSize: 18 * normalizedWidth(context)
                  ),
                ),
              ),

              //LANGUAGE
              // ListTile(
              //   leading: DescribedFeatureOverlay(
              //       featureId: 'language',
              //       tapTarget: Icon(LineIcons.language, color: Styles.navyBlue),
              //       backgroundColor: Styles.navyBlue,
              //       barrierDismissible: false,
              //       contentLocation: ContentLocation.below,
              //       overflowMode: OverflowMode.wrapBackground,
              //       title: Text(translate('tutorial.language')),
              //       description: Text(translate('tutorial.button')),
              //       child: Icon(LineIcons.language,
              //           size: 20.0 * normalizedHeight(context),
              //           color: Theme.of(context).primaryColor)),
              //   trailing: locale.toString() == 'ar'
              //       ? Icon(Icons.keyboard_arrow_left,
              //           size: 20.0 * normalizedHeight(context),
              //           color: Theme.of(context).primaryColor)
              //       : Icon(Icons.keyboard_arrow_right,
              //           size: 20.0 * normalizedHeight(context),
              //           color: Theme.of(context).primaryColor),
              //   title: Text(
              //     translate('settings.language'),
              //     style: TextStyle(color: Theme.of(context).primaryColor),
              //   ),
              //   onTap: () {
              //     languageActionSheet(context);
              //   },
              // ),

              ListTile(
                leading: DescribedFeatureOverlay(
                    featureId: 'category',
                    tapTarget: Icon(CupertinoIcons.collections_solid, color: Styles.navyBlue),
                    backgroundColor: Styles.navyBlue,
                    barrierDismissible: false,
                    contentLocation: ContentLocation.below,
                    overflowMode: OverflowMode.wrapBackground,
                    title: Text(translate('tutorial.category')),
                    description: Text(translate('tutorial.button')),
                    child: Icon(CupertinoIcons.collections_solid,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)),
                trailing: locale.toString() == 'ar'
                    ? Icon(Icons.keyboard_arrow_left,
                    size: 20.0 * normalizedHeight(context),
                    color: Theme.of(context).primaryColor)
                    : Icon(Icons.keyboard_arrow_right,
                    size: 20.0 * normalizedHeight(context),
                    color: Theme.of(context).primaryColor),
                title: Text(
                  translate('settings.category'),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onTap: () {
                  NewsPage.newspagekey.currentState.categoryActionSheet(context);
                },
              ),

              //NOTIFICATIONS
              ListTile(
                  leading: DescribedFeatureOverlay(
                      featureId: 'notifications',
                      tapTarget: Icon(Icons.notification_important, color: Styles.navyBlue),
                      backgroundColor: Styles.navyBlue,
                      barrierDismissible: false,
                      overflowMode: OverflowMode.wrapBackground,
                      contentLocation: ContentLocation.below,
                      title: Text(translate('tutorial.notifications')),
                      description: Text(translate('tutorial.button')),
                      child: Icon(Icons.notification_important,
                          color: Theme.of(context).primaryColor,
                          size: 20.0 * normalizedHeight(context))),
                  title: Text(
                    translate('settings.notifs'),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  trailing: Switch(
                      activeColor: Styles.tealColor,
                      value: NotificationSwitch,
                      onChanged: (bool value) {
                        setState(() {
                          NotificationSwitch = value;
                          switch (locale.toString()) {
                            case 'en':
                              value
                                  ? subscribeToEn()
                                  : unsubscribeAll();
                              break;
                            case 'ar':
                              value
                                  ? subscribeToAr()
                                  : unsubscribeAll();
                              break;
                          }
                        });
                      })
              ),

              ListTile(
                  leading: DescribedFeatureOverlay(
                      featureId: 'nightmode',
                      tapTarget: Icon(Icons.brightness_3, color: Styles.navyBlue),
                      backgroundColor: Styles.navyBlue,
                      barrierDismissible: false,
                      overflowMode: OverflowMode.wrapBackground,
                      contentLocation: ContentLocation.below,
                      title: Text(translate('tutorial.nightmode')),
                      description: Text(translate('tutorial.button')),
                      child: Icon(Icons.brightness_3,
                          size: 20.0 * normalizedHeight(context),
                          color: Theme.of(context).primaryColor)),
                  title: Text(translate('settings.nightmode'),
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  trailing: Switch(
//                          activeThumbImage: Icon(Icons.brightness_2),
//                          inactiveThumbImage: Icon(Icons.brightness_high),
                      activeColor: Styles.tealColor,
                      value: themeChange.darkTheme,
                      onChanged: (bool value) {
                        setState(() {
                          themeChange.darkTheme = value;
                        });
                      })),

              //SHARE THIS APP
              ListTile(
                leading: DescribedFeatureOverlay(
                    featureId: 'shareapp',
                    tapTarget: Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share, color: Styles.navyBlue),
                    backgroundColor: Styles.navyBlue,
                    barrierDismissible: false,
                    overflowMode: OverflowMode.wrapBackground,
                    title: Text(translate('tutorial.shareapp')),
                    description: Text(translate('tutorial.button')),
                    child: Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)),
                title: Text(translate('settings.shareapp'),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                trailing: locale.toString() == 'ar'
                    ? Icon(Icons.keyboard_arrow_left,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)
                    : Icon(Icons.keyboard_arrow_right,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor),
                onTap: () {
                  WcFlutterShare.share(
                      sharePopupTitle: translate('share.popuptitle'),
                      subject: translate('share.subject'),
                      text: translate('share.text'),
                      mimeType: 'text/plain');
                },
              ),

              //RATE THIS APP
              ListTile(
                leading: DescribedFeatureOverlay(
                    featureId: 'rateapp',
                    tapTarget: Icon(Icons.star, color: Styles.navyBlue),
                    backgroundColor: Styles.navyBlue,
                    barrierDismissible: false,
                    overflowMode: OverflowMode.wrapBackground,
                    title: Text(translate('tutorial.rateapp')),
                    description: Text(translate('tutorial.button')),
                    child: Icon(Icons.star,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)),
                title: Text(translate('settings.rateapp'),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                trailing: locale.toString() == 'ar'
                    ? Icon(Icons.keyboard_arrow_left,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)
                    : Icon(Icons.keyboard_arrow_right,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor),
                onTap: () {
                  _openStoreListing();
                },
              ),

              //SEND FEEDBACK
              ListTile(
                leading: DescribedFeatureOverlay(
                    featureId: 'feedback',
                    tapTarget: Icon(Icons.send, color: Styles.navyBlue),
                    backgroundColor: Styles.navyBlue,
                    barrierDismissible: false,
                    overflowMode: OverflowMode.wrapBackground,
                    title: Text(translate('tutorial.feedback')),
                    description: Text(translate('tutorial.button')),
                    child: Icon(Icons.send,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)),
                title: Text(translate('settings.feedback'),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                trailing: locale.toString() == 'ar'
                    ? Icon(Icons.keyboard_arrow_left,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)
                    : Icon(Icons.keyboard_arrow_right,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor),
                onTap: () async {
                  FeedbackEmail();
                },
              ),

              //TERMS AND CONDITIONS
              ListTile(
                leading: Icon(Icons.note,
                    size: 20.0 * normalizedHeight(context),
                    color: Theme.of(context).primaryColor),
                title: Text(translate('settings.tandc'),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                trailing: locale.toString() == 'ar'
                    ? Icon(Icons.keyboard_arrow_left,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)
                    : Icon(Icons.keyboard_arrow_right,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor),
                onTap: () async {
                  await browser.open(
                      url: termsURL,
                      options: ChromeSafariBrowserClassOptions(
                          android: AndroidChromeCustomTabsOptions(
                              addDefaultShareMenuItem: false),
                          ios: IOSSafariOptions(
                              barCollapsingEnabled: true)));
                },
              ),

              //PRIVACY POLICY
              ListTile(
                leading: Icon(Icons.lock,
                    size: 20.0 * normalizedHeight(context),
                    color: Theme.of(context).primaryColor),
                title: Text(translate('settings.privacy'),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                trailing: locale.toString() == 'ar'
                    ? Icon(Icons.keyboard_arrow_left,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)
                    : Icon(Icons.keyboard_arrow_right,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor),
                onTap: () async {
                  await browser.open(
                      url: privacyURL,
                      options: ChromeSafariBrowserClassOptions(
                          android: AndroidChromeCustomTabsOptions(
                              addDefaultShareMenuItem: false),
                          ios: IOSSafariOptions(
                              barCollapsingEnabled: true)));
                },
              ),

              //ABOUT
              ListTile(
                leading: Icon(Icons.help,
                    size: 20.0 * normalizedHeight(context),
                    color: Theme.of(context).primaryColor),
                title: Text(translate('settings.about'),
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                trailing: locale.toString() == 'ar'
                    ? Icon(Icons.keyboard_arrow_left,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor)
                    : Icon(Icons.keyboard_arrow_right,
                        size: 20.0 * normalizedHeight(context),
                        color: Theme.of(context).primaryColor),
                onTap: () {
                  showAboutDialog(
                      context: context,
                      applicationName: translate('settings.appname'),
                      applicationVersion: versiontext,
                      applicationIcon: SizedBox(
                          height: 50.0 * normalizedHeight(context),
                          width: 50.0 * normalizedWidth(context),
                          child: locale.toString() == 'ar' ?
                          Image.asset('assets/icon/ar_icon.png') : Image.asset('assets/icon/en_icon.png')),
                      applicationLegalese: translate('settings.legal'),
                      children: [
                        Text(translate('settings.imagecredits')),
                        Text('- Africa: @redcharlie on Unsplash', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Americas: @martinjernberg on Unsplash', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- East Asia: Sean Pavone on Alamy', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Automotive: @mibro on Pixabay', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Bollywood: DearCinema via Wayback Machine', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Business: Johannes Eisele(AFP) on Getty Images', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Cricket: @rc820 on Unsplash', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Entertainment: Freepik', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Europe: @edouard_grillot on Unsplash', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Football: @chancema on Unsplash', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- GCC: Freepik', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Health: Freepik', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Hollywood: @jakeblucker on Unsplash', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- India: @mazzzur on DepositPhotos', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- MidEast: Freepik', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Pakistan: Imran Ahmed on Alamy', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Philippines: @alanaharris on Unsplash', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Science & Technology: Alex Knight', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Sports: SuperBowl', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- Startups: Freepik', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                        Text('- UAE: @zoltantasi on Unsplash', style: TextStyle(fontSize: 10.0 * normalizedWidth(context), color: Colors.grey)),
                      ]
                  );
                },
              ),
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Text(
                      locale.toString() == 'ar' ? todayAr : todayEn,
                      style: TextStyle(
                        fontSize: 11.0 * normalizedWidth(context),
                      ),
                    ),
                    Text(
                      HijriCalendar.now().toFormat("MMMM dd , yyyy"),
                      style: TextStyle(
                        fontSize: 11.0 * normalizedWidth(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  //EMAIL FEEDBACK FUNCTIONS
  Future<void> FeedbackEmail() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> _deviceData = <String, dynamic>{};

    Map<String, dynamic> deviceData;
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
      String sys_id = Platform.isIOS
          ? deviceData['systemVersion']
          : deviceData['androidId'];
      String sys_vers = Platform.isIOS
          ? deviceData['systemVersion']
          : deviceData['version.release'];
      String manufacturer =
          Platform.isIOS ? 'APPLE' : deviceData['manufacturer'];
      String model = Platform.isIOS ? 'iOS13' : deviceData['model'];
      String display = Platform.isIOS ? '' : deviceData['display'];
      final Email email = Email(
          body:
              'System ID: $sys_id\nSystem Version: $sys_vers\nManufacturer: $manufacturer\nModel: $model\nDisplay: $display\n-----PLEASE DO NOT EDIT ANY DATA ABOVE THIS LINE SO THAT WE MAY SERVE YOU BETTER-----\n',
          subject: DateTime.now().toString() + ': Feedback for Nawa App',
          recipients: ['nawafeedback@gmail.com'],
          isHTML: false);
      await FlutterEmailSender.send(email);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;
    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  // LANGUAGE SELECTION MENU
  void languageActionSheet(BuildContext context) {
    PlatformActionSheet().displaySheet(
      context: context,
      title:
          Platform.isIOS ? Text(translate('language.selection.title')) : null,
      message:
          Platform.isIOS ? Text(translate('language.selection.message')) : null,
      actions: [
        ActionSheetAction(
            text: 'English',
            onPressed: () {
              changeLocale(context, 'en');
              Navigator.pop(context, 'en');
              NotificationSwitch ? subscribeToEn() : null;
            }),
        ActionSheetAction(
            text: 'العربية (في مرحلة تجريبية)',
            onPressed: () {
              changeLocale(context, 'ar');
              Navigator.pop(context, 'ar');
              NotificationSwitch ? subscribeToAr() : null;
            }),
      ],
    );
  }

  Future<void> _openStoreListing() =>
      _inAppReview.openStoreListing(appStoreId: _appStoreId);

  subscribeToEn() {
    _fcm.unsubscribeFromTopic('ar');
    _fcm.subscribeToTopic('en');
  }

  subscribeToAr() {
    _fcm.unsubscribeFromTopic('en');
    _fcm.subscribeToTopic('ar');
  }

  unsubscribeAll() {
    _fcm.unsubscribeFromTopic('en');
    _fcm.unsubscribeFromTopic('ar');
  }
}

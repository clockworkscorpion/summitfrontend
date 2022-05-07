import 'dart:io' show Platform;

import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_translate_preferences/flutter_translate_preferences.dart';
import 'package:fuji/screens/newsfeed.dart';
import 'package:fuji/widgets/innerdrawer.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'package:fuji/theme/darkthemeprovider.dart';
import 'package:fuji/theme/themedata.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeDilation = 1.0;
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en',
      supportedLocales: ['en','ar'],
      preferences: TranslatePreferences()
  );
  await Firebase.initializeApp();
  runApp(LocalizedApp(delegate, MainApp()));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  _configureFirebaseListeners(){
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {   //IN FOREGROUND
        print("onMessage: $message");
        if (Platform.isAndroid) {
          showSimpleNotification(
              Container(child: Column(
                children: [
                  Text(message['notification']['title']),
                  Text(message['notification']['body']),
                ],
              )),
              position: NotificationPosition.top,
              background: Colors.teal
          );
        }
        if (Platform.isIOS) {
          showSimpleNotification(
              Container(child: Text(message['aps']['alert']['body'])),
              position: NotificationPosition.top,
              background: Colors.teal
          );
        }
        NewsPage.newspagekey.currentState.fetchLatestNews();
      },
      onLaunch: (Map<String, dynamic> message) async{     // NOT OPENED
        print ('onLaunch: $message');
        NewsPage.newspagekey.currentState.fetchLatestNews();
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainApp()));
      },
      onResume: (Map<String, dynamic> message) async{     // IN BACKGROUND
        print ('onResume: $message');
        NewsPage.newspagekey.currentState.fetchLatestNews();
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainApp()));
      },
    );
  }

  @override
  void initState() {
    // TODO implement initState
    super.initState();
    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
        sound: true, badge: true, alert: true
      ));
      _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
        _configureFirebaseListeners();
        print ("Settings registered: $settings");
      });
      /*StreamSubscription iosSubscription = _firebaseMessaging.onIosSettingsRegistered.listen((data) {
      });*/
    }
    if (Platform.isAndroid) {
      _configureFirebaseListeners();
    }
    getCurrentAppTheme();
  }


  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
    await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return ChangeNotifierProvider(
      create: (_)
      {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return LocalizationProvider(
            state: LocalizationProvider.of(context).state,
            child: MaterialApp(
              title: 'Summit',
              debugShowCheckedModeBanner: false,
              navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics),],
              supportedLocales: localizationDelegate.supportedLocales,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                localizationDelegate
              ],
              locale: localizationDelegate.currentLocale,
              theme: Styles.themeData(themeChangeProvider.darkTheme,context),
              home: FeatureDiscovery(
                  child: SlideDrawer()
              ),
            ),
          );
        },
      )
    );
  }
}
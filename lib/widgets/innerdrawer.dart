import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fuji/global.dart';
import 'package:fuji/screens/newsfeed.dart';
import 'package:fuji/screens/settings.dart';
import 'package:fuji/theme/themedata.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SlideDrawer extends StatefulWidget {
  SlideDrawer({Key key}) : super(key: key);

  @override
  _SlideDrawerState createState() => _SlideDrawerState();
}

class _SlideDrawerState extends State<SlideDrawer> {
  final GlobalKey<InnerDrawerState> _innerDrawerKey = GlobalKey<InnerDrawerState>();

  final InAppReview _inAppReview = InAppReview.instance;   bool _isAvailable;
  bool _swipe = true;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.quadratic;
  bool _proportionalChildArea = true;
  double _scale = 0.8;
  double _borderRadius = 50;

  @override
  void initState() {
    super.initState();
    inAppRating();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Platform.isIOS) {
        _inAppReview.isAvailable().then((bool isAvailable) {
          setState(() {
            _isAvailable = isAvailable;
          });
        });
      } else {
        setState(() {
          _isAvailable = false;
        });
      }
    });
    startTime();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    String lang = localizationDelegate.currentLocale.toString();
    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: true,
      offset: IDOffset.only(
//          top: _topBottom ? _verticalOffset : 0.0,
//          bottom: !_topBottom ? _verticalOffset : 0.0,
          right: 0.75,
          left: 0.75),
      scale: IDOffset.horizontal(_scale),
      borderRadius: _borderRadius,
      duration: Duration(milliseconds: 1200),
      swipe: _swipe,
      proportionalChildArea: _proportionalChildArea,
      //backgroundColor: Colors.red,
      colorTransitionChild: Colors.black54,
      leftAnimationType: _animationType,
      rightAnimationType: _animationType,
      leftChild: DescribedFeatureOverlay(
          featureId: 'endtut',
          tapTarget: Icon(LineIcons.smile_o, color: Styles.navyBlue),
          backgroundColor: Styles.navyBlue,
          overflowMode: OverflowMode.wrapBackground,
          barrierDismissible: false,
          onComplete: () async{
            _innerDrawerKey.currentState.toggle();
            return true;
          },
          title: Text(translate('tutorial.endtut')),
          description: Text(translate('tutorial.button')),
          child: SettingsDrawer()),
      scaffold: DescribedFeatureOverlay(
          featureId: 'swipetosettings',
          tapTarget: Icon(Icons.settings, color: Styles.navyBlue),
          backgroundColor: Styles.navyBlue,
          barrierDismissible: false,
          overflowMode: OverflowMode.wrapBackground,
          onComplete: () async{
            _innerDrawerKey.currentState.toggle();
            return true;
          },
          title: Text(translate('tutorial.swipetosettings')),
          description: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(translate('tutorial.button')),
              SizedBox(
                  width: 86.0 * normalizedWidth(context),
                  height: 106.0 * normalizedHeight(context),
                  child: FittedBox(
                    child: lang == 'en'
                        ? Image.asset('assets/tutorial/swipe_right.png')
                        : Image.asset('assets/tutorial/swipe_left.png'),
                  )
              )
            ],
          ),
          child: NewsPage(),
      )
    );
  }
  // INITIAL LANGUAGE SELECTION SHEET
  startTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('first_time');
    if (firstTime != null && !firstTime) {
      // Not first time
      return;
    } else {
      // First time
      prefs.setBool('first_time', false);
/*      _fcm.getToken().then((deviceToken){
        FirebaseFirestore.instance.collection('DeviceTokens').add({
          'createdAt': DateTime.now(),
          'platform' : Platform.isIOS ? 'iOS' : 'Android',
          'token': deviceToken
        });
      });*/
      //Future.delayed(Duration(milliseconds: 1000), () => _onActionSheetPress(context));
      changeLocale(context, 'en');
      subscribeToEn();
      discovery();
    }
  }

  //IN APP RATING
  inAppRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int launchCount = prefs.getInt('launch_count') ?? 0;
    bool ratedTag = prefs.getBool('rated_tag') ?? false;
    launchCount = launchCount == 0 ? 1 : launchCount + 1;
    prefs.setInt('launch_count', launchCount);
    if (((launchCount == 3) || (launchCount == 6) || (launchCount == 10)) && (ratedTag = false)) {
      Future.delayed(Duration(seconds: 60), () => _requestReview());
      ratedTag = true;
      prefs.setBool('rated_tag', ratedTag);
    } else return;
  }

  //IN APP REVIEW
  Future<void> _requestReview() => _inAppReview.requestReview();


/*  _onActionSheetPress(BuildContext context) async {
    PlatformActionSheet().displaySheet(
        context: context,
        title:
        Platform.isIOS ? Text(translate('language.selection.title')) : null,
        message: Platform.isIOS
            ? Text(translate('language.selection.message'))
            : null,
        actions: [
          ActionSheetAction(
              text: 'English',
              onPressed: () async {
                Navigator.pop(context, 'en');
                changeLocale(context, 'en');
                discovery();
                subscribeToEn();
              }),
          ActionSheetAction(
              text: 'العربية (في مرحلة تجريبية)',
              onPressed: () async {
                Navigator.pop(context, 'ar');
                changeLocale(context, 'ar');
                discovery();
                subscribeToAr();
              }),
        ]);
  }*/

  // TUTORIAL
  discovery() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{
          'swipeup',
          'shareicon',
          'webicon',
          'refreshicon',
          'swipetosettings',
          // 'language',
          'category',
          'notifications',
          'nightmode',
          'shareapp',
          'rateapp',
          'feedback',
          'endtut'
        },
      );
    });
  }

  FirebaseMessaging _fcm = FirebaseMessaging();
  subscribeToEn() {
    _fcm.unsubscribeFromTopic('ar');
    _fcm.subscribeToTopic('en');
  }

  subscribeToAr() {
    _fcm.unsubscribeFromTopic('en');
    _fcm.subscribeToTopic('ar');
  }

}
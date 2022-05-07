import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fuji/global.dart';

import 'package:fuji/screens/newsfeed.dart';
import 'package:fuji/screens/settings.dart';
import 'package:fuji/theme/themedata.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({Key key, this.child}) : super(key: key);

  static HomeScreenState of(BuildContext context) =>
      context.findAncestorStateOfType<HomeScreenState>();

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  final InAppReview _inAppReview = InAppReview.instance;   bool _isAvailable;

  AnimationController animationController;
  bool _canBeDragged = false;

  @override
  void initState() {
    super.initState();
    inAppRating();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
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
    animationController.dispose();
    super.dispose();
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  @override
  Widget build(BuildContext context) {

    final double maxSlide = 360.0 * normalizedWidth(context);

    return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
        child: GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          behavior: HitTestBehavior.translucent,
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, _) {
              return Material(
                child: Stack(
                  children: <Widget>[
                    Transform.translate(
                      offset: Offset(maxSlide * (animationController.value - 1), 0),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(math.pi / 2 * (1 - animationController.value)),
                        alignment: Alignment.centerRight,
                        child: DescribedFeatureOverlay(
                            featureId: 'endtut',
                            tapTarget: Icon(LineIcons.smile_o, color: Styles.navyBlue),
                            backgroundColor: Styles.navyBlue,
                            overflowMode: OverflowMode.wrapBackground,
                            barrierDismissible: false,
                            onComplete: () async{
                              toggle();
                              return true;
                            },
                            title: Text(translate('tutorial.endtut')),
                            description: Text(translate('tutorial.button')),
                            child: SettingsDrawer()),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(maxSlide * animationController.value, 0),
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(-math.pi / 2 * animationController.value),
                        alignment: Alignment.centerLeft,
                        child: DescribedFeatureOverlay(
                            featureId: 'swipetosettings',
                            tapTarget: Icon(Icons.settings, color: Styles.navyBlue),
                            backgroundColor: Styles.navyBlue,
                            barrierDismissible: false,
                            overflowMode: OverflowMode.wrapBackground,
                            onComplete: () async{
                              toggle();
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
                                      child: Image.asset('assets/tutorial/swipe_right.png'),
                                    )
                                )
                              ],
                            ),
                            child: NewsPage()),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      )
    );
  }

  // ANIMATION CONTROLLER CONTROLS
  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed;
    bool isDragCloseFromRight = animationController.isCompleted;
    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final double maxSlide = screenWidth(context);
    if (_canBeDragged) {
      double delta = details.primaryDelta / maxSlide;
      animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    //I have no idea what it means, copied from Drawer
    double _kMinFlingVelocity = 365.0;

    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      animationController.reverse();
    } else {
      animationController.forward();
    }
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
/*      prefs.setBool('first_time', false);
      _fcm.getToken().then((deviceToken){
        FirebaseFirestore.instance.collection('DeviceTokens').add({
          'createdAt': DateTime.now(),
          'platform' : Platform.isIOS ? 'iOS' : 'Android',
          'token': deviceToken
        });
      });*/
      //Future.delayed(Duration(milliseconds: 1000), () => _onActionSheetPress(context));
      changeLocale(context, 'en');
      discovery();
      subscribeToEn();
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


/*
  _onActionSheetPress(BuildContext context) async {
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
  }
*/

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
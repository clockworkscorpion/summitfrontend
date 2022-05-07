import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bordered_text/bordered_text.dart';
import 'package:circular_check_box/circular_check_box.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fuji/categoryselection/categories.dart';
import 'package:fuji/categoryselection/categoryprefs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:postgrest/postgrest.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:clippy_flutter/diagonal.dart';
import 'package:http/http.dart' as http;
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:fuji/global.dart';
import 'package:fuji/theme/darkthemeprovider.dart';
import 'package:fuji/theme/themedata.dart';
import 'package:fuji/models/newsclass.dart';

class NewsPage extends StatefulWidget {
  static final GlobalKey<_NewsPageState> newspagekey = GlobalKey<_NewsPageState>();
  NewsPage({Key key}) : super(key: newspagekey);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();
  final ChromeSafariBrowser browser = ChromeSafariBrowser();

  List<String> _userCategories = [];
  CategoriesPreference categoriesPreference = CategoriesPreference();
  List<bool> CategorySwitch = List<bool>.filled(categories.length, false);

  List<String> get userCategories => _userCategories;

  getUserCategories() async {
    _userCategories = await categoriesPreference.getUserCategories();
  }

  addUserCategory(String value) {
    if (!_userCategories.contains(value)) {
      _userCategories.add(value);
    }
    categoriesPreference.storeCategoryList(_userCategories);
  }

  removeUserCategory(String value) {
    if (_userCategories.contains(value)) {
      _userCategories.remove(value);
    }
    categoriesPreference.storeCategoryList(_userCategories);
  }

  File _imageFile;
  ScreenshotController screenshotController = ScreenshotController();
  int index = 0;
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  List<dynamic> displayList =
      []; // list that will be displayed based on user categories
  List<dynamic> masterList = []; // list that will store API-retrieved data
  String translateUrl;

  bool _loadingNews = true;
  bool _gettingmoreNews = false;
  bool _moreNewsAvailable = true;
  String functionTag;
  String bookmark;
  AnimationController animationController;

  // INITIAL NEWS RETRIEVAL
  fetchLatestNews() async {
    List<News> _newslist = [];
    setState(() {
      _loadingNews = true;
    });
    functionTag = "initNews";
    var url = 'https://vntkzwyetgdgqyvjfgcz.supabase.co';
    var client = PostgrestClient(url);
    // final response_news = await http.get(
    //     'https://summit-newsdb.europe-west1.firebasedatabase.app/news_EN.json?orderBy="t"&limitToLast=11');
    final response_news = await client.from('news').select().execute();
    print('Data:' + response_news.data);
    Map map = json.decode(response_news.data);
//    if (map.length <= 11) {
//      _moreNewsAvailable = false;
//    }
    masterList.clear();
    index = 0;
    map.forEach((newsID, newsData) {
      _newslist.add(News.fromJson(newsData));
    });
    print('Fetched Initial News');
    _newslist
        .sort((a, b) => b.timestamp.compareTo(a.timestamp)); //sortdescending
    bookmark = (_newslist[_newslist.length - 1].timestamp).toString();
    _newslist.removeLast(); // because Realtime DB does not have startAfter parameter
    masterList.addAll(_newslist);
    organizeNews();
  }

  // MORE NEWS RETRIEVAL
  fetchMoreNews() async {
    List<News> _newslist = [];
//    if (_moreNewsAvailable == false) {
//      print('No more News');
//    }
    if (_gettingmoreNews == true) {
      print("More News");
      return;
    }
    functionTag = "moreNews";
    _gettingmoreNews = true;
    final response = await http.get(
        'https://summit-newsdb.europe-west1.firebasedatabase.app/news_EN.json?orderBy="t"&limitToLast=11&endAt=' +
            bookmark);
    Map map = json.decode(response.body);
//    if (map.length <= 11) {
//      _moreNewsAvailable = false;
//    }
    map.forEach((newsID, newsData) {
      _newslist.add(News.fromJson(newsData));
    });
    print('Fetched More News');
    _newslist
        .sort((a, b) => b.timestamp.compareTo(a.timestamp)); //sortdescending
    bookmark = (_newslist[_newslist.length - 1].timestamp).toString();
    _newslist.removeLast(); // because Realtime DB does not have startAfter parameter
    masterList.addAll(_newslist);
    organizeNews();
  }

  organizeNews() {
    /*setState(() {
      _loadingNews = true;
    });*/
    displayList = [];
    displayList.addAll(masterList);
    displayList.retainWhere(
        (x) => (userCategories.contains(x.category) || x.score.contains('n')));
    switch (functionTag) {
      case "initNews":
        {
          setState(() {
            _loadingNews = false;
          });
          break;
        }
      case "moreNews":
        {
          _gettingmoreNews = false;
          break;
        }
      default:
        {
          setState(() {
            _loadingNews = false;
          });
          break;
        }
    }
  }

  @override
  void initState() {
    getUserCategories();
    // TODO: implement initState
    super.initState();
    fetchLatestNews();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    String lang = localizationDelegate.currentLocale.toString();
    return _loadingNews == true
        ? Container(
            color: Colors.black,
            child: Center(
              child:
                  CircularProgressIndicator(backgroundColor: Styles.navyBlue),
            ),
          )
        : displayList.length == 0
            ? Center(
                child: Text("No articles to show"),
              )
            : Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Scaffold(
                  floatingActionButtonLocation: lang == 'ar'
                      ? FloatingActionButtonLocation.startDocked
                      : FloatingActionButtonLocation.endDocked,
                  floatingActionButton: FabCircularMenu(
                      alignment: lang == 'ar'
                          ? Alignment.bottomLeft
                          : Alignment.bottomRight,
                      key: fabKey,
                      ringColor: Styles.tealColor,
                      ringDiameter: 240.0 * normalizedWidth(context),
                      ringWidth: 60.0 * normalizedWidth(context),
                      fabSize: 64.0 * normalizedWidth(context),
                      fabElevation: 2.0,
                      fabColor: Styles.tealColor,
                      fabOpenColor: Styles.blackColor,
                      fabOpenIcon: Icon(LineIcons.newspaper_o, color: Colors.white),
                      fabCloseIcon: Icon(Icons.close, color: Styles.tealColor),
                      fabMargin: lang =='en'
                          ? EdgeInsets.only(right: 20.0 * normalizedWidth(context), bottom: 30.0 * normalizedWidth(context))
                          : EdgeInsets.only(left: 20.0 * normalizedWidth(context), bottom: 30.0 * normalizedWidth(context)),
                      animationCurve: Curves.easeInOutCirc,
                      animationDuration: const Duration(milliseconds: 500),
                      children: <Widget>[
                        //REFRESH ICON
                        DescribedFeatureOverlay(
                          featureId: 'refreshicon',
                          tapTarget:
                          Icon(LineIcons.refresh, color: Styles.navyBlue),
                          contentLocation: ContentLocation.above,
                          overflowMode: OverflowMode.wrapBackground,
                          backgroundColor: Styles.navyBlue,
                          barrierDismissible: false,
                          title: Text(translate('tutorial.refresh')),
                          description: Text(translate('tutorial.button')),
                          child: RawMaterialButton(
                              shape: CircleBorder(),
                              padding: const EdgeInsets.all(24.0),
                              onPressed: () async {
                                fetchLatestNews();
                              },
                              child: Icon(LineIcons.refresh,
                                  color: Colors.white, size: 24.0)),
                          onComplete: () async {
                            fabKey.currentState.close();
                            return true;
                          },
                        ),

                        //WEB BUTTON
                        DescribedFeatureOverlay(
                          featureId: 'webicon',
                          tapTarget:
                              Icon(LineIcons.globe, color: Styles.navyBlue),
                          backgroundColor: Styles.navyBlue,
                          overflowMode: OverflowMode.wrapBackground,
                          contentLocation: ContentLocation.above,
                          barrierDismissible: false,
                          title: Text(translate('tutorial.web')),
                          description: Text(translate('tutorial.button')),
                          child: RawMaterialButton(
                              shape: CircleBorder(),
                              padding: const EdgeInsets.all(24.0),
                              onPressed: () {
                                /*lang == 'ar'
                              // ignore: unnecessary_statements
                              ? {
                                  translateUrl =
                                      'https://translate.google.com/translate?sl=en&tl=ar&u=' +
                                          displayList[index]
                                              .url
                                              .replaceAll(':', '%3A')
                                              .replaceAll('/', '%2F'),
                                  Navigator.push(
                                      context,
                                   MaterialPageRoute(
                                          builder: (context) =>
                                              WebViewScreen(
                                                  translateUrl)))
                                }
                              :*/
                                Future.delayed(Duration (milliseconds: 250), () async {
                                  await browser.open(
                                      url: displayList[index].url,
                                      options: ChromeSafariBrowserClassOptions(
                                          android: AndroidChromeCustomTabsOptions(
                                              addDefaultShareMenuItem: false),
                                          ios: IOSSafariOptions(
                                              barCollapsingEnabled: true)));
                                });
                              },
                              child: Icon(LineIcons.globe,
                                  color: Colors.white, size: 24.0)),
                        ),

                        //SHARE BUTTON
                        DescribedFeatureOverlay(
                          featureId: 'shareicon',
                          tapTarget: Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share, color: Styles.navyBlue),
                          backgroundColor: Styles.navyBlue,
                          overflowMode: OverflowMode.wrapBackground,
                          contentLocation: ContentLocation.above,
                          barrierDismissible: false,
                          title: Text(translate('tutorial.share')),
                          description: Text(translate('tutorial.button')),
                          child: RawMaterialButton(
                            shape: CircleBorder(),
                            padding: const EdgeInsets.all(24.0),
                            child: Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share,
                                color: Colors.white, size: 24.0),
                            onPressed: () async {
                              Future.delayed(
                                  Duration(milliseconds: 1000),
                                  () => _takeScreenshotandShare(
                                      displayList[index].url));
                            },
                          ),
                        ),
                      ]),
                  body: Screenshot(
                    controller: screenshotController,
                    child: Consumer<DarkThemeProvider>(
                        builder: (BuildContext context, value, Widget child) {
                      return Scaffold(
                        body: Theme(
                            data: Styles.themeData(
                                themeChangeProvider.darkTheme, context),
                            child: PageView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: displayList.length,
                                scrollDirection: Axis.vertical,
                                allowImplicitScrolling: true,
                                pageSnapping: true,
                                itemBuilder: (context, position) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Stack(children: <Widget>[
                                      // SOURCE IMAGE
                                      DescribedFeatureOverlay(
                                        featureId: 'swipeup',
                                        tapTarget: Icon(LineIcons.newspaper_o,
                                            color: Styles.navyBlue),
                                        backgroundColor: Styles.navyBlue,
                                        barrierDismissible: false,
                                        contentLocation: ContentLocation.below,
                                        overflowMode:
                                            OverflowMode.wrapBackground,
                                        title:
                                            Text(translate('tutorial.swipeup')),
                                        description: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(translate(
                                                'tutorial.swipeup_desc')),
                                            SizedBox(
                                                width: 86.0 *
                                                    normalizedWidth(context),
                                                height: 106.0 *
                                                    normalizedHeight(context),
                                                child: FittedBox(
                                                  child: Image.asset(
                                                      'assets/tutorial/swipe_up.png'),
                                                ))
                                          ],
                                        ),
                                        onComplete: () async {
                                          fabKey.currentState.open();
                                          return true;
                                        },
                                        child: Diagonal(
                                          position: lang == 'en'
                                              ? DiagonalPosition.BOTTOM_RIGHT
                                              : DiagonalPosition.BOTTOM_LEFT,
                                          clipHeight:
                                              50 * normalizedHeight(context),
                                          child: Container(
                                            color: Styles.tealColor,
                                            height:
                                                300 * normalizedHeight(context),
                                            child: Image.network(
                                                displayList[position].img,
                                                fit: BoxFit.fill),
                                          ),
                                        ),
                                      ),

                                      //CATEGORY
                                      Positioned(
                                        left: lang == 'en'
                                            ? 5.0 * normalizedWidth(context)
                                            : 0,
                                        right: lang == 'en'
                                            ? 0
                                            : 5.0 * normalizedWidth(context),
                                        top: 265.0 * normalizedHeight(context),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              8.0 * normalizedHeight(context)),
                                          child: Text(
                                            translate(
                                                'category.${displayList[position].category}'),
                                            style: TextStyle(
                                              color: Styles.tealColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0 *
                                                  normalizedWidth(context),
                                            ),
                                          ),
                                        ),
                                      ),

                                      //TITLE, TIME, SOURCE, TEXT
                                      Positioned(
                                        left: 5 * normalizedWidth(context),
                                        top: 300 * normalizedHeight(context),
                                        child: Center(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(2.0),
                                                child: Container(
                                                  width: 320 *
                                                      normalizedWidth(context),
                                                  child: Text(
                                                    titleOutput(
                                                        displayList[position]),
                                                    style: TextStyle(
                                                        fontSize: 20.0 *
                                                            normalizedWidth(
                                                                context),
                                                        height: 1.5 *
                                                            normalizedHeight(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                ),
                                              ),

                                              //TIME AND SOURCE
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                    child: Text(
                                                      '${timeagoOutput(displayList[position])} | ${sourceOutput(displayList[position])}',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12.0 *
                                                              normalizedWidth(
                                                                  context),
                                                          fontWeight:
                                                              FontWeight.w300),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              //TEXT
                                              Padding(
                                                padding: EdgeInsets.all(8.0 *
                                                    normalizedHeight(context)),
                                                child: Container(
                                                  width: 320 *
                                                      normalizedWidth(context),
                                                  child: Stack(
                                                    children: [
                                                      Center(
                                                        child: Text('A', style: TextStyle(
                                                          color: Colors.grey.withOpacity(0.2),
                                                            fontFamily: 'FinalFrontier',
                                                              fontSize: 300.0 * normalizedWidth(context)
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        textOutput(
                                                            displayList[position]),
                                                        style: TextStyle(
                                                            fontSize: 18 *
                                                                normalizedWidth(
                                                                    context),
                                                            height: 1.3 *
                                                                normalizedHeight(
                                                                    context)),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      //LOGO
/*                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                            height: lang == 'en' ? 19.6 * normalizedHeight(context) : 29.2 * 0.70 * normalizedHeight(context),
                                            width: lang == 'en' ? 62 * normalizedWidth(context) : 57.2 * 0.70 * normalizedWidth(context),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image:
                                                )
                                            )
                                        ),
                                      )*/
                                    ]),
                                  );
                                },
                                onPageChanged: (position) {
                                  setState(() {
                                    index = position;
                                    if (position == displayList.length - 3) {
                                      fetchMoreNews();
                                    }
                                  });
                                })),
                      );
                    }),
                  ),
                ),
            );
  }

  //SCREENSHOT
  _takeScreenshotandShare(String url) async {
    _imageFile = null;
    screenshotController
        .capture(delay: Duration(milliseconds: 5), pixelRatio: 2.0)
        .then((File image) async {
      setState(() {
        _imageFile = image;
      });
      final directory = (await getApplicationDocumentsDirectory()).path;
      Uint8List pngBytes = _imageFile.readAsBytesSync();
      File imgFile = new File('$directory/nawa_screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      await WcFlutterShare.share(
          sharePopupTitle: translate('share.popuptitle'),
          subject: translate('share.subject'),
          text: translate('share.text') + '\n\n$url',
          fileName: 'nawa_screenshot_${DateTime.now().toIso8601String()}.png',
          mimeType: 'image/png',
          bytesOfFile: pngBytes.buffer.asUint8List());
    }).catchError((onError) {
      print(onError);
    });
  }

  String titleOutput(News news) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    String lang = localizationDelegate.currentLocale.toString();
    String title;
    switch (lang) {
      case 'en':
        title = news.title_en;
        break;
      case 'ar':
        title = news.title_ar;
        break;
    }
    return title;
  }

  String textOutput(News news) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    String lang = localizationDelegate.currentLocale.toString();
    String text;
    switch (lang) {
      case 'en':
        text = news.text_en;
        break;
      case 'ar':
        text = news.text_ar;
        break;
    }
    return text;
  }

  String sourceOutput(News news) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    String lang = localizationDelegate.currentLocale.toString();
    String source;
    switch (lang) {
      case 'en':
        source = news.src_en;
        break;
      case 'ar':
        source = news.src_ar;
        break;
    }
    return source;
  }

  String timeagoOutput(News news) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    String lang = localizationDelegate.currentLocale.toString();
    String time;
    switch (lang) {
      case 'en':
        time = timeago.format(
            DateTime.fromMillisecondsSinceEpoch(news.timestamp * 1000),
            locale: 'en');
        break;
      case 'ar':
        timeago.setLocaleMessages('ar', timeago.ArMessages());
        time = timeago.format(
            DateTime.fromMillisecondsSinceEpoch(news.timestamp * 1000),
            locale: 'ar');
        break;
    }
    return time;
  }

  void categoryActionSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (context) => Container(
        //color: Styles.navyBlue,
        padding: EdgeInsets.only(top: 20.0 * normalizedHeight(context)),
        height: 600 * normalizedHeight(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0 * normalizedWidth(context)),
        ),
        child: Column(
          children: [
            ListTile(
              title: Align(
                  alignment: Alignment.center,
                  child: Text(translate('category.tapcategories'))),
              trailing: FlatButton(
                color: Styles.tealColor,
                textColor: Styles.whiteColor,
                onPressed: () {
                  Navigator.pop(context);
                  organizeNews();
                },
                child: Text(translate('category.Done')),
              ),
            ),
            Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (BuildContext context, int gridindex) {
                    userCategories.contains(categories[gridindex].code)
                        ? CategorySwitch[gridindex] = true
                        : CategorySwitch[gridindex] = false;
                    return Padding(
                      padding: EdgeInsets.all(5.0 * normalizedHeight(context)),
                      child: GridTile(
                        child: StatefulBuilder(
                          builder: (BuildContext context, setState) =>
                              GestureDetector(
                            onTap: () => setState(() {
                              CategorySwitch[gridindex] =
                                  !CategorySwitch[gridindex];
                              CategorySwitch[gridindex]
                                  ? addUserCategory(categories[gridindex].code)
                                  : removeUserCategory(
                                      categories[gridindex].code);
                            }),
                            child: Container(
                              alignment: Alignment.center,
                              width: 100.0 * normalizedWidth(context),
                              height: 100.0 * normalizedHeight(context),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      10.0 * normalizedWidth(context)),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          categories[gridindex].image),
                                      fit: BoxFit.cover)),
                              child: Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    CircularCheckBox(
                                        value: CategorySwitch[gridindex],
                                        checkColor: Styles.whiteColor,
                                        activeColor: Styles.tealColor,
                                        inactiveColor: Colors.transparent,
                                        onChanged: (val) => setState(() {
                                              CategorySwitch[gridindex] =
                                                  !CategorySwitch[gridindex];
                                              CategorySwitch[gridindex]
                                                  ? addUserCategory(
                                                      categories[gridindex]
                                                          .code)
                                                  : removeUserCategory(
                                                      categories[gridindex]
                                                          .code);
                                            })),
                                    BorderedText(
                                      strokeColor: Styles.navyBlue,
                                      strokeWidth:
                                          2.0 * normalizedWidth(context),
                                      child: Text(
                                          translate(
                                              'category.${categories[gridindex].code}'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Styles.whiteColor)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}

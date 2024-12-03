import 'dart:developer';
import 'dart:io';

import 'package:braille_recognition/cubit/data_cubit.dart';
// import 'package:braille_recognition/firebase_options.dart';
import 'package:braille_recognition/pages/login_page.dart';
import 'package:braille_recognition/pages/main_page.dart';
import 'package:braille_recognition/pages/onboarding.dart';
import 'package:braille_recognition/pages/select_role.dart';
import 'package:braille_recognition/themes.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // final messaging = FirebaseMessaging.instance;

  // final settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  // print('Permission granted: ${settings.authorizationStatus}');

  // String notificationToken = await messaging.getToken() ?? "undefined";
  // print(notificationToken);
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getBool("isLogin") ?? false) {
    String authToken = preferences.getString("token") ?? "undefined";
    // Api api = Api(token: authToken);
    // ApiResult<bool> res = await api.setNotification(notificationToken);
    // if (res.isSuccess) {
    //   print("success");
    // } else {
    //   print("Error: " + res.message);
    // }
  }

  Appodeal.setAutoCache(AppodealAdType.Banner, true);
  Appodeal.setAutoCache(AppodealAdType.Interstitial, true);
  Appodeal.setAutoCache(AppodealAdType.RewardedVideo, true);
  Appodeal.setBannerCallbacks(
    onBannerLoaded: (isPrecache) => {},
    onBannerFailedToLoad: () {
      log("Failed to load ad:");
    },
    onBannerShown: () => {},
    onBannerShowFailed: () {
      log("onBannerShowFailed");
    },
    onBannerClicked: () => {},
    onBannerExpired: () => {},
  );
  await Appodeal.initialize(
    appKey: Platform.isAndroid
        ? "816c44e3a5e4105759eb1d2d28c000e01eb2c7a5ed594c22"
        : "3d164de64d37030ac2e5a5616160c76d432b321ea1f79607",
    adTypes: [
      AppodealAdType.Interstitial,
      AppodealAdType.Banner,
      AppodealAdType.RewardedVideo,
    ],
    onInitializationFinished: (errors) {
      if (errors!.isNotEmpty) {
        log("AppodealError" + errors.toString());
      }
    },
  );

  SharedPreferences.getInstance().then(
    (value) {
      runApp(MyApp(
        isFirstOpen: value.getBool("isFirstOpen") ?? true,
        isLogin: value.getBool("isLogin") ?? false,
        token: value.getString("token") ?? "Undefined",
      ));
    },
  );
}

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    this.isFirstOpen = true,
    this.isLogin = false,
    this.token = "undefined",
  });

  bool isFirstOpen;
  bool isLogin;
  String token;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataCubit(token),
      child: MaterialApp(
        title: 'Braille Recognition',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        home: MyHomePage(
          title: 'Braille Recognition',
          isFirstOpen: isFirstOpen,
          isLogin: isLogin,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
    required this.title,
    this.isFirstOpen = true,
    this.isLogin = false,
  });

  final String title;
  final bool isFirstOpen;
  final bool isLogin;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return widget.isFirstOpen
        ? OnboardingPage()
        : widget.isLogin
            ? MainPage()
            : LoginPage();
  }
}

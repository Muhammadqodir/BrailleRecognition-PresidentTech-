import 'package:braille_recognition/cubit/data_cubit.dart';
import 'package:braille_recognition/pages/content_history.dart';
import 'package:braille_recognition/pages/content_main.dart';
import 'package:braille_recognition/pages/content_profile.dart';
import 'package:braille_recognition/widgets/bottom_navigation.dart';
import 'package:braille_recognition/widgets/fade_indexed_stack.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int pageIndex = 0;
  void openPage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  void rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    inAppReview.openStoreListing(appStoreId: 'id1669110413');

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) => rateApp());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeIndexedStack(
        index: pageIndex,
        children: [
          ContentMain(
            context: context,
          ),
          ContentHistory(
            context: context,
          ),
          ContentProfile(
            context: context,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        items: [
          Item("title", "icons/home_outline.svg", "icons/home_gradient.svg"),
          Item("title", "icons/star_outline.svg", "icons/star_gradient.svg"),
          Item("title", "icons/profile_outline.svg",
              "icons/profile_gradient.svg")
        ],
        openPage: openPage,
      ),
    );
  }
}

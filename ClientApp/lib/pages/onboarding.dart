import 'package:braille_recognition/fragments/onboarding_fragment.dart';
import 'package:braille_recognition/pages/register_page.dart';
import 'package:braille_recognition/pages/select_role.dart';
import 'package:braille_recognition/widgets/circle_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  double percent = 0.25;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          setState(() {
            percent = 0.25 * (value + 1);
          });
        },
        children: [
          OnboardingFragment(
            title: "Translate braille directly from your phone camera!",
            description:
                "Our artificial intelligence is proficient at identifying Braille dots in images and can effectively translate them into different languages.",
            illustration: "images/getstart.png",
            illustrationBg: "images/onboarding_0.png",
          ),
          OnboardingFragment(
            title: "Bridging the Homework Gap!",
            description:
                "Simplify the homework review process for teachers and parents. With our app, effortlessly check Braille assignments, providing a valuable tool for educators and fostering collaboration between parents and teachers.",
            illustration: "images/resize_3.png",
            illustrationBg: "images/onboarding_1.png",
          ),
          OnboardingFragment(
            title: "Inclusivity!",
            description:
                "Embrace inclusivity with our app, breaking down barriers for the visually impaired. Join us in creating a world where education is accessible to everyone, regardless of their abilities!",
            illustration: "images/getstart.png",
            illustrationBg: "images/onboarding_2.png",
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          CircularPercentIndicator(
            radius: 39,
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 200,
            percent: percent,
            linearGradient: const LinearGradient(colors: [
              Color(0xFFB3EAFF),
              Color(0xFF4AB7E0),
              Color(0xFF0AB0EF),
            ]),
            lineWidth: 3,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          CircleButton(
            size: 60,
            onTap: () async {
              if (percent >= 0.75) {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                preferences.setBool("isFirstOpen", false);
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              } else {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.ease,
                );
              }
            },
          )
        ],
      ),
    );
  }
}

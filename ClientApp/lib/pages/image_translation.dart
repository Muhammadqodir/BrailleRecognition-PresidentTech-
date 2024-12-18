import 'dart:developer';
import 'dart:io';
import 'package:braille_recognition/api/api.dart';
import 'package:braille_recognition/api/models/translation.dart';
import 'package:braille_recognition/api/result.dart';
import 'package:braille_recognition/cubit/data_cubit.dart';
import 'package:braille_recognition/language.dart';
import 'package:braille_recognition/main.dart';
import 'package:braille_recognition/pages/image_result.dart';
import 'package:braille_recognition/widgets/custom_button.dart';
import 'package:braille_recognition/widgets/scanner_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:measured_size/measured_size.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class ImageTranslationPage extends StatefulWidget {
  ImageTranslationPage({Key? key, required this.image, required this.lang_code})
      : super(key: key);

  File image;

  String lang_code;

  @override
  State<ImageTranslationPage> createState() => _ImageTranslationPageState();
}

class _ImageTranslationPageState extends State<ImageTranslationPage>
    with SingleTickerProviderStateMixin {
  bool _animationStopped = false;
  late AnimationController _animationController;

  double image_height = 50;
  double percent = 0;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animateScanAnimation(true);
      } else if (status == AnimationStatus.dismissed) {
        animateScanAnimation(false);
      }
    });
    translate(widget.lang_code);
    super.initState();
  }

  void animateScanAnimation(bool reverse) {
    if (reverse) {
      _animationController.reverse(from: 1.0);
    } else {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  GlobalKey key = GlobalKey();

  void translate(String lang) async {
    await Future.delayed(const Duration(seconds: 1));
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    setState(() {
      image_height = renderBox.size.height + 60;
    });
    animateScanAnimation(false);
    String token = (await SharedPreferences.getInstance()).getString("token") ??
        "undefined";
    ApiResult<TranslationResult> res = await Api(token: token).translate(
      widget.image,
      lang,
    );
    if (res.isSuccess) {
      setState(() {
        isFinish = true;
      });

      // context.read<DataCubit>().api.addTranslation(res.data!);
      Navigator.pushReplacement(context,
          CupertinoPageRoute(builder: ((context) {
        return ImageResultPage(
          result: res.data!,
        );
      })));
    } else {
      Fluttertoast.showToast(msg: res.message);
    }
    startCounter();
  }

  bool isFinish = false;
  void startCounter() async {
    while (percent < 0.90 && !isFinish) {
      setState(() {
        percent = percent + 0.001;
      });
      await Future.delayed(const Duration(milliseconds: 5));
    }
    if (percent >= 0.90) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text("The process is taking longer than usual, please wait..."),
      ));
    }
    while (percent < 0.98 && !isFinish) {
      setState(() {
        percent = percent + 0.0001;
      });
      await Future.delayed(const Duration(milliseconds: 5));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        MyButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset("icons/back.svg"),
                        ),
                        Expanded(
                          child: Text(
                            "Translation",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        // MyButton(
                        //   onTap: () {},
                        //   child: SvgPicture.asset("images/notification.svg"),
                        //   width: 24,
                        //   height: 24,
                        // )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'image',
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(
                                      0, 4), // changes position of shadow
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  MeasuredSize(
                                    onChange: ((size) {
                                      log("Size changed");
                                    }),
                                    child: Container(
                                      key: key,
                                      child: Image.file(
                                        widget.image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  ScannerAnimation(
                                    _animationStopped,
                                    image_height,
                                    animation: _animationController,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            AnimatedOpacity(
                              opacity: 1,
                              duration: const Duration(milliseconds: 200),
                              child: Column(
                                children: [
                                  Text(
                                    "Analyzing image...",
                                    textAlign: TextAlign.center,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(
                                    height: 12,
                                    width: double.infinity,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: LinearProgressIndicator(
                                      color: const Color(0xFF26A6D6),
                                      backgroundColor: const Color(0xFFB2E4F8),
                                      value: percent,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        AppodealBanner(
                          adSize: AppodealBannerSize.BANNER,
                        ),
                      ],
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
}

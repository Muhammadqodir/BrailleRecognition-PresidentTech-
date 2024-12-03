import 'dart:io';
import 'package:braille_recognition/api/api.dart';
import 'package:braille_recognition/api/models/translation.dart';
import 'package:braille_recognition/api/result.dart';
import 'package:braille_recognition/cubit/data_cubit.dart';
import 'package:braille_recognition/language.dart';
import 'package:braille_recognition/pages/image_viewer_page.dart';
import 'package:braille_recognition/widgets/custom_button.dart';
import 'package:braille_recognition/widgets/dialog.dart';
import 'package:braille_recognition/widgets/ontap_scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class ImageResultPage extends StatefulWidget {
  ImageResultPage({Key? key, required this.result}) : super(key: key);

  final TranslationResult result;

  @override
  State<ImageResultPage> createState() => _ImageResultPageState();
}

class _ImageResultPageState extends State<ImageResultPage> {
  @override
  void initState() {
    super.initState();
    Appodeal.show(AppodealAdType.Interstitial);
  }

  Future<Api> initApi() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token") ?? "undefined";
    return Api(token: token);
  }

  void sendToBack(int rating) async {
    Api api = await initApi();
    await api.rateTranslation(widget.result.id, rating);
    print("rated");
  }

  void rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    inAppReview.openStoreListing(appStoreId: 'id1669110413');

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  void setRating(int rating) async {
    sendToBack(rating);
    if (rating > 0) {
      Dialogs.showDonateDialog(context);
    } else {
      Dialogs.showApologiseDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    DataCubit dataCubit = context.read<DataCubit>();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Row(
                    children: [
                      MyButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset("icons/back.svg"),
                        width: 24,
                        height: 24,
                      ),
                      Expanded(
                        child: Text(
                          "Translation",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      MyButton(
                        onTap: () {
                          Share.share(
                            "${widget.result.resultBraille}\n\n${widget.result.result}\n\nTranslated by: https://braillerecognition.alfocus.uz/",
                          );
                        },
                        child: SvgPicture.asset(
                          "icons/share.svg",
                          color: Colors.black,
                        ),
                        width: 24,
                        height: 24,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFA2E7FB).withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(
                                        0, 4), // changes position of shadow
                                  ),
                                ],
                                color: Color(0xFFA2E7FB),
                              ),
                              child: Row(
                                children: [
                                  OnTapScaleAndFade(
                                    onTap: () {
                                      // Translator.translate(widget.image);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: ((context) {
                                            return ImageViewer(
                                              imageProvider: widget.result
                                                          .imageData.length >
                                                      0
                                                  ? MemoryImage(
                                                      widget.result.imageData,
                                                    )
                                                  : Image.network(
                                                      BASE_SERVER_URL +
                                                          widget
                                                              .result.imageUrl,
                                                    ).image,
                                            );
                                          }),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: 'image',
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(12)),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              spreadRadius: 1,
                                              blurRadius: 10,
                                              offset: const Offset(0,
                                                  4), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(12),
                                          ),
                                          child: FadeInImage(
                                            image: widget.result.imageData
                                                        .length >
                                                    0
                                                ? MemoryImage(
                                                    widget.result.imageData,
                                                  )
                                                : Image.network(
                                                    BASE_SERVER_URL +
                                                        widget.result.imageUrl,
                                                  ).image,
                                            placeholder: NetworkImage(
                                                "https://www.zonebourse.com/images/loading_100.gif"),
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "Braille",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    "icons/swap.svg",
                                    height: 28,
                                    width: 28,
                                  ),
                                  Expanded(
                                    child: Text(
                                      dataCubit
                                          .getLangTitle(widget.result.langCode),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFD5F3FB).withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(
                                        0, 4), // changes position of shadow
                                  ),
                                ],
                                color: Color(0xFFD5F3FB),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: "n_text",
                                    child: Text(
                                      widget.result.result,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // MyButton(
                                      //   onTap: () {},
                                      //   width: 20,
                                      //   height: 20,
                                      //   child: SvgPicture.asset(
                                      //     "icons/paper.svg",
                                      //     color: const Color(0xFF828282),
                                      //     width: 20,
                                      //     height: 20,
                                      //   ),
                                      // ),
                                      // const SizedBox(
                                      //   width: 18,
                                      // ),
                                      MyButton(
                                        onTap: () {
                                          setRating(1);
                                        },
                                        width: 22,
                                        height: 22,
                                        child: SvgPicture.asset(
                                          "images/thumbsup.svg",
                                          color: Color(0xFF828282),
                                          width: 22,
                                          height: 22,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 18,
                                      ),
                                      MyButton(
                                        onTap: () {
                                          setRating(-1);
                                        },
                                        width: 22,
                                        height: 22,
                                        child: SvgPicture.asset(
                                          "images/thumbsdown.svg",
                                          color: Color(0xFF828282),
                                          width: 18,
                                          height: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 14,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Recognized Braille symbols:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontFamily: "PoppinBold"),
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 12),
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(24)),
                                color: const Color(0xFFD5F3FB),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFD5F3FB).withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(
                                        0, 4), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: "b_text",
                                    child: Text(
                                      widget.result.resultBraille,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                AppodealBanner(
                  adSize: AppodealBannerSize.BANNER,
                ),
                SizedBox(
                  height: 6,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

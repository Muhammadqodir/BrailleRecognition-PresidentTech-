import 'dart:developer';
import 'dart:io';

import 'package:braille_recognition/api/api.dart';
import 'package:braille_recognition/api/models/translation.dart';
import 'package:braille_recognition/api/result.dart';
import 'package:braille_recognition/cubit/data_cubit.dart';
import 'package:braille_recognition/language.dart';
import 'package:braille_recognition/pages/history_page.dart';
import 'package:braille_recognition/pages/image_translation.dart';
import 'package:braille_recognition/widgets/custom_button.dart';
import 'package:braille_recognition/widgets/dialog.dart';
import 'package:braille_recognition/widgets/history_item.dart';
import 'package:braille_recognition/widgets/ontap_scale.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

const double _kItemExtent = 32.0;

class ContentMain extends StatefulWidget {
  const ContentMain({super.key, required this.context});
  final BuildContext context;

  @override
  State<ContentMain> createState() => _ContentMainState();
}

class _ContentMainState extends State<ContentMain> {
  String? imagePath;
  void runCamera() async {
    print("start");
    try {
      await Permission.camera.request();
    } catch (e) {
      print("error");
    }

    bool isCameraGranted = await Permission.camera.request().isGranted;

    if (!isCameraGranted) {
      return;
    }

    imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    try {
      bool success = await EdgeDetection.detectEdge(
        imagePath ?? "",
        canUseGallery: false,
        androidScanTitle: 'Scanning', // use custom localizations for android
        androidCropTitle: 'Crop',
        androidCropBlackWhiteTitle: 'Crop',
        androidCropReset: 'Reset',
      );
      if (success) {
        Navigator.push(
          this.context,
          CupertinoPageRoute(
            builder: ((context) => ImageTranslationPage(
                  image: File(imagePath ?? ''),
                  lang_code:
                      context.read<DataCubit>().state.langs[selectedLang].code,
                )),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void runGallery() async {
    await Permission.photos.request();

    bool isCameraGranted = await Permission.storage.request().isGranted;

    if (!isCameraGranted) {
      return;
    }

    imagePath = join((await getApplicationSupportDirectory()).path,
        "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");

    try {
      ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        Navigator.push(
          this.context,
          CupertinoPageRoute(
            builder: (context) => ImageTranslationPage(
              image: File(image.path),
              lang_code:
                  context.read<DataCubit>().state.langs[selectedLang].code,
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  int selectedLang = 0;

  void showSelectLangDialog(List<Language> langs) {
    FixedExtentScrollController extentScrollController =
        FixedExtentScrollController(initialItem: selectedLang);
    showCupertinoModalPopup<void>(
      context: this.context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: CupertinoPicker(
                  scrollController: extentScrollController,
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: false,
                  looping: false,
                  itemExtent: _kItemExtent,
                  // This is called when selected item is changed.
                  onSelectedItemChanged: (int selectedItem) {
                    SystemSound.play(SystemSoundType.click);
                    HapticFeedback.mediumImpact();
                  },
                  children: List<Widget>.generate(langs.length, (int index) {
                    return Center(
                      child: Text(
                        langs[index].title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }),
                ),
              ),
              CupertinoButton(
                child: Text(
                  "Select",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                onPressed: () {
                  SharedPreferences.getInstance().then((value) {
                    value.setDouble("defaultLang",
                        extentScrollController.selectedItem.toDouble());
                  });

                  setState(() {
                    selectedLang = extentScrollController.selectedItem;
                  });
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  void initData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token") ?? "undefined";
    widget.context.read<DataCubit>().setToken(token);
    await widget.context.read<DataCubit>().updateAvailableLangs();
    await setDefaultLang();
    await widget.context.read<DataCubit>().getHistory();
  }

  Future<void> setDefaultLang() async {
    final prefs = await SharedPreferences.getInstance();
    int defaultLang = (prefs.getDouble("defaultLang") ?? 0).round();
    setState(() {
      selectedLang = defaultLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<TranslationResult> items = context.watch<DataCubit>().state.items;
    List<Language> langs = context.watch<DataCubit>().state.langs;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Braille Recognition",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                MyButton(
                  onTap: () async {
                    Dialogs.showDonateDialog(context);
                  },
                  child: SvgPicture.asset("images/infinity.svg"),
                  width: 24,
                  height: 24,
                )
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    widget.context.read<DataCubit>().getHistory();
                  },
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFA2E7FB).withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(
                                      0, 4), // changes position of shadow
                                ),
                              ],
                              color: const Color(0xFFA2E7FB),
                            ),
                            child: OnTapScaleAndFade(
                              onTap: () {
                                showSelectLangDialog(langs);
                              },
                              child: Row(
                                children: [
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
                                      langs[selectedLang].title,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFD5F3FB).withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(
                                    0,
                                    4,
                                  ), // changes position of shadow
                                ),
                              ],
                              color: const Color(0xFFD5F3FB),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OnTapScaleAndFade(
                                    onTap: runCamera,
                                    child: Column(
                                      children: [
                                        SvgPicture.asset("icons/camera.svg"),
                                        Text(
                                          "Camera",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: OnTapScaleAndFade(
                                    onTap: runGallery,
                                    child: Column(
                                      children: [
                                        SvgPicture.asset("icons/import.svg"),
                                        Text(
                                          "Import",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: OnTapScaleAndFade(
                                    child: Column(
                                      children: [
                                        SvgPicture.asset("icons/edit.svg"),
                                        Text(
                                          "Keyboard",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Fluttertoast.showToast(msg: "Soon!");
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const AppodealBanner(
                      adSize: AppodealBannerSize.BANNER,
                      placement: "default",
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "History",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontFamily: "PoppinBold"),
                                ),
                              ),
                              CupertinoButton(
                                child: Opacity(
                                  opacity: 0.6,
                                  child: Text(
                                    "See more",
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          HistoryPage(context: context),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          items.length > 0
                              ? Column(
                                  children: items
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 24),
                                            child: HistoryItem(
                                              result: e,
                                            ),
                                          ))
                                      .toList(),
                                )
                              : Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "images/empty.png",
                                        width: 150,
                                      ),
                                      Text(
                                        "Your history list is empty!",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .color!
                                                  .withAlpha(150),
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    )
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

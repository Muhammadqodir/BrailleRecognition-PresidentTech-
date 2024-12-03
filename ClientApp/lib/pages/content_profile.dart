import 'package:braille_recognition/api/models/user.dart';
import 'package:braille_recognition/pages/history_page.dart';
import 'package:braille_recognition/pages/login_page.dart';
import 'package:braille_recognition/themes.dart';
import 'package:braille_recognition/widgets/card.dart';
import 'package:braille_recognition/widgets/custom_button.dart';
import 'package:braille_recognition/widgets/dialog.dart';
import 'package:braille_recognition/widgets/ontap_scale.dart';
import 'package:braille_recognition/widgets/settings_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContentProfile extends StatefulWidget {
  const ContentProfile({super.key, required this.context});

  final BuildContext context;

  @override
  State<ContentProfile> createState() => _ContentProfileState();
}

class _ContentProfileState extends State<ContentProfile> {
  User user = User.undefined();

  @override
  void initState() {
    initData();
    // TODO: implement initState
    super.initState();
  }

  Future<void> initData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJson = preferences.getString("user") ?? "undefined";
    print("User: " + userJson);
    if (userJson != "undefined") {
      setState(() {
        user = User.fromJson(userJson);
      });
    }
  }

  void rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    // inAppReview.openStoreListing(appStoreId: 'id1669110413');

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  void logout() async {
    (await SharedPreferences.getInstance()).setBool(
      "isLogin",
      false,
    );
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Profile",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                MyButton(
                  onTap: () {
                    logout();
                  },
                  child: SvgPicture.asset("images/logout.svg"),
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
              padding: EdgeInsets.symmetric(horizontal: 24),
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(30),
                      ),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFBAE8F9),
                        ),
                        child: FadeInImage.assetNetwork(
                          placeholder: "images/user.png",
                          image: user.photo_url,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Image.asset("images/user.png"),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 12,
                    //     vertical: 4,
                    //   ),
                    //   decoration: const BoxDecoration(
                    //     borderRadius: BorderRadius.all(
                    //       Radius.circular(24),
                    //     ),
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         Color(0xFF95DBF6),
                    //         Color(0xFF11B1EE),
                    //       ],
                    //     ),
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       Text(
                    //         "0 of 3",
                    //         style: Theme.of(context)
                    //             .textTheme
                    //             .titleMedium!
                    //             .copyWith(
                    //               color: Colors.white,
                    //               fontSize: 14,
                    //             ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                MyCard(
                  title: "Account",
                  soonBadge: false,
                  child: Column(
                    children: [
                      SettingsItem(
                        icon: "icons/icon_history.svg",
                        title: "History",
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) =>
                                  HistoryPage(context: context),
                            ),
                          );
                        },
                      ),
                      SettingsItem(
                        icon: "images/infinity.svg",
                        title: "Donate",
                        onTap: () {
                          Dialogs.showDonateDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                // MyCard(
                //   title: "Notifications",
                //   soonBadge: true,
                //   child: Column(
                //     children: [
                //       SettingsItem(
                //         icon: "icons/icon_notifications.svg",
                //         title: "Pop-up Notifications",
                //         isSwitch: true,
                //         onTap: () {},
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(
                //   height: 24,
                // ),
                MyCard(
                  title: "Other",
                  child: Column(
                    children: [
                      SettingsItem(
                        icon: "icons/icon_message.svg",
                        title: "Contact Us",
                        onTap: () {
                          launchUrl(
                            Uri.parse(
                                "mailto:mqodir777@gmail.com?subject=Braille Recognition"),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                      SettingsItem(
                        icon: "icons/icon_privacy.svg",
                        title: "Privacy Policy",
                        onTap: () {
                          launchUrlString(
                            "https://braillerecognition.alfocus.uz/privacy-policy",
                          );
                        },
                      ),
                      SettingsItem(
                        icon: "icons/thumbsup.svg",
                        title: "Rate app",
                        onTap: () {
                          rateApp();
                        },
                      ),
                      // SettingsItem(
                      //   icon: "icons/icon_settings.svg",
                      //   title: "Settings",
                      //   onTap: () {
                      //     //Open settings
                      //   },
                      // ),
                      SettingsItem(
                        icon: "icons/icon_community.svg",
                        title: "Share",
                        onTap: () {
                          Share.share(
                            'Check app https://abduvoitov.uz/projects/braille/',
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  "Focus Group\n© Copyrights 2024",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.black.withOpacity(0.6),
                      ),
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

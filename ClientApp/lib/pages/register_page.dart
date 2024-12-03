import 'dart:io';

import 'package:braille_recognition/api/api.dart';
import 'package:braille_recognition/api/models/user.dart';
import 'package:braille_recognition/api/result.dart';
import 'package:braille_recognition/cubit/data_cubit.dart';
import 'package:braille_recognition/main.dart';
import 'package:braille_recognition/pages/login_page.dart';
import 'package:braille_recognition/pages/main_page.dart';
import 'package:braille_recognition/pages/select_role.dart';
import 'package:braille_recognition/themes.dart';
import 'package:braille_recognition/widgets/custom_btn.dart';
import 'package:braille_recognition/widgets/custom_input.dart';
import 'package:braille_recognition/widgets/custom_select.dart';
import 'package:braille_recognition/widgets/divider_text.dart';
import 'package:braille_recognition/widgets/ontap_scale.dart';
import 'package:braille_recognition/widgets/outline_btn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String role = "";
  bool accept = false;

  bool isLoading = false;

  List<String> roles = const [
    "Parent of Visually Impaired Children",
    "Teacher of Visually Impaired Students",
    "Regular Education Teacher",
    "Special Education Department",
    "Language Enthusiast",
    "Other",
  ];

  void setLoading(bool val) {
    setState(() {
      isLoading = val;
    });
  }

  void loginWithApple() async {
    Api api = Api();
    setLoading(true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      ApiResult<User> res = await api.loginGoogle(
        credential.email ?? 'undefined',
        credential.givenName ?? 'undefined',
        credential.identityToken ?? 'undefined',
        'undefined',
      );
      if (res.isSuccess) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        if (res.data!.role == "undefined") {
          print("UserToken: " + res.data!.token);
          await preferences.setString("token", res.data!.token);
          await preferences.setString("user", res.data!.toJson());
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (context) => const SelectRolePage(),
            ),
          );
        } else {
          await preferences.setString("token", res.data!.token);
          await preferences.setString("user", res.data!.toJson());
          await preferences.setBool("isLogin", true);
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (context) => MainPage(),
            ),
          );
        }
      } else {
        print(res.message);
        Fluttertoast.showToast(
          gravity: ToastGravity.TOP,
          msg: res.message,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    setLoading(false);
  }

  void loginWithGoogle() async {
    Api api = Api();
    setLoading(true);
    const List<String> scopes = <String>[
      'email',
      'profile',
    ];
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: scopes,
    );

    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        ApiResult<User> res = await api.loginGoogle(
          account.email,
          account.displayName ?? 'undefined',
          account.serverAuthCode ?? 'undefined',
          account.photoUrl ?? 'undefined',
        );
        if (res.isSuccess) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          if (res.data!.role == "undefined") {
            print("UserToken: " + res.data!.token);
            await preferences.setString("token", res.data!.token);
            await preferences.setString("user", res.data!.toJson());
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (context) => const SelectRolePage(),
              ),
            );
          } else {
            await preferences.setString("token", res.data!.token);
            await preferences.setString("user", res.data!.toJson());
            await preferences.setBool("isLogin", true);
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(
                builder: (context) => MainPage(),
              ),
            );
          }
        } else {
          print(res.message);
          Fluttertoast.showToast(
            gravity: ToastGravity.TOP,
            msg: res.message,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Authorizatoin failed!");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
    setLoading(false);
  }

  void register() async {
    Api api = Api();
    setLoading(true);
    ApiResult<String> res =
        await api.registerNewUser(name.text, email.text, password.text, role);
    if (res.isSuccess) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString("token", res.data!);
      await preferences.setString(
        "user",
        User(
                name: name.text,
                token: res.data!,
                email: email.text,
                phone: "",
                role: role,
                photo_url: "")
            .toJson(),
      );
      await preferences.setBool("isLogin", true);
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => MainPage(),
        ),
      );
    } else {
      Fluttertoast.showToast(
        gravity: ToastGravity.TOP,
        msg: res.message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
    setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(
              height: 25,
              width: double.infinity,
            ),
            Text(
              "Hey there!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Create an Account",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 32,
            ),
            CustomTextField(
              controller: name,
              icon: "icons/profile.svg",
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              onChanged: (v) {},
              hint: "Name",
            ),
            const SizedBox(
              height: 12,
            ),
            CustomTextField(
              controller: email,
              icon: "icons/message.svg",
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              onChanged: (v) {},
              hint: "Email",
            ),
            const SizedBox(
              height: 12,
            ),
            CustomSelect(
              title: "Who are you?",
              items: roles,
              icon: "images/question1.svg",
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
              onChanged: (v) {
                role = roles[v];
              },
              hint: "Who are you?",
            ),
            const SizedBox(
              height: 12,
            ),
            CustomTextField(
              controller: password,
              icon: "icons/lock.svg",
              obscureText: true,
              margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              onChanged: (v) {},
              hint: "Password",
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  CupertinoCheckbox(
                    value: accept,
                    checkColor: Colors.white,
                    activeColor: primaryColor,
                    onChanged: (v) {
                      setState(() {
                        accept = v!;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          accept = !accept;
                        });
                      },
                      child: Linkify(
                        onOpen: (link) {
                          launchUrl(
                            Uri.parse(link.url),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        text:
                            "By continuing you accept our Privacy Policy: https://braillerecognition.alfocus.uz/privacy-policy ",
                        options: const LinkifyOptions(humanize: false),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color!
                                  .withAlpha(100),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 48,
            ),
            CustomBtn(
              onTap: () async {
                if (accept) {
                  register();
                } else {
                  Fluttertoast.showToast(
                    msg: "Accept our Privacy policy",
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.amber,
                    textColor: Colors.white,
                  );
                }
              },
              text: "Register",
              isLoading: isLoading,
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            //   child: OnTapScaleAndFade(
            //     onTap: () {
            //       Navigator.of(context).pushReplacement(
            //         CupertinoPageRoute(
            //           builder: (context) => const LoginPage(),
            //         ),
            //       );
            //     },
            //     child: Text(
            //       "Later, continue using",
            //       textAlign: TextAlign.center,
            //       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            //             color: primaryColor,
            //             fontFamily: "PoppinsBold",
            //           ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),
            const DividerWithText(text: "Or"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // if (Platform.isAndroid)
                //   OutlineBtn(
                //     onTap: () {
                //       loginWithGoogle();
                //     },
                //     width: 60,
                //     height: 60,
                //     padding: const EdgeInsets.all(0),
                //     child: Image.asset(
                //       "icons/google.png",
                //       height: 26,
                //       width: 26,
                //     ),
                //   ),
                // if (Platform.isIOS)
                //   Row(
                //     children: [
                //       const SizedBox(
                //         width: 24,
                //       ),
                //       OutlineBtn(
                //         onTap: () {
                //           loginWithApple();
                //         },
                //         width: 60,
                //         height: 60,
                //         padding: const EdgeInsets.all(0),
                //         child: Image.asset(
                //           "icons/apple.png",
                //           height: 26,
                //           width: 26,
                //         ),
                //       ),
                //     ],
                //   ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                OnTapScaleAndFade(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      CupertinoPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Login",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: primaryColor,
                          fontFamily: "PoppinsBold",
                        ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

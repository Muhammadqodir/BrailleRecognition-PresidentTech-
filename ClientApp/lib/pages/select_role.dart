import 'package:braille_recognition/api/api.dart';
import 'package:braille_recognition/api/models/user.dart';
import 'package:braille_recognition/api/result.dart';
import 'package:braille_recognition/pages/login_page.dart';
import 'package:braille_recognition/pages/main_page.dart';
import 'package:braille_recognition/themes.dart';
import 'package:braille_recognition/widgets/custom_btn.dart';
import 'package:braille_recognition/widgets/ontap_scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectRolePage extends StatefulWidget {
  const SelectRolePage({super.key});

  @override
  State<SelectRolePage> createState() => _SelectRolePageState();
}

class _SelectRolePageState extends State<SelectRolePage> {
  bool isLoading = false;
  String selectedRole = "";
  String userName = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserName();
  }

  void getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      String userJson = preferences.getString("user") ?? "undefined";
      if (userJson != "undefined") {
        userName = User.fromJson(userJson).name;
      } else {
        logout();
      }
    });
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

  void changeRole() async {
    if (selectedRole != "") {
      setState(() {
        isLoading = true;
      });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      Api api = Api(token: preferences.getString("token") ?? 'undefined');
      ApiResult<User> res = await api.setRole(selectedRole);
      if (res.isSuccess) {
        await preferences.setString("user", res.data!.toJson());
        await preferences.setBool("isLogin", true);
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => MainPage(),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: res.message);
      }
      setState(() {
        isLoading = true;
      });
    } else {
      Fluttertoast.showToast(msg: "Please select your role");
    }
  }

  List<String> roles = const [
    "Parent of Visually Impaired Children",
    "Teacher of Visually Impaired Students",
    "Regular Education Teacher",
    "Special Education Department",
    "Language Enthusiast",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 25,
              width: double.infinity,
            ),
            Text(
              "Hey, $userName!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Who are you?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 32,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: roles
                    .map(
                      (e) => OnTapScaleAndFade(
                        onTap: () {
                          setState(() {
                            selectedRole = e;
                          });
                        },
                        lowerBound: 0.96,
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 16,
                            bottom: 12,
                            left: 12,
                            right: 12,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedRole == e
                                  ? Colors.transparent
                                  : Colors.black12,
                              width: 2,
                            ),
                            gradient: selectedRole == e
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF95DBF6),
                                      Color(0xFF11B1EE),
                                      Color(0xFF11B1EE),
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  e,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        height: 1,
                                        color: selectedRole == e
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .color,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(
              height: 48,
            ),
            CustomBtn(
              onTap: () async {
                changeRole();
              },
              text: "Login",
              isLoading: isLoading,
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 32),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

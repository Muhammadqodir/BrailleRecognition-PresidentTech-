import 'package:braille_recognition/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Dialogs {
  static void showDonateDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (BuildContext context) {
        return SizedBox(
          height: 260,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "If you appreciate our concept, kindly lend us your support.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Image.asset(
                    "images/bmac.png",
                    width: double.infinity,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: CustomBtn(
                    text: "Donate!",
                    onTap: () {
                      launchUrlString(
                        "https://www.buymeacoffee.com/braillerecognition",
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showApologiseDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Apologies!",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Please follow these steps for a better translation:\n✔️ The image was clear and contrasty\n✔️ The light fell obliquely from the top side of the paper\n✔️ The paper was photographed from top",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 24),
                //   child: Text(
                //     "If you appreciate our concept, kindly lend us your support.",
                //     style: Theme.of(context).textTheme.bodyMedium,
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 24),
                //   child: CustomBtn(
                //     text: "Donate!",
                //     onTap: () {},
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

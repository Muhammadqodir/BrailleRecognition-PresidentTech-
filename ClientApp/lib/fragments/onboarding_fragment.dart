import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart';

class OnboardingFragment extends StatelessWidget {
  OnboardingFragment(
      {super.key,
      required this.title,
      required this.description,
      required this.illustration,
      required this.illustrationBg});

  String title;
  String description;
  String illustration;
  String illustrationBg;

  double getNegativeMargin(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double margin = (width * 100) / height;
    print("Margin:" + margin.toString());
    if (margin > 50) {
      print(height * ((50 - margin) / 100));
      return height * ((50 - margin) / 100);
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          transform: Matrix4.translationValues(
            0.0,
            getNegativeMargin(context),
            0.0,
          ),
          child: Image.asset(
            illustrationBg,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 40,
                ),
                child: Image.asset(
                  illustration,
                  height: MediaQuery.of(context).size.height * 0.50,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}

import 'package:braille_recognition/themes.dart';
import 'package:braille_recognition/widgets/ontap_scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  const CustomBtn({
    super.key,
    required this.text,
    required this.onTap,
    this.width = double.infinity,
    this.height = 50,
    this.isLoading = false,
    this.margin = const EdgeInsets.all(0),
    this.lowerBound = 0.95,
  });

  final String text;
  final Function() onTap;
  final double width;
  final double height;
  final EdgeInsets margin;
  final bool isLoading;
  final double lowerBound;

  @override
  Widget build(BuildContext context) {
    return OnTapScaleAndFade(
      onTap: onTap,
      lowerBound: lowerBound,
      child: Container(
        margin: margin,
        height: height,
        width: width,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: const LinearGradient(
            colors: [
              Color(0xFF95DBF6),
              Color(0xFF11B1EE),
              Color(0xFF11B1EE),
            ],
          ),
        ),
        child: isLoading
            ? const CupertinoActivityIndicator(
                color: Colors.white,
              )
            : Text(
                text,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontFamily: "PoppinsBold",
                    ),
              ),
      ),
    );
  }
}

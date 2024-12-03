import 'package:braille_recognition/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final Color baseColor;
  final Color errorColor;
  final TextInputType inputType;
  final TextAlign textAlign;
  final bool obscureText;
  final BorderRadius borderRadius;
  final List<TextInputFormatter> inputFormatter;
  final EdgeInsets padding;
  final Function(String) onChanged;
  final EdgeInsets margin;
  final String icon;

  const CustomTextField({
    this.hint = "",
    required this.controller,
    required this.onChanged,
    this.baseColor = const Color(0xFFF7F8F8),
    this.errorColor = Colors.red,
    this.textAlign = TextAlign.start,
    required this.icon,
    this.inputFormatter = const [],
    this.inputType = TextInputType.text,
    this.padding = const EdgeInsets.all(8),
    this.margin = const EdgeInsets.all(12),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.obscureText = false,
  });

  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Color currentColor = Colors.black12;

  @override
  void initState() {
    super.initState();
    currentColor = widget.baseColor;
  }

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.baseColor,
        borderRadius: widget.borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
        child: Row(
          children: [
            const SizedBox(
              width: 12,
            ),
            SvgPicture.asset(
              widget.icon,
              color: Colors.black54,
              width: 22,
              height: 22,
            ),
            Expanded(
              child: TextField(
                obscureText: widget.obscureText && !showPassword,
                onChanged: widget.onChanged,
                inputFormatters: widget.inputFormatter,
                textAlign: widget.textAlign,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 14),
                keyboardType: widget.inputType,
                enableSuggestions: !widget.obscureText,
                autocorrect: !widget.obscureText,
                controller: widget.controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  isDense: true,
                  border: InputBorder.none,
                  hintText: widget.hint,
                ),
              ),
            ),
            if (widget.obscureText)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: MyButton(
                  width: 22,
                  height: 22,
                  onTap: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  child: SvgPicture.asset("icons/hide.svg"),
                ),
              )
          ],
        ),
      ),
    );
  }
}

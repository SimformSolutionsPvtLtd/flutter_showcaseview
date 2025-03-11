import 'package:flutter/material.dart';

class DefaultTooltipTextWidget extends StatelessWidget {
  const DefaultTooltipTextWidget({
    super.key,
    required this.alignment,
    required this.padding,
    required this.text,
    this.textAlign,
    this.textDirection,
    this.textColor,
    this.textStyle,
  });

  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;
  final String text;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Color? textColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Text(
          text,
          textAlign: textAlign,
          textDirection: textDirection,
          style: textStyle ??
              Theme.of(context).textTheme.titleSmall!.merge(
                    TextStyle(
                      color: textColor,
                    ),
                  ),
        ),
      ),
    );
  }
}

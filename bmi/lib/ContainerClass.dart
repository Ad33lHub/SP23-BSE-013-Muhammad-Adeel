import 'package:flutter/material.dart';
class RepeatContainerCode extends StatelessWidget {
  final Color colour;
  final Widget? child;
  final Widget cardWidget;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Function? onPressed;

  RepeatContainerCode({
    super.key,
    required this.colour,
    Widget? cardWidget,
    this.onPressed,
    this.padding = const EdgeInsets.all(4.0),
    this.margin = const EdgeInsets.all(2.0), this.child,
  }) : cardWidget = cardWidget ?? Container();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed as VoidCallback?,
      child: Container(
        width: double.infinity,
        margin: margin,
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: padding,
        child: cardWidget,
      ),
    );
  }
}
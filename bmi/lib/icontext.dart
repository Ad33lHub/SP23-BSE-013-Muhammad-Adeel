import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class CardWidget extends StatelessWidget {
  final IconData iconData;
  final String label;
  Function? onPressed;
  CardWidget({super.key, required this.iconData, required this.label, this.onPressed});


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : 200.0;
        final iconSize = (maxH * 0.45).clamp(24.0, 80.0);
        final spacing = (maxH * 0.06).clamp(6.0, 20.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(
              iconData,
              size: iconSize,
              color: Colors.white,
            ),
            SizedBox(height: spacing),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
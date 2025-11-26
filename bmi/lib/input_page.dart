import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BMI Calculator")),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(
                      colour:Color.fromARGB(255, 3, 9, 40),
                      cardWidget: CardWidget(
                        iconData: FontAwesomeIcons.male,
                        label: 'Male',
                      ),
                  ),
                ),
                Expanded(
                  child: RepeatContainerCode(
                    colour:Color.fromARGB(255, 3, 9, 40),
                    cardWidget: CardWidget(
                      iconData: FontAwesomeIcons.female,
                      label: 'Female',
                    ),),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: RepeatContainerCode(
                colour:Color.fromARGB(255, 3, 9, 40),

            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(
                      colour:Color.fromARGB(255, 3, 9, 40),
                      cardWidget: CardWidget(
                        iconData: FontAwesomeIcons.male,
                        label: 'Male',
                      ),
                  ),
                ),
                Expanded(
                  child: RepeatContainerCode(
                    colour:Color.fromARGB(255, 3, 9, 40),
                    cardWidget: CardWidget(
                      iconData: FontAwesomeIcons.female,
                      label: 'Female',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RepeatContainerCode extends StatelessWidget {
  final Color colour;
  final Widget? child;
  final Widget cardWidget;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const RepeatContainerCode({
    super.key,
    required this.colour,
    Widget? cardWidget,
    this.padding = const EdgeInsets.all(15.0),
    this.margin = const EdgeInsets.all(15.0), this.child,
  }) : cardWidget = cardWidget ?? const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: padding,
        child: cardWidget,
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final IconData iconData;
  final String label;

  const CardWidget({super.key, required this.iconData, required this.label});

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
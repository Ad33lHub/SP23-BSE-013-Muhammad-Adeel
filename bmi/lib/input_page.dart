// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'icontext.dart';
import 'container.dart';

// ignore: use_key_in_widget_constructors
class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

const activecolor = Color.fromARGB(255, 2, 5, 23);
const deactivecolor = Color.fromARGB(255, 3, 9, 40);

class _InputPageState extends State<InputPage> {
  Color maleColor = deactivecolor;
  Color femaleColor = deactivecolor;

  void UpdateColor(int gender) {
    if (gender == 1) {
      maleColor = activecolor;
      femaleColor = deactivecolor;
    } else if (gender == 2) {
      femaleColor = activecolor;
      maleColor = deactivecolor;
    } else {}
  }

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
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        UpdateColor(1);
                      });
                    },
                    child: RepeatContainerCode(
                      colour: maleColor,
                      cardWidget: CardWidget(
                        iconData: FontAwesomeIcons.male,
                        label: 'Male',
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        UpdateColor(2);
                      });
                    },
                    child: RepeatContainerCode(
                      colour: femaleColor,
                      cardWidget: CardWidget(
                        iconData: FontAwesomeIcons.female,
                        label: 'Female',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: RepeatContainerCode(colour: Color.fromARGB(255, 3, 9, 40)),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(
                    colour: Color.fromARGB(255, 3, 9, 40),
                    cardWidget: CardWidget(
                      iconData: FontAwesomeIcons.male,
                      label: 'Male',
                    ),
                  ),
                ),
                Expanded(
                  child: RepeatContainerCode(
                    colour: Color.fromARGB(255, 3, 9, 40),
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

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
enum Gender{
  male,
  female,
}

class _InputPageState extends State<InputPage> {

  Gender? selectedGender;


  // Color maleColor = deactivecolor;
  // Color femaleColor = deactivecolor;
  // void UpdateColor(Gender gendertype) {
  //   if (gendertype == Gender.male) {
  //     maleColor = activecolor;
  //     femaleColor = deactivecolor;
  //   } else if (gendertype == Gender.female) {
  //     femaleColor = activecolor;
  //     maleColor = deactivecolor;
  //   } else {}
  // }

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
                        selectedGender = Gender.male;
                      });
                    },
                    child: RepeatContainerCode(
                      colour: selectedGender == Gender.male
                          ? activecolor
                          : deactivecolor,
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
                        selectedGender = Gender.female;
                      });
                    },
                    child: RepeatContainerCode(
                      colour: selectedGender == Gender.female
                          ? activecolor
                          : deactivecolor,
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

// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api

import 'package:bmi/ConstantFile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'ContainerClass.dart';
import 'icontext.dart';

// ignore: use_key_in_widget_constructors
class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

enum Gender { male, female }

class _InputPageState extends State<InputPage> {
  Gender? selectedGender;
  int sliderHight = 180;
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(
                    onPressed: () {
                      setState(() {
                        selectedGender = Gender.male;
                      });
                    },
                    colour: selectedGender == Gender.male
                        ? activecolor
                        : deactivecolor,
                    cardWidget: CardWidget(
                      iconData: FontAwesomeIcons.male,
                      label: 'Male',
                    ),
                  ),
                ),
                Expanded(
                  child: RepeatContainerCode(
                    onPressed: () {
                      setState(() {
                        selectedGender = Gender.female;
                      });
                    },
                    colour: selectedGender == Gender.female
                        ? activecolor
                        : deactivecolor,
                    cardWidget: CardWidget(
                      iconData: FontAwesomeIcons.female,
                      label: 'Female',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RepeatContainerCode(
              colour: Color.fromARGB(255, 3, 9, 40),
              cardWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('HIGHT', style: klabelstyle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        sliderHight.toString(),
                        style: kNumberStyle,
                      ),
                      Text('cm', style: klabelstyle),
                      
                    ],
                  ),
                  Slider(
                    value: sliderHight.toDouble(),
                    min: 120.0,
                    max: 220.0,
                    activeColor: Color(0xFFEB1555),
                    inactiveColor: Color(0xFF8D8E98),
                    onChanged: (double newValue) {
                      setState(() {
                        sliderHight = newValue.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(
                    colour: Color.fromARGB(255, 3, 9, 40),
                    cardWidget: Column(),
                  ),
                ),
                Expanded(
                  child: RepeatContainerCode(
                    colour: Color.fromARGB(255, 3, 9, 40),
                    cardWidget: Column(),
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

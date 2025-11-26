import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'icontext.dart';
import 'container.dart';
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




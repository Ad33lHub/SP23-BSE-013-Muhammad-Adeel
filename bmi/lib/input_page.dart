import 'package:flutter/material.dart';

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
                  child: RepeatContainerCode(color:Color.fromARGB(255, 3, 9, 40)),
                ),
                Expanded(
                  child: RepeatContainerCode(color:Color.fromARGB(255, 3, 9, 40)),
                ),
              ],
            ),
          ),
          Expanded(
            child: RepeatContainerCode(color:Color.fromARGB(255, 3, 9, 40)),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: RepeatContainerCode(color:Color.fromARGB(255, 3, 9, 40)),
                ),
                Expanded(
                  child: RepeatContainerCode(color:Color.fromARGB(255, 3, 9, 40)),
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
  const RepeatContainerCode({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 3, 9, 40),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
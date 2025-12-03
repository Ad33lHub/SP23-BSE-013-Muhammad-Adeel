import 'package:flutter/material.dart';
import 'package:bmi/ConstantFile.dart';
import 'ContainerClass.dart';
import 'input_page.dart';

class ResultScreen extends StatelessWidget {
  ResultScreen(
      {required this.bmiResult,
        required this.resultText,
        required this.interpretation});
  String bmiResult;
  String resultText;
  String interpretation;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Container(
              child: Center(
                child: Text(
                  'Your Result',
                  style: KTittleStyleS2,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: RepeatContainerCode(
              colour :activecolor,
              cardWidget: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    resultText.toUpperCase(),
                    style: klabelstyle,
                  ),
                  Text(
                    bmiResult,
                    style: KNormalNumberStyle,
                  ),
                  Text(
                    interpretation,
                    textAlign: TextAlign.center,
                    style: klabelstyle,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InputPage()),
                );
              },
              child: Container(
                child: Center(child: Text('RE-CALCULATOR' , style: KLargeButtonStyle)),
                color: Color(0xFFEB1555),
                margin: EdgeInsets.only(top: 10.0),
                width: double.infinity,
                height: 60.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String userInput = "";
  String result = "0";

  // Button widget
  Widget buildButton(String text, {Color color = Colors.black, Color textColor = Colors.green, Function? onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => onTap?.call(),
          child: Text(
            text,
            style: TextStyle(fontSize: 24, color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Evaluate input
  void equalPressed() {
    try {
      String finalInput = userInput.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('%', '/100');
      Parser p = Parser();
      Expression exp = p.parse(finalInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        result = eval.toString();
      });
    } catch (e) {
      setState(() {
        result = "Error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Display
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(userInput, style: const TextStyle(fontSize: 30, color: Colors.black54)),
                  const SizedBox(height: 10),
                  Text(result, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
          ),

          // Buttons
          Column(
            children: [
              Row(
                children: [
                  buildButton("C", color: Colors.white, textColor: Colors.red, onTap: () {
                    setState(() {
                      userInput = "";
                      result = "0";
                    });
                  }),
                  buildButton("%", color: Colors.white, textColor: Colors.green, onTap: () {
                    setState(() {
                      userInput += "%";
                    });
                  }),
                  buildButton("⌫", color: Colors.white, textColor: Colors.green, onTap: () {
                    setState(() {
                      if (userInput.isNotEmpty) {
                        userInput = userInput.substring(0, userInput.length - 1);
                      }
                    });
                  }),
                  buildButton("÷", color: Colors.white, textColor: Colors.green, onTap: () {
                    setState(() {
                      userInput += "÷";
                    });
                  }),
                ],
              ),
              Row(
                children: [
                  buildButton("7", onTap: () => setState(() => userInput += "7")),
                  buildButton("8", onTap: () => setState(() => userInput += "8")),
                  buildButton("9", onTap: () => setState(() => userInput += "9")),
                  buildButton("×", color: Colors.white, textColor: Colors.green, onTap: () {
                    setState(() {
                      userInput += "×";
                    });
                  }),
                ],
              ),
              Row(
                children: [
                  buildButton("4", onTap: () => setState(() => userInput += "4")),
                  buildButton("5", onTap: () => setState(() => userInput += "5")),
                  buildButton("6", onTap: () => setState(() => userInput += "6")),
                  buildButton("-", color: Colors.white, textColor: Colors.green, onTap: () {
                    setState(() {
                      userInput += "-";
                    });
                  }),
                ],
              ),
              Row(
                children: [
                  buildButton("1", onTap: () => setState(() => userInput += "1")),
                  buildButton("2", onTap: () => setState(() => userInput += "2")),
                  buildButton("3", onTap: () => setState(() => userInput += "3")),
                  buildButton("+", color: Colors.white, textColor: Colors.green, onTap: () {
                    setState(() {
                      userInput += "+";
                    });
                  }),
                ],
              ),
              Row(
                children: [
                  buildButton("00", onTap: () => setState(() => userInput += "00")),
                  buildButton("0", onTap: () => setState(() => userInput += "0")),
                  buildButton(".", onTap: () => setState(() => userInput += ".")),
                  buildButton("x²", color: Colors.white, textColor: Colors.green, onTap: () {
                    setState(() {
                      if (userInput.isNotEmpty) {
                        userInput = "(${userInput})^2";
                      }
                    });
                  }),
                  buildButton("x³", color: Colors.white, textColor: Colors.green, onTap: () {
                    setState(() {
                      if (userInput.isNotEmpty) {
                        userInput = "(${userInput})^3";
                      }
                    });
                  }),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => equalPressed(),
                        child: const Text("=", style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
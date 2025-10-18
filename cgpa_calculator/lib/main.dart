import 'package:flutter/material.dart';

void main() => runApp(CGPAApp());

class CGPAApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Calculator',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('CGPA Calculator'),
          centerTitle: true,
        ),
        body: CGPACalculator(),
      ),
    );
  }
}

class CGPACalculator extends StatefulWidget {
  @override
  _CGPACalculatorState createState() => _CGPACalculatorState();
}

class _CGPACalculatorState extends State<CGPACalculator> {
  List<TextEditingController> creditControllers = [];
  List<TextEditingController> gradeControllers = [];
  int subjectCount = 3;
  double cgpa = 0.0;

  @override
  void initState() {
    super.initState();
    _generateControllers();
  }

  void _generateControllers() {
    creditControllers =
        List.generate(subjectCount, (index) => TextEditingController());
    gradeControllers =
        List.generate(subjectCount, (index) => TextEditingController());
  }

  void _calculateCGPA() {
    double totalPoints = 0;
    double totalCredits = 0;

    for (int i = 0; i < subjectCount; i++) {
      double? credit = double.tryParse(creditControllers[i].text);
      double? grade = double.tryParse(gradeControllers[i].text);

      if (credit == null || grade == null) {
        _showError("Please enter valid numbers for Subject ${i + 1}.");
        return;
      }

      if (credit < 2 || credit > 4) {
        _showError("Credit hours must be between 2 and 4 for Subject ${i + 1}.");
        return;
      }

      if (grade < 1 || grade > 4) {
        _showError("Grade points must be between 1.0 and 4.0 for Subject ${i + 1}.");
        return;
      }

      totalPoints += grade * credit;
      totalCredits += credit;
    }

    setState(() {
      cgpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Enter Subject Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          for (int i = 0; i < subjectCount; i++)
            Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text("Subject ${i + 1}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    TextField(
                      controller: creditControllers[i],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Credit Hours (2 - 4)',
                          hintText: 'e.g. 3'),
                    ),
                    TextField(
                      controller: gradeControllers[i],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Grade Points (1.0 - 4.0)',
                          hintText: 'e.g. 3.5'),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _calculateCGPA,
            child: Text('Calculate CGPA'),
          ),
          SizedBox(height: 20),
          Text(
            "Your CGPA: ${cgpa.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                subjectCount++;
                _generateControllers();
              });
            },
            child: Text('Add Subject'),
          ),
        ],
      ),
    );
  }
}

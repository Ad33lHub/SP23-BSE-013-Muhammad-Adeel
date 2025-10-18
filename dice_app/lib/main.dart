//
// import 'dart:math';
// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(DiceGameApp());
// }
//
// class DiceGameApp extends StatefulWidget {
//   @override
//   State<DiceGameApp> createState() => _DiceGameAppState();
// }
//
// class _DiceGameAppState extends State<DiceGameApp> {
//   final _formKey = GlobalKey<FormState>();
//   final List<TextEditingController> nameControllers =
//   List.generate(4, (_) => TextEditingController());
//   final List<TextEditingController> guessControllers =
//   List.generate(4, (_) => TextEditingController());
//
//   List<String> playerNames = [];
//   List<int> guesses = [];
//   int diceNumber = 1;
//   String resultMessage = "";
//   int round = 1;
//   Map<String, int> scores = {};
//
//   bool gameStarted = false;
//   bool roundEnded = false;
//
//   void startGame() {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         playerNames = nameControllers.map((c) => c.text.trim()).toList();
//         scores = {for (var name in playerNames) name: 0};
//         gameStarted = true;
//         round = 1;
//         resultMessage = "";
//       });
//     }
//   }
//
//   void rollDice() {
//     if (playerNames.isEmpty) return;
//
//     // Validate guesses
//     for (int i = 0; i < guessControllers.length; i++) {
//       if (guessControllers[i].text.isEmpty ||
//           int.tryParse(guessControllers[i].text)! < 1 ||
//           int.tryParse(guessControllers[i].text)! > 6) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(
//               "Each player must enter a valid guess (1–6) before rolling."),
//         ));
//         return;
//       }
//     }
//
//     setState(() {
//       roundEnded = true;
//       diceNumber = Random().nextInt(6) + 1;
//       guesses = guessControllers.map((c) => int.parse(c.text)).toList();
//
//       List<String> winners = [];
//       for (int i = 0; i < playerNames.length; i++) {
//         if (guesses[i] == diceNumber) {
//           winners.add(playerNames[i]);
//           scores[playerNames[i]] = (scores[playerNames[i]] ?? 0) + 1;
//         }
//       }
//
//       if (winners.isEmpty) {
//         resultMessage =
//         "Dice rolled: $diceNumber 🎲\nNo one guessed correctly this round!";
//       } else {
//         resultMessage =
//         "Dice rolled: $diceNumber 🎲\nWinner(s): ${winners.join(", ")}";
//       }
//     });
//   }
//
//   void nextRound() {
//     if (round >= 4) {
//       setState(() {
//         roundEnded = true;
//         resultMessage = "🏁 Game Over!\n";
//         int highest = scores.values.reduce(max);
//         List<String> finalWinners = scores.entries
//             .where((entry) => entry.value == highest)
//             .map((e) => e.key)
//             .toList();
//
//         if (finalWinners.length > 1) {
//           resultMessage += "It’s a tie between: ${finalWinners.join(', ')}!";
//         } else {
//           resultMessage += "Winner: ${finalWinners.first} 🏆";
//         }
//       });
//     } else {
//       setState(() {
//         round++;
//         diceNumber = 1;
//         resultMessage = "";
//         roundEnded = false;
//         for (var c in guessControllers) {
//           c.clear();
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Roller Dice Game',
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text("🎲 Roller Dice Game (4 Rounds)"),
//           backgroundColor: Colors.deepPurple,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: gameStarted ? buildGameScreen() : buildSetupScreen(),
//         ),
//       ),
//     );
//   }
//
//   Widget buildSetupScreen() {
//     return SingleChildScrollView(
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             Text(
//               "Enter Player Names",
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             for (int i = 0; i < 4; i++)
//               TextFormField(
//                 controller: nameControllers[i],
//                 decoration: InputDecoration(
//                   labelText: "Player ${i + 1} Name",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return "Enter a valid name";
//                   }
//                   return null;
//                 },
//               ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: startGame,
//               child: Text("Start Game"),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   foregroundColor: Colors.white,
//                   padding:
//                   EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildGameScreen() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Text(
//             "Round $round of 4",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           Divider(),
//           for (int i = 0; i < playerNames.length; i++)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 children: [
//                   Expanded(child: Text("${playerNames[i]}’s Guess (1–6):")),
//                   SizedBox(
//                     width: 80,
//                     child: TextField(
//                       controller: guessControllers[i],
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           SizedBox(height: 20),
//           Image.asset(
//             "images/dice$diceNumber.jpg",
//             height: 150,
//             width: 150,
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: roundEnded ? null : rollDice,
//             child: Text("🎲 Roll Dice"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.deepPurple,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//             ),
//           ),
//           SizedBox(height: 20),
//           if (resultMessage.isNotEmpty)
//             Card(
//               color: Colors.amber.shade100,
//               elevation: 3,
//               margin: EdgeInsets.symmetric(vertical: 10),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   resultMessage,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                 ),
//               ),
//             ),
//           if (roundEnded && round < 4)
//             ElevatedButton(
//               onPressed: nextRound,
//               child: Text("Next Round ➡️"),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white),
//             ),
//           if (roundEnded && round >= 4)
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   gameStarted = false;
//                   for (var c in nameControllers) c.clear();
//                   for (var c in guessControllers) c.clear();
//                 });
//               },
//               child: Text("Restart Game 🔁"),
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red, foregroundColor: Colors.white),
//             ),
//           SizedBox(height: 20),
//           buildScoreBoard(),
//         ],
//       ),
//     );
//   }
//
//   Widget buildScoreBoard() {
//     return Card(
//       elevation: 4,
//       color: Colors.blue.shade50,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               "🏆 Scoreboard",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             for (var entry in scores.entries)
//               Text("${entry.key}: ${entry.value} points",
//                   style: TextStyle(fontSize: 16)),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(DiceGameApp());
}

class DiceGameApp extends StatefulWidget {
  @override
  State<DiceGameApp> createState() => _DiceGameAppState();
}

class _DiceGameAppState extends State<DiceGameApp> {
  final List<TextEditingController> nameControllers =
  List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> guessControllers =
  List.generate(4, (_) => TextEditingController());

  List<String> playerNames = [];
  List<int> guesses = [];
  int diceNumber = 1;
  String resultMessage = "";
  int round = 1;
  Map<String, int> scores = {};

  bool gameStarted = false;
  bool roundEnded = false;

  void startGame() {
    for (var c in nameControllers) {
      if (c.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter all player names!")),
        );
        return;
      }
    }

    setState(() {
      playerNames = nameControllers.map((c) => c.text.trim()).toList();
      scores = {for (var name in playerNames) name: 0};
      gameStarted = true;
      round = 1;
      resultMessage = "";
    });
  }

  void rollDice() {
    if (!gameStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please start the game first!")),
      );
      return;
    }

    // Validate guesses
    for (int i = 0; i < guessControllers.length; i++) {
      if (guessControllers[i].text.isEmpty ||
          int.tryParse(guessControllers[i].text)! < 1 ||
          int.tryParse(guessControllers[i].text)! > 6) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
          Text("Each player must enter a valid guess (1–6) before rolling."),
        ));
        return;
      }
    }

    setState(() {
      roundEnded = true;
      diceNumber = Random().nextInt(6) + 1;
      guesses = guessControllers.map((c) => int.parse(c.text)).toList();

      List<String> winners = [];
      for (int i = 0; i < playerNames.length; i++) {
        if (guesses[i] == diceNumber) {
          winners.add(playerNames[i]);
          scores[playerNames[i]] = (scores[playerNames[i]] ?? 0) + 1;
        }
      }

      if (winners.isEmpty) {
        resultMessage =
        "Dice rolled: $diceNumber 🎲\nNo one guessed correctly this round!";
      } else {
        resultMessage =
        "Dice rolled: $diceNumber 🎲\nWinner(s): ${winners.join(", ")}";
      }
    });
  }

  void nextRound() {
    if (round >= 4) {
      setState(() {
        roundEnded = true;
        resultMessage = "🏁 Game Over!\n";
        int highest = scores.values.reduce(max);
        List<String> finalWinners = scores.entries
            .where((entry) => entry.value == highest)
            .map((e) => e.key)
            .toList();

        if (finalWinners.length > 1) {
          resultMessage += "It’s a tie between: ${finalWinners.join(', ')}!";
        } else {
          resultMessage += "Winner: ${finalWinners.first} 🏆";
        }
      });
    } else {
      setState(() {
        round++;
        diceNumber = 1;
        resultMessage = "";
        roundEnded = false;
        for (var c in guessControllers) c.clear();
      });
    }
  }

  void restartGame() {
    setState(() {
      for (var c in nameControllers) c.clear();
      for (var c in guessControllers) c.clear();
      playerNames.clear();
      scores.clear();
      round = 1;
      gameStarted = false;
      resultMessage = "";
      diceNumber = 1;
      roundEnded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🎲 Roller Dice Game',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("🎲 Roller Dice Game (4 Rounds)"),
          backgroundColor: Colors.deepPurple,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Enter Player Names & Guesses",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              for (int i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: nameControllers[i],
                          decoration: InputDecoration(
                            labelText: "Player ${i + 1} Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: guessControllers[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Guess (1–6)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: gameStarted ? null : startGame,
                child: Text("Start Game ✅"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Round $round of 4",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Image.asset(
                "images/dice$diceNumber.jpg",
                height: 150,
                width: 150,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (gameStarted && !roundEnded) ? rollDice : null,
                child: Text("🎲 Roll Dice"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
              ),
              SizedBox(height: 20),
              if (resultMessage.isNotEmpty)
                Card(
                  color: Colors.amber.shade100,
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      resultMessage,
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              if (roundEnded && round < 4)
                ElevatedButton(
                  onPressed: nextRound,
                  child: Text("Next Round ➡️"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (roundEnded && round >= 4)
                ElevatedButton(
                  onPressed: restartGame,
                  child: Text("Restart Game 🔁"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              SizedBox(height: 20),
              buildScoreBoard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildScoreBoard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "🏆 Scoreboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            for (var entry in scores.entries)
              Text("${entry.key}: ${entry.value} points",
                  style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

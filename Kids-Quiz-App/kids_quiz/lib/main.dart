import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // Home Screen as the initial screen
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.pink[50],
      ),
    );
  }
}

// Home Screen with App Title, Icon, and Continue Button
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cute Icon
            Icon(
              Icons.calculate, // You can use any icon you like
              size: 100,
              color: Colors.pink[300],
            ),
            const SizedBox(height: 20),
            // App Title
            const Text(
              "Multiplication Quiz App",
              style: TextStyle(
                fontSize: 28,
                color: Colors.pink,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // Continue Button
            AnimatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiplicationHome(),
                  ),
                );
              },
              child: const Text("Continue", style: TextStyle(fontSize: 18, color: Colors.white)),
              color: Colors.pink[300]!,
            ),
          ],
        ),
      ),
    );
  }
}

// Multiplication Home Screen
class MultiplicationHome extends StatefulWidget {
  @override
  _MultiplicationHomeState createState() => _MultiplicationHomeState();
}

class _MultiplicationHomeState extends State<MultiplicationHome> {
  int tableNumber = 2;
  int limit = 10;
  double fontSize = 24;
  bool timerEnabled = false;
  int duration = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplication Table Quiz', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink[300],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Table Number:", style: TextStyle(fontSize: 18, color: Colors.pink[800])),
            Slider(
              value: tableNumber.toDouble(),
              min: 1,
              max: 20,
              divisions: 19,
              label: tableNumber.toString(),
              activeColor: Colors.pink[300],
              inactiveColor: Colors.pink[100],
              onChanged: (value) {
                setState(() {
                  tableNumber = value.toInt();
                });
              },
            ),
            Text("Select Limit:", style: TextStyle(fontSize: 18, color: Colors.pink[800])),
            Slider(
              value: limit.toDouble(),
              min: 5,
              max: 20,
              divisions: 15,
              label: limit.toString(),
              activeColor: Colors.pink[300],
              inactiveColor: Colors.pink[100],
              onChanged: (value) {
                setState(() {
                  limit = value.toInt();
                });
              },
            ),
            Text("Font Size:", style: TextStyle(fontSize: 18, color: Colors.pink[800])),
            Slider(
              value: fontSize,
              min: 16,
              max: 40,
              divisions: 12,
              label: fontSize.toString(),
              activeColor: Colors.pink[300],
              inactiveColor: Colors.pink[100],
              onChanged: (value) {
                setState(() {
                  fontSize = value;
                });
              },
            ),
            SwitchListTile(
              title: Text("Enable Timer", style: TextStyle(fontSize: 18, color: Colors.pink[800])),
              value: timerEnabled,
              activeColor: Colors.pink[300],
              onChanged: (bool value) {
                setState(() {
                  timerEnabled = value;
                });
              },
            ),
            if (timerEnabled)
              Slider(
                value: duration.toDouble(),
                min: 5,
                max: 30,
                divisions: 5,
                label: "$duration sec",
                activeColor: Colors.pink[300],
                inactiveColor: Colors.pink[100],
                onChanged: (value) {
                  setState(() {
                    duration = value.toInt();
                  });
                },
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          tableNumber: tableNumber,
                          limit: limit,
                          fontSize: fontSize,
                          timerEnabled: timerEnabled,
                          duration: duration,
                        ),
                      ),
                    );
                  },
                  child: const Text("Start Quiz", style: TextStyle(fontSize: 18, color: Colors.white)),
                  color: Colors.pink[300]!,
                ),
                AnimatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PracticePage(
                          tableNumber: tableNumber,
                          fontSize: fontSize,
                        ),
                      ),
                    );
                  },
                  child: const Text("Practice Mode", style: TextStyle(fontSize: 18, color: Colors.white)),
                  color: Colors.pink[300]!,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Quiz Page
class QuizPage extends StatefulWidget {
  final int tableNumber;
  final int limit;
  final double fontSize;
  final bool timerEnabled;
  final int duration;

  const QuizPage({
    required this.tableNumber,
    required this.limit,
    required this.fontSize,
    required this.timerEnabled,
    required this.duration,
    Key? key,
  }) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int questionIndex = 0;
  int score = 0;
  int timer = 10;
  late Timer countdown;
  late int num;
  late int correctAnswer;
  late List<int> options;
  bool showQuestion = true;

  @override
  void initState() {
    super.initState();
    generateQuestion();
    startTimer();
  }

  void generateQuestion() {
    setState(() {
      num = Random().nextInt(widget.limit) + 1;
      correctAnswer = widget.tableNumber * num;
      options = [
        correctAnswer,
        correctAnswer + 2,
        correctAnswer - 1,
        correctAnswer + 5
      ];
      options.shuffle();
    });
  }

  void startTimer() {
    if (widget.timerEnabled) {
      timer = widget.duration;
      countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (this.timer > 0) {
            this.timer--;
          } else {
            timer.cancel();
            nextQuestion(false);
          }
        });
      });
    }
  }

  void nextQuestion(bool correct) async {
    if (widget.timerEnabled) countdown.cancel();
    setState(() {
      if (correct) score++;
      showQuestion = false;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      questionIndex++;
      if (questionIndex >= widget.limit) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: score,
              totalQuestions: widget.limit,
            ),
          ),
        );
      } else {
        generateQuestion();
        showQuestion = true;
        startTimer();
      }
    });
  }

  @override
  void dispose() {
    if (widget.timerEnabled) countdown.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink[300],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.timerEnabled)
              Text("Time Left: $timer sec", style: TextStyle(fontSize: 18, color: Colors.pink[800])),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: showQuestion
                  ? Column(
                key: ValueKey<int>(questionIndex),
                children: [
                  Text(
                    "${widget.tableNumber} × $num = ?",
                    style: TextStyle(fontSize: widget.fontSize, color: Colors.pink[800]),
                  ),
                  const SizedBox(height: 20),
                  ...options.map((answer) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AnimatedButton(
                      onPressed: () => nextQuestion(answer == correctAnswer),
                      child: Text(answer.toString(),
                          style: const TextStyle(fontSize: 20, color: Colors.white)),
                      color: Colors.pink[300]!,
                    ),
                  )),
                ],
              )
                  : const SizedBox.shrink(),
            ),
            Text("Score: $score", style: TextStyle(fontSize: 20, color: Colors.pink[800])),
          ],
        ),
      ),
    );
  }
}

// Practice Page
class PracticePage extends StatefulWidget {
  final int tableNumber;
  final double fontSize;

  const PracticePage({
    required this.tableNumber,
    required this.fontSize,
    Key? key,
  }) : super(key: key);

  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late int num;
  late int correctAnswer;
  late List<int> options;

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    setState(() {
      num = Random().nextInt(10) + 1;
      correctAnswer = widget.tableNumber * num;
      options = [
        correctAnswer,
        correctAnswer + 2,
        correctAnswer - 1,
        correctAnswer + 5
      ];
      options.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Practice Mode", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink[300],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${widget.tableNumber} × $num = ?",
              style: TextStyle(fontSize: widget.fontSize, color: Colors.pink[800]),
            ),
            const SizedBox(height: 20),
            ...options.map((answer) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: AnimatedButton(
                onPressed: () {
                  // Show SnackBar for Correct/Incorrect feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        answer == correctAnswer ? "Correct!" : "Incorrect!",
                        style: const TextStyle(fontSize: 20),
                      ),
                      backgroundColor: answer == correctAnswer ? Colors.green : Colors.red,
                    ),
                  );
                  // Remove the automatic question generation here
                },
                child: Text(answer.toString(),
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                color: Colors.pink[300]!,
              ),
            )),
            const SizedBox(height: 20),
            // New Question Button
            AnimatedButton(
              onPressed: generateQuestion,
              child: const Text("New Question", style: TextStyle(fontSize: 18, color: Colors.white)),
              color: Colors.pink[300]!,
            ),
          ],
        ),
      ),
    );
  }
}

// Animated Button
class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;

  const AnimatedButton({
    required this.onPressed,
    required this.child,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// Result Screen
class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({
    required this.score,
    required this.totalQuestions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink[300],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Your Score: $score / $totalQuestions",
              style: TextStyle(fontSize: 24, color: Colors.pink[800]),
            ),
            const SizedBox(height: 20),
            AnimatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Back to Home", style: TextStyle(fontSize: 18, color: Colors.white)),
              color: Colors.pink[300]!,
            ),
          ],
        ),
      ),
    );
  }
}
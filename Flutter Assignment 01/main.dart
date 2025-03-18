import 'package:flutter/material.dart';

void main() => runApp(const FlashcardApp());

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Fredoka', // Use a cute font (add it to pubspec.yaml).
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.pinkAccent,
          secondary: Colors.blueAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class Flashcard {
  final String question;
  final String answer;
  bool isCorrect;

  Flashcard({required this.question, required this.answer, this.isCorrect = false});
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAD0C4), Color(0xFFFFD1FF)], // Pastel gradient.
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Flashcard Quiz 🎀",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 40),
              _buildSeriesButton(context, "Flutter Series 🦋", flutterSeries),
              const SizedBox(height: 20),
              _buildSeriesButton(context, "Dart Series 🎯", dartSeries),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeriesButton(BuildContext context, String title, List<Flashcard> series) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FlashcardScreen(series: series)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.pinkAccent,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        shadowColor: Colors.pinkAccent.withOpacity(0.3),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

final List<Flashcard> flutterSeries = [
  Flashcard(question: "Which company developed Flutter?", answer: "Google"),
  Flashcard(question: "What UI rendering engine does Flutter use?", answer: "Skia"),
  Flashcard(question: "Which widget type doesn’t change its state?", answer: "Stateless"),
  Flashcard(question: "What command is used to create a new Flutter project?", answer: "flutter create"),
  Flashcard(question: "Which file manages dependencies in Flutter?", answer: "pubspec.yaml"),
];

final List<Flashcard> dartSeries = [
  Flashcard(question: "Which language does Flutter use?", answer: "Dart"),
  Flashcard(question: "What keyword is used to declare a constant variable?", answer: "const"),
  Flashcard(question: "Which data type holds multiple values of the same type?", answer: "List"),
  Flashcard(question: "What keyword is used for asynchronous functions?", answer: "async"),
  Flashcard(question: "What type of programming language is Dart?", answer: "Object-oriented"),
];

class FlashcardScreen extends StatefulWidget {
  final List<Flashcard> series;
  const FlashcardScreen({Key? key, required this.series}) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int currentIndex = 0;
  bool showAnswer = false;
  int score = 0;

  void nextCard(bool isCorrect) {
    setState(() {
      widget.series[currentIndex].isCorrect = isCorrect;
      if (isCorrect) score++;
      if (currentIndex < widget.series.length - 1) {
        currentIndex++;
        showAnswer = false;
      } else {
        _showScoreDialog();
      }
    });
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Completed 🎉", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          "Your Score: $score/${widget.series.length}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAD0C4), Color(0xFFFFD1FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NEW: Add the progress text here
            Text(
              "Question ${currentIndex + 1} of ${widget.series.length}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 10), // NEW: Adds spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / widget.series.length,
                backgroundColor: Colors.white.withOpacity(0.3),
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => setState(() => showAnswer = !showAnswer),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  showAnswer ? widget.series[currentIndex].answer : widget.series[currentIndex].question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => nextCard(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Bright green for "Correct".
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Correct ✅",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => nextCard(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Bright red for "Incorrect".
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Incorrect ❌",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

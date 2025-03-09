import 'package:flutter/material.dart';

// Main function jo Flutter app ko run karegi
void main() => runApp(const MaterialApp(
  home: FlashcardScreen(), // Home screen ko FlashcardScreen set kiya gaya hai
));

// Flashcard class jo ek single flashcard ko represent karti hai
class Flashcard {
  final String question; // Flashcard ka sawal
  final String answer;   // Flashcard ka jawab

  const Flashcard({required this.question, required this.answer});
}

// FlashcardScreen class, jo app ka main screen hai
class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({Key? key}) : super(key: key);

  // Flashcards ki list jo pehle se define ki gayi hai
  static const List<Flashcard> flashcards = [
    Flashcard(question: "What is the capital of France?", answer: "Paris"),
    Flashcard(question: "What is 5 + 2?", answer: "7"),
    Flashcard(question: "What is 2 + 2?", answer: "4"),
    Flashcard(question: "What is the largest planet?", answer: "Jupiter"),
    Flashcard(question: "Who wrote 'Romeo and Juliet'?", answer: "Shakespeare"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: Colors.blueAccent, // AppBar ka color change kiya gaya hai
      ),
      body: Container(
        color: Colors.grey[100], // Background color light grey set kiya gaya hai
        child: ListView.builder(
          padding: const EdgeInsets.all(8), // ListView ke around padding
          itemCount: flashcards.length, // List mein items ki tadad
          itemBuilder: (context, index) {
            // Har flashcard ke liye ek FlashcardWidget banaya jaa raha hai
            return FlashcardWidget(flashcard: flashcards[index]);
          },
        ),
      ),
    );
  }
}

// FlashcardWidget class, jo ek single flashcard ko dikhata hai
class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard; // Flashcard jo display hogi
  const FlashcardWidget({Key? key, required this.flashcard}) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

// FlashcardWidget ki state class
class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool showAnswer = false; // State variable jo sawal aur jawab ke darmiyan toggle karegi

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Jab card pe tap kiya jaye to showAnswer ko toggle karo
        setState(() => showAnswer = !showAnswer);
      },
      child: Card(
        elevation: 4, // Card ki elevation (shadow) set ki gayi hai
        color: showAnswer ? Colors.green[50] : Colors.blue[50], // Card ka color toggle ke hisab se change hoga
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Card ke andar padding
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300), // Animation ki duration
            child: Text(
              // Agar showAnswer true hai to jawab dikhao, warna sawal dikhao
              showAnswer ? widget.flashcard.answer : widget.flashcard.question,
              key: ValueKey(showAnswer), // Animation ko trigger karne ke liye key
              textAlign: TextAlign.center, // Text ko center-align karo
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: showAnswer ? Colors.green[800] : Colors.blue[800], // Text color toggle ke hisab se change hoga
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:math';

class CalculatorBrain {
  // Constructor with required parameters
  CalculatorBrain({required this.height, required this.weight});

  final int height;
  final int weight;

  double? _bmi;  // Make _bmi nullable

  // Method to calculate BMI
  String calculateBMI() {
    _bmi = weight / pow(height / 100, 2);
    return _bmi!.toStringAsFixed(1); // Using ! because _bmi will not be null after calculateBMI is called
  }

  // Method to get the BMI result
  String getResult() {
    if (_bmi! >= 25) {
      return 'Overweight';
    } else if (_bmi! > 18.5) {
      return 'Normal';
    } else {
      return 'Underweight';
    }
  }

  // Method to get the interpretation of the BMI result
  String getInterpretation() {
    if (_bmi! >= 25) {
      return 'You have a higher than normal body weight. Try to exercise more.';
    } else if (_bmi! >= 18.5) {
      return 'You have a normal body weight. Good job!';
    } else {
      return 'You have a lower than normal body weight. You can eat a bit more.';
    }
  }
}

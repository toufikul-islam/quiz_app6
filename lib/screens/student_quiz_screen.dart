import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/student.dart';
import 'student_result_screen.dart';
import 'home_screen.dart';

class StudentQuizScreen extends StatefulWidget {
  final List<Question> questions;
  final Student student;
  final String category;

  const StudentQuizScreen({
    super.key,
    required this.questions,
    required this.student,
    required this.category,
  });

  @override
  State<StudentQuizScreen> createState() => _StudentQuizScreenState();
}

class _StudentQuizScreenState extends State<StudentQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _answered = false;

  void _answerQuestion(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;

      if (answer == widget.questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentResultScreen(
            score: _score,
            totalQuestions: widget.questions.length,
            student: widget.student,
            category: widget.category,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Question ${_currentQuestionIndex + 1}/${widget.questions.length}'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Leave Quiz?'),
                  content: const Text('Are you sure you want to leave? Your progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Leave'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Home',
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            minHeight: 8,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.deepPurple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildAnswerButton('A', question.optionA, question),
                  const SizedBox(height: 12),
                  _buildAnswerButton('B', question.optionB, question),
                  const SizedBox(height: 12),
                  _buildAnswerButton('C', question.optionC, question),
                  const SizedBox(height: 12),
                  _buildAnswerButton('D', question.optionD, question),
                  const SizedBox(height: 32),
                  if (_answered)
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentQuestionIndex < widget.questions.length - 1
                              ? 'Next Question'
                              : 'See Results',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String letter, String text, Question question) {
    final isSelected = _selectedAnswer == letter;
    final isCorrect = question.correctAnswer == letter;
    final showCorrect = _answered && isCorrect;
    final showIncorrect = _answered && isSelected && !isCorrect;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (showCorrect) {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade900;
      borderColor = Colors.green;
    } else if (showIncorrect) {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade900;
      borderColor = Colors.red;
    } else if (isSelected) {
      backgroundColor = Colors.deepPurple.shade100;
      textColor = Colors.deepPurple.shade900;
      borderColor = Colors.deepPurple;
    } else {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
      borderColor = Colors.grey.shade400;
    }

    return InkWell(
      onTap: () => _answerQuestion(letter),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: showCorrect
                    ? Colors.green
                    : showIncorrect
                        ? Colors.red
                        : isSelected
                            ? Colors.deepPurple
                            : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    color: (showCorrect || showIncorrect || isSelected)
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (showCorrect)
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
            if (showIncorrect)
              const Icon(Icons.cancel, color: Colors.red, size: 28),
          ],
        ),
      ),
    );
  }
}

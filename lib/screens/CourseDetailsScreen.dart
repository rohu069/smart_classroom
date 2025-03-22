import 'package:flutter/material.dart';
import 'assignments.dart';
import 'classes.dart';
import 'quiz.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  
  const CourseDetailsScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ClassesScreen(),
    AssignmentScreen(),
    QuizScreen(),
  ];

  Widget _buildNavButton(String title, IconData icon, int index, Color color) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedIndex == index ? color : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Course Details")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildNavButton('Classes', Icons.class_rounded, 0, Colors.blue),
                const SizedBox(width: 16),
                _buildNavButton('Assignments', Icons.assignment_rounded, 1, Colors.green),
                const SizedBox(width: 16),
                _buildNavButton('Quizzes', Icons.quiz_rounded, 2, Colors.orange),
              ],
            ),
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

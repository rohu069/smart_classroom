import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'add_notes.dart'; // Import Add Notes Screen

class ManageCoursesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> courses;

  const ManageCoursesScreen({Key? key, required this.courses}) : super(key: key);

  @override
  _ManageCoursesScreenState createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Courses")),
      body: widget.courses.isEmpty
          ? const Center(child: Text("You haven't created any courses yet."))
          : ListView.builder(
              itemCount: widget.courses.length,
              itemBuilder: (context, index) {
                final course = widget.courses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ExpansionTile(
                    title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "Students Enrolled: ${(course['students'] is List ? course['students'].length : (course['students'] ?? 0))}"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Copy Link
                            if (course['courseLink'] != null)
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: course['courseLink']));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Link copied to clipboard!"),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    const Text(
                                      "Group Link → ",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                    const Icon(Icons.content_copy, color: Colors.blue, size: 20),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 5),

                            // Action Buttons
                            Card(
                              elevation: 2,
                              color: Colors.blue[50],
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: const Text("Add Notes"),
                                      trailing: const Icon(Icons.note_add, color: Colors.blue),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddNotesScreen(courseId: course['id']),
                                          ),
                                        );
                                      },
                                    ),
                                  ListTile(
  title: const Text("Assignments"),
  trailing: const Icon(Icons.assignment, color: Colors.green),
  onTap: () {
    Navigator.pushNamed(context, '/manage_assignments');
  },
),
ListTile(
  title: const Text("Quizzes"),
  trailing: const Icon(Icons.quiz, color: Colors.orange),
  onTap: () {
    Navigator.pushNamed(context, '/manage_quizzes');
  },
),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

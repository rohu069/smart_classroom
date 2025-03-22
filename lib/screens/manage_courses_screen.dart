import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

class ManageCoursesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> courses; // Courses list

  const ManageCoursesScreen({Key? key, required this.courses}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Courses")),
      body: courses.isEmpty
          ? const Center(child: Text("You haven't created any courses yet."))
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Students Enrolled: ${(course['students'] is List ? course['students'].length : (course['students'] ?? 0))}"),
                        if (course['courseLink'] != null) // Show only if link exists
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  launchUrl(Uri.parse(course['courseLink']));
                                },
                                child: const Text(
                                  "Open Link",
                                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                              ),
                              const SizedBox(width: 10), // Space between options
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: course['courseLink']));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Link copied to clipboard!")),
                                  );
                                },
                                child: const Text(
                                  "Copy Link",
                                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.indigo),
                    onTap: () {
                      // Future: Navigate to a detailed course management screen
                    },
                  ),
                );
              },
            ),
    );
  }
}

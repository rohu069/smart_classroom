import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample_classroom/screens/CourseDetailsScreen.dart';


class CoursesScreen extends StatefulWidget {
  final String userId;
  const CoursesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  Stream<List<Map<String, dynamic>>> getUserEnrolledCourses(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots().asyncMap((snapshot) async {
      List<dynamic> enrolledCourses = snapshot.data()?['enrolledCourses'] ?? [];
      if (enrolledCourses.isEmpty) return [];

      List<Future<Map<String, dynamic>?>> courseFutures = enrolledCourses.map((courseId) async {
        DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();
        if (courseSnapshot.exists) {
          return {
            'id': courseSnapshot.id,
            'title': courseSnapshot['title'],
            'description': courseSnapshot['description'],
          };
        }
        return null;
      }).toList();

      List<Map<String, dynamic>> courses = (await Future.wait(courseFutures)).whereType<Map<String, dynamic>>().toList();
      return courses;
    });
  }

Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Column(
      children: [
        ListTile(
          title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(course['description']),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to Course Details Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailsScreen(courseId: course['id']),
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/assignments');
              },
              child: const Text("Assignments"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quiz');
              },
              child: const Text("Quiz"),
            ),
          ],
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Learning Dashboard')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Courses', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getUserEnrolledCourses(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No courses enrolled yet."));
                }
                var courses = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return _buildCourseCard(context, courses[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Implement join class feature
        child: const Icon(Icons.add),
      ),
    );
  }
}

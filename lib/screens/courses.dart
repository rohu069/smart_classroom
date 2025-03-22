import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sample_classroom/screens/assignments.dart';
import 'classes.dart';
import 'quiz.dart';

class CoursesScreen extends StatefulWidget {
  final String userId;
  const CoursesScreen({super.key, required this.userId});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {


  void _enrollInCourse(String courseId) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance.collection("courses").doc(courseId).update({
        'students': FieldValue.arrayUnion([user.uid])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enrolled Successfully!"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enrollment Failed: $e"))
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in"))
    );
  }
}



Future<void> joinCourse(String userId, String courseId) async {
  DocumentReference courseRef = FirebaseFirestore.instance.collection('courses').doc(courseId);
  DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  try {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot courseSnapshot = await transaction.get(courseRef);
      DocumentSnapshot userSnapshot = await transaction.get(userRef);

      // Ensure data exists and cast it properly
      Map<String, dynamic>? courseData = courseSnapshot.data() as Map<String, dynamic>?;
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (courseData == null || userData == null) {
        throw Exception("Document data is null");
      }

      List students = List.from(courseData['studentsEnrolled'] ?? []);
      if (!students.contains(userId)) {
        students.add(userId);
        transaction.update(courseRef, {'studentsEnrolled': students});
      }

      List enrolledCourses = List.from(userData['enrolledCourses'] ?? []);
      if (!enrolledCourses.contains(courseId)) {
        enrolledCourses.add(courseId);
        transaction.update(userRef, {'enrolledCourses': enrolledCourses});
      }
    });

    // Force UI refresh
    if (mounted) {
      setState(() {});
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error joining the course: $e")),
      );
    }
  }
}

Stream<List<Map<String, dynamic>>> getUserEnrolledCourses(String userId) {
  return FirebaseFirestore.instance.collection('users').doc(userId).snapshots().asyncMap((snapshot) async {
    List<dynamic> enrolledCourses = snapshot.data()?['enrolledCourses'] ?? [];

    if (enrolledCourses.isEmpty) return [];

    List<Future<Map<String, dynamic>?>> courseFutures = enrolledCourses.map((courseId) async {
      DocumentSnapshot courseSnapshot =
          await FirebaseFirestore.instance.collection('courses').doc(courseId).get();

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

  void _showJoinClassDialog(BuildContext context) {
    TextEditingController linkController = TextEditingController();
    bool isValidLink = false;
    String? courseId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Enter Course Link"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: linkController,
                    decoration: const InputDecoration(
                      labelText: "Paste Course Link",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  isValidLink
                      ? ElevatedButton(
                          onPressed: () async {
                            if (courseId != null) {
                              await joinCourse(widget.userId, courseId!);

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Successfully joined the course!")),
                                );
                              }
                            }
                          },
                          child: const Text("Join Class"),
                        )
                      : Container(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    String link = linkController.text.trim();
                    if (link.isNotEmpty) {
                      Uri uri = Uri.tryParse(link) ?? Uri();
                      String? extractedCourseId =
                          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;

                      if (extractedCourseId != null) {
                        try {
                          DocumentSnapshot courseDoc = await FirebaseFirestore.instance
                              .collection('courses')
                              .doc(extractedCourseId)
                              .get();

                          if (courseDoc.exists) {
                            setState(() {
                              isValidLink = true;
                              courseId = extractedCourseId;
                            });
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Invalid Course Link")),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Error fetching course details")),
                            );
                          }
                        }
                      }
                    }
                  },
                  child: const Text("Check Link"),
                ),
              ],
            );
          },
        );
      },
    );
  }

Widget _buildNavButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, String courseId) {
  return ElevatedButton(
    onPressed: () => _enrollInCourse(courseId), // Now courseId is passed correctly
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
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
  );
}

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(course['title']),
        subtitle: Text(course['description']),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to course details (implement this if needed)
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('My Learning Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              children: [
Expanded(
  child: _buildNavButton(
    context,
    'Classes',
    Icons.class_rounded,
    Theme.of(context).colorScheme.primary,
    () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ClassesScreen(),
        ),
      );
    },
    "", // Add this empty courseId as a placeholder
  ),
),

                const SizedBox(width: 16),
 Expanded(
  child: _buildNavButton(
    context,
    'Assignments',
    Icons.assignment_rounded,
    Theme.of(context).colorScheme.secondary,
    () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AssignmentScreen(),
        ),
      );
    },
    "", // Add missing courseId argument
  ),
),

                const SizedBox(width: 16),
Expanded(
  child: _buildNavButton(
    context,
    'Quizzes',
    Icons.quiz_rounded,
    Theme.of(context).colorScheme.tertiary,
    () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(),
        ),
      );
    },
    "", // Add missing courseId argument
  ),
),

              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Courses',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>( 
              stream: getUserEnrolledCourses(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No courses enrolled yet."));
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
        onPressed: () => _showJoinClassDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:sample_classroom/screens/manage_courses_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_signup.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  String teacherName = "Teacher";
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
  }

Future<void> _fetchTeacherData() async {
  setState(() {
    isLoading = true;
  });

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    if (userDoc.exists) {
      setState(() {  // Update teacherName inside setState()
        teacherName = userDoc["name"] ?? "Teacher";
      });
    }

    QuerySnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection("courses")
        .where("teacherId", isEqualTo: user.uid)
        .get();

    List<Map<String, dynamic>> loadedCourses = [];
    for (var doc in courseSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      loadedCourses.add({
        'id': doc.id,
        'title': data['title'] ?? 'Untitled',
        'description': data['description'] ?? 'No description available',
        'students': data['students'] ?? 0,
        'courseLink': data['courseLink'] ?? "https://sampleclassrooms.com/course/${doc.id}",
      });
    }

    setState(() {
      courses = loadedCourses;
      isLoading = false;
    });
  } else {
    setState(() {
      isLoading = false;
    });
  }
}

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
    );
  }

  void _addNewCourse() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return AddCourseForm(
          onCourseAdded: () {
            _fetchTeacherData();
            Navigator.pop(context);
          },
        );
      },
    );
  }

Future<void> createCourse(String title, String description) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentReference docRef = await FirebaseFirestore.instance.collection("courses").add({
      'title': title,
      'description': description,
      'teacherId': user.uid,
      'students': 0,
      'courseLink': "https://sampleclassrooms.com/course/${user.uid}", // Ensure it's stored
    });

    // Update the document with the correct link if needed
    await docRef.update({
      'courseLink': "https://sampleclassrooms.com/course/${docRef.id}"
    });
  }
}


void launchURL(String url) async {
  Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    print("Could not launch $url");
  }
}

Widget _smallActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}



Widget _statCard(String title, String value, IconData icon) {
  return Expanded(
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.indigo),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
      ),
    ),
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.indigo,
      title: Text(
        "Welcome, $teacherName",
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
          tooltip: "Logout",
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _addNewCourse,
      backgroundColor: Colors.indigo,
      child: const Icon(Icons.add),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  color: Colors.indigo,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _statCard("Total Courses", "${courses.length}", Icons.book),
                          const SizedBox(width: 16),
                          _statCard("Total Students", "${courses.fold(0, (sum, course) {
                            var students = course['students'];
                            int studentCount = (students is List) ? students.length : (students is int ? students : 0);
                            return sum + studentCount;
                          })}", Icons.people),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          _smallActionCard(
                            "Manage Courses",
                            Icons.book,
                            Colors.blue[700]!,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageCoursesScreen(courses: courses),
                                ),
                              );
                            },
                          ),
                          _smallActionCard("Profile", Icons.person, Colors.purple[700]!, () {
                            // Navigate to profile screen
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
  );
}
}

class AddCourseForm extends StatefulWidget {
  final VoidCallback onCourseAdded;

  const AddCourseForm({Key? key, required this.onCourseAdded}) : super(key: key);

  @override
  _AddCourseFormState createState() => _AddCourseFormState();
}

class _AddCourseFormState extends State<AddCourseForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _submitForm() {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();

    if (title.isNotEmpty && description.isNotEmpty) {
      // You can add a method here to save the course in Firestore
      widget.onCourseAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add New Course",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Course Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Course Description"),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text("Add Course"),
            ),
          ],
        ),
      ),
    );
  }
}

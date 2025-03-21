import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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
      teacherName = userDoc["name"] ?? "Teacher";
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
                            _statCard("Total Students", 
                              "${courses.fold(0, (sum, course) => sum + (course['students'] as int))}", 
                              Icons.people),
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
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _actionCard("Manage Courses", Icons.book, Colors.blue[700]!, () {
                              // Navigate to courses management screen
                            }),
                            _actionCard("Manage Students", Icons.people, Colors.green[700]!, () {
                              // Navigate to student management screen
                            }),
                            _actionCard("Assignments", Icons.assignment, Colors.orange[700]!, () {
                              // Navigate to assignments screen
                            }),
                            _actionCard("Profile", Icons.person, Colors.purple[700]!, () {
                              // Navigate to profile screen
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // My Courses Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Courses",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _addNewCourse,
                          child: const Text("Add New"),
                        ),
                      ],
                    ),
                  ),
                  
                  courses.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  "You don't have any courses yet",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _addNewCourse,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                  ),
                                  child: const Text("Create Your First Course"),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return _courseCard(course);
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _courseCard(Map<String, dynamic> course) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Course Link as Text (with Copy Feature)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: course['courseLink']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Course link copied!")),
                  );
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        course['courseLink'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.blue),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: course['courseLink']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Course link copied!")),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

// Add Course Form Widget
class AddCourseForm extends StatefulWidget {
  final VoidCallback onCourseAdded;

  const AddCourseForm({Key? key, required this.onCourseAdded}) : super(key: key);

  @override
  State<AddCourseForm> createState() => _AddCourseFormState();
}

class _AddCourseFormState extends State<AddCourseForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('courses').add({
            'title': _titleController.text,
            'description': _descriptionController.text,
                 'https://via.placeholder.com/300x150?text=Course'
                : _imageUrlController.text,
            'teacherId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'students': 0,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course added successfully!')),
          );
          widget.onCourseAdded();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding course: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Add New Course",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Course Title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Course Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Add Course",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
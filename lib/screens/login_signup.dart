import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sample_classroom/screens/teacher_dashboard_screen.dart';
import 'courses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedRole = 'student'; // Default role

  Future<void> _signUp() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "role": selectedRole,
        "userId": userCredential.user!.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        isLogin = true;
        nameController.clear();
        phoneController.clear();
        emailController.clear();
        passwordController.clear();
      });
    } catch (e) {
      _showError("Signup Error: $e");
    }
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc.data().toString().contains('role')
            ? userDoc["role"]
            : "student";

        if (selectedRole == "teacher" && role == "teacher") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const TeacherDashboardScreen()),
          );
        } else if (selectedRole == "student" && role == "student") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CoursesScreen(userId: userCredential.user!.uid)),
          );
        } else {
          _showError("You are not registered as a $selectedRole.");
        }
      } else {
        _showError("User not found in database.");
      }
    } catch (e) {
      _showError("Login Error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Smart Learning',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Education at your fingertips',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isLogin ? 'Welcome Back' : 'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Input Fields
                        if (!isLogin) ...[
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Role Selection
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          items: [
                            DropdownMenuItem(value: 'student', child: Text('Student')),
                            DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Role',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),

                        // Login / SignUp Button
                        ElevatedButton(
                          onPressed: () {
                            if (isLogin) {
                              _login();
                            } else {
                              _signUp();
                            }
                          },
                          child: Text(isLogin ? 'Login' : 'Sign Up'),
                        ),
                        const SizedBox(height: 16),

                        // Toggle between Login and Signup
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(
                            isLogin ? 'New user? Create an account' : 'Already have an account? Login',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

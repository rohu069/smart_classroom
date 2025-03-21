import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Sample quiz data
  final List<Map<String, dynamic>> quizzes = [
    {
      'title': 'Flutter Basics',
      'course': 'Introduction to Flutter',
      'questions': 15,
      'timeLimit': '20 minutes',
      'dueDate': 'Mar 24, 2025',
      'status': 'Upcoming',
      'description': 'Test your knowledge of Flutter basics, widgets, and state management.',
    },
    {
      'title': 'Data Structures Quiz',
      'course': 'Data Structures & Algorithms',
      'questions': 20,
      'timeLimit': '30 minutes',
      'dueDate': 'Mar 22, 2025',
      'status': 'Completed',
      'score': 85,
      'description': 'Quiz covering arrays, linked lists, stacks, and queues.',
    },
    {
      'title': 'Machine Learning Concepts',
      'course': 'Machine Learning Fundamentals',
      'questions': 25,
      'timeLimit': '40 minutes',
      'dueDate': 'Mar 26, 2025',
      'status': 'Upcoming',
      'description': 'Test your understanding of supervised and unsupervised learning algorithms.',
    },
    {
      'title': 'React Fundamentals',
      'course': 'Web Development with React',
      'questions': 18,
      'timeLimit': '25 minutes',
      'dueDate': 'Mar 19, 2025',
      'status': 'Completed',
      'score': 92,
      'description': 'Quiz on React components, props, state, and hooks.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final upcomingQuizzes = quizzes.where((q) => q['status'] == 'Upcoming').toList();
    final completedQuizzes = quizzes.where((q) => q['status'] == 'Completed').toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Quizzes'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Performance summary
              Card(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Your Quiz Performance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPerformanceItem(
                            context,
                            'Average Score',
                            '88.5%',
                            Icons.insert_chart,
                          ),
                          _buildPerformanceItem(
                            context,
                            'Completed',
                            '${completedQuizzes.length}/${quizzes.length}',
                            Icons.check_circle,
                          ),
                          _buildPerformanceItem(
                            context,
                            'Upcoming',
                            upcomingQuizzes.length.toString(),
                            Icons.event,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Upcoming quizzes section
              Text(
                'Upcoming Quizzes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              
              if (upcomingQuizzes.isEmpty) ...[
                _buildEmptyState(
                  context,
                  'No upcoming quizzes',
                  'You\'re all caught up for now',
                ),
              ] else ...[
                for (var quiz in upcomingQuizzes) _buildQuizCard(context, quiz),
              ],
              
              const SizedBox(height: 24),
              
              // Completed quizzes section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed Quizzes',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (completedQuizzes.isEmpty) ...[
                _buildEmptyState(
                  context,
                  'No completed quizzes',
                  'You haven\'t completed any quizzes yet',
                ),
              ] else ...[
                for (var quiz in completedQuizzes.take(2)) _buildQuizCard(context, quiz),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        icon: const Icon(Icons.search),
        label: const Text('Find Quizzes'),
      ),
    );
  }

  Widget _buildPerformanceItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.tertiary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, Map<String, dynamic> quiz) {
    final bool isCompleted = quiz['status'] == 'Completed';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.quiz,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz['title'],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz['course'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${quiz['score']}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQuizDetail(
                  context,
                  'Questions',
                  quiz['questions'].toString(),
                  Icons.help_outline,
                ),
                const SizedBox(width: 16),
                _buildQuizDetail(
                  context,
                  'Time',
                  quiz['timeLimit'],
                  Icons.timer,
                ),
                const SizedBox(width: 16),
                _buildQuizDetail(
                  context,
                  'Due',
                  quiz['dueDate'],
                  Icons.event,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              quiz['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isCompleted) ...[
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.analytics),
                    label: const Text('Review'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizDetail(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
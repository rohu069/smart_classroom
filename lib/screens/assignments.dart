import 'package:flutter/material.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({Key? key}) : super(key: key);

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  // Assignment status filter
  String _currentFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Submitted', 'Graded'];

  // Sample assignment data
  final List<Map<String, dynamic>> assignments = [
    {
      'title': 'Flutter UI Challenge',
      'course': 'Introduction to Flutter',
      'dueDate': 'Mar 25, 2025',
      'status': 'Pending',
      'points': 100,
      'description': 'Create a mobile app UI for a smart learning platform.',
    },
    {
      'title': 'Binary Search Tree Implementation',
      'course': 'Data Structures & Algorithms',
      'dueDate': 'Mar 23, 2025',
      'status': 'Submitted',
      'points': 80,
      'earnedPoints': 75,
      'description': 'Implement a Binary Search Tree with insertion, deletion, and search operations.',
    },
    {
      'title': 'Linear Regression Model',
      'course': 'Machine Learning Fundamentals',
      'dueDate': 'Mar 28, 2025',
      'status': 'Pending',
      'points': 120,
      'description': 'Build a linear regression model to predict housing prices.',
    },
    {
      'title': 'React Component Library',
      'course': 'Web Development with React',
      'dueDate': 'Mar 20, 2025',
      'status': 'Graded',
      'points': 150,
      'earnedPoints': 142,
      'description': 'Create a reusable component library for React applications.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter assignments
    List<Map<String, dynamic>> filteredAssignments = _currentFilter == 'All'
        ? assignments
        : assignments.where((a) => a['status'] == _currentFilter).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Assignments'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return FilterChip(
                    label: Text(_filters[index]),
                    selected: _currentFilter == _filters[index],
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = _filters[index];
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.secondary,
                    labelStyle: TextStyle(
                      color: _currentFilter == _filters[index]
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.black,
                      fontWeight: _currentFilter == _filters[index]
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),

          // Assignments summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildSummaryCard(
                  context,
                  'Pending',
                  assignments.where((a) => a['status'] == 'Pending').length.toString(),
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  context,
                  'Submitted',
                  assignments.where((a) => a['status'] == 'Submitted').length.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  context,
                  'Graded',
                  assignments.where((a) => a['status'] == 'Graded').length.toString(),
                  Colors.green,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Assignments list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              filteredAssignments.isEmpty
                  ? 'No Assignments'
                  : '${filteredAssignments.length} Assignment${filteredAssignments.length > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          
          Expanded(
            child: filteredAssignments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No assignments found',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = filteredAssignments[index];
                      return _buildAssignmentCard(context, assignment);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String count,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Map<String, dynamic> assignment) {
    Color statusColor;
    IconData statusIcon;
    
    switch (assignment['status']) {
      case 'Pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'Submitted':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Graded':
        statusColor = Colors.green;
        statusIcon = Icons.grading;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.assignment;
    }
    
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
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment['title'],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment['course'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${assignment['dueDate']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  statusIcon,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  assignment['status'],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  assignment['status'] == 'Graded'
                      ? '${assignment['earnedPoints']}/${assignment['points']}'
                      : '${assignment['points']} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              assignment['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (assignment['status'] == 'Pending') ...[
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    child: const Text('Upload'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: const Text('Start'),
                  ),
                ] else if (assignment['status'] == 'Submitted') ...[
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('View Submission'),
                  ),
                ] else if (assignment['status'] == 'Graded') ...[
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('View Feedback'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
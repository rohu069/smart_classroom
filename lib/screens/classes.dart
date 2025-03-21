import 'package:flutter/material.dart';

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample class schedule data
    final List<Map<String, dynamic>> classes = [
      {
        'title': 'Flutter Development',
        'time': '9:00 AM - 10:30 AM',
        'instructor': 'Dr. Sarah Johnson',
        'room': 'Virtual Room 1',
        'day': 'Monday',
        'isLive': true,
      },
      {
        'title': 'Data Structures',
        'time': '11:00 AM - 12:30 PM',
        'instructor': 'Prof. Michael Lee',
        'room': 'Room 203',
        'day': 'Monday',
        'isLive': false,
      },
      {
        'title': 'Machine Learning Lab',
        'time': '2:00 PM - 4:00 PM',
        'instructor': 'Dr. Emily Chen',
        'room': 'Lab 105',
        'day': 'Wednesday',
        'isLive': false,
      },
      {
        'title': 'Web Development Workshop',
        'time': '10:00 AM - 12:00 PM',
        'instructor': 'John Smith',
        'room': 'Virtual Room 3',
        'day': 'Thursday',
        'isLive': false,
      },
      {
        'title': 'Mobile App Design',
        'time': '1:00 PM - 3:00 PM',
        'instructor': 'Jessica Thompson',
        'room': 'Design Studio',
        'day': 'Friday',
        'isLive': false,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('My Classes'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming class highlight
          if (classes.any((cls) => cls['isLive'])) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Live Now',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLiveClassCard(
                context,
                classes.firstWhere((cls) => cls['isLive']),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Class schedule
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week\'s Schedule',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Calendar'),
                ),
              ],
            ),
          ),
          
          // Schedule tabs
          DefaultTabController(
            length: 5,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Monday'),
                    Tab(text: 'Tuesday'),
                    Tab(text: 'Wednesday'),
                    Tab(text: 'Thursday'),
                    Tab(text: 'Friday'),
                  ],
                ),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    children: [
                      _buildDaySchedule(context, classes, 'Monday'),
                      _buildDaySchedule(context, classes, 'Tuesday'),
                      _buildDaySchedule(context, classes, 'Wednesday'),
                      _buildDaySchedule(context, classes, 'Thursday'),
                      _buildDaySchedule(context, classes, 'Friday'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Join Class'),
      ),
    );
  }

  Widget _buildLiveClassCard(BuildContext context, Map<String, dynamic> cls) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  cls['time'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              cls['title'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Instructor: ${cls['instructor']}',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            Text(
              'Room: ${cls['room']}',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Join Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(
    BuildContext context,
    List<Map<String, dynamic>> classes,
    String day,
  ) {
    final dayClasses = classes.where((cls) => cls['day'] == day).toList();
    
    if (dayClasses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No classes scheduled for $day',
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.8),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayClasses.length,
      itemBuilder: (context, index) {
        final cls = dayClasses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.class_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              cls['title'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  cls['time'],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Instructor: ${cls['instructor']}'),
                Text('Room: ${cls['room']}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {},
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}
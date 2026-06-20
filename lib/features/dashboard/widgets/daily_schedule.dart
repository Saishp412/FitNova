import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';

class DailySchedule extends StatelessWidget {
  DailySchedule({super.key});

  void _showAddTaskDialog(BuildContext context, String uid) {
    final titleController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Task Name (e.g. Read 10 Pages)'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: 'Time (e.g. 08:00 AM)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && timeController.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'tasks': FieldValue.arrayUnion([
                      {
                        'title': titleController.text,
                        'time': timeController.text,
                        'isDone': false,
                      }
                    ])
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryAccent),
              child: Text('Add Task', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _toggleTask(String uid, List<dynamic> allTasks, int index) {
    // Because it's an array of maps in Firestore, we must replace the whole array to update one item
    final updatedTasks = List<Map<String, dynamic>>.from(allTasks);
    updatedTasks[index]['isDone'] = !updatedTasks[index]['isDone'];

    FirebaseFirestore.instance.collection('users').doc(uid).update({
      'tasks': updatedTasks,
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final List<dynamic> tasks = data?['tasks'] ?? [];

        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: AppTheme.primaryAccent),
                    onPressed: () => _showAddTaskDialog(context, user.uid),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (tasks.isEmpty)
                Text('No tasks yet. Add one!', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!)),
              ...List.generate(tasks.length, (index) {
                final task = tasks[index] as Map<String, dynamic>;
                final bool isDone = task['isDone'] ?? false;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onTap: () => _toggleTask(user.uid, tasks, index),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            color: isDone ? AppTheme.primaryAccent : Colors.transparent,
                            border: Border.all(
                              color: isDone ? AppTheme.primaryAccent : Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: isDone
                              ? Icon(Icons.check, size: 16, color: Colors.white).animate().scale()
                              : null,
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDone ? Theme.of(context).textTheme.bodyMedium!.color! : Theme.of(context).textTheme.bodyLarge!.color!,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Text(
                              task['time'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium!.color!,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1);
              }),
            ],
          ),
        );
      },
    );
  }
}

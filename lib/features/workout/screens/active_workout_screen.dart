import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../core/theme/app_theme.dart';
class ActiveWorkoutScreen extends StatefulWidget {
  final String workoutTitle;
  final List<Map<String, String>> exercises;

  ActiveWorkoutScreen({
    super.key,
    required this.workoutTitle,
    required this.exercises,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Timer _timer;
  int _secondsElapsed = 0;
  final Set<int> _completedExercises = {};
  int? _activeVideoIndex;

  Widget _buildYoutubePlayer(String url) {
    String videoId = '';
    if (url.contains('v=')) {
      videoId = url.split('v=')[1].split('&')[0];
    } else if (url.contains('youtu.be/')) {
      videoId = url.split('youtu.be/')[1].split('?')[0];
    }

    if (videoId.isEmpty) return SizedBox();

    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    return Container(
      margin: EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: controller,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsElapsed / 60).floor();
    final seconds = _secondsElapsed % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _finishWorkout() async {
    _timer.cancel();
    
    // Calculate rough calories burned (e.g. 8 calories per minute of active workout)
    final minutes = (_secondsElapsed / 60).ceil();
    final caloriesBurned = minutes * 8;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && caloriesBurned > 0) {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('logged_workouts').add({
        'title': widget.workoutTitle,
        'calories': caloriesBurned,
        'durationMinutes': minutes,
        'date': dateStr,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'calories': FieldValue.increment(caloriesBurned),
      }, SetOptions(merge: true));
    }

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great job! Burned ~$caloriesBurned calories!'),
        backgroundColor: AppTheme.primaryAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context); // Go back to Dashboard
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.exercises.isEmpty ? 0.0 : _completedExercises.length / widget.exercises.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge!.color!),
        title: Text('Active Workout', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!)),
        actions: [
          TextButton(
            onPressed: _finishWorkout,
            child: Text('FINISH', style: TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Timer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.workoutTitle,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  _formattedTime,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryAccent,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 16),
                // Progress bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      color: AppTheme.primaryAccent,
                      minHeight: 8,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${_completedExercises.length} / ${widget.exercises.length} Completed',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.2),

          SizedBox(height: 16),

          // Exercise List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: widget.exercises.length,
              itemBuilder: (context, index) {
                final isCompleted = _completedExercises.contains(index);
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isCompleted) {
                          _completedExercises.remove(index);
                        } else {
                          _completedExercises.add(index);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppTheme.primaryAccent.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCompleted ? AppTheme.primaryAccent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: isCompleted ? AppTheme.primaryAccent : Theme.of(context).textTheme.bodyMedium!.color!,
                            size: 28,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.exercises[index]['name']!,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isCompleted ? FontWeight.bold : FontWeight.bold,
                                          color: isCompleted ? Theme.of(context).textTheme.bodyLarge!.color! : Theme.of(context).textTheme.bodyLarge!.color!,
                                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      widget.exercises[index]['sets']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted ? Theme.of(context).textTheme.bodyMedium!.color! : AppTheme.primaryAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  widget.exercises[index]['desc']!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).textTheme.bodyMedium!.color!,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                if (widget.exercises[index].containsKey('mediaUrl'))
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: _activeVideoIndex == index
                                        ? _buildYoutubePlayer(widget.exercises[index]['mediaUrl']!)
                                        : TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _activeVideoIndex = _activeVideoIndex == index ? null : index;
                                              });
                                            },
                                            icon: Icon(Icons.play_circle_fill, color: Colors.red),
                                            label: Text('Watch Tutorial', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!)),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              alignment: Alignment.centerLeft,
                                            ),
                                          ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 200 + (index * 50))).slideX(begin: 0.2),
                );
              },
            ),
          ),
          
          // Giant Finish Button at bottom
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _finishWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('FINISH WORKOUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.surface)),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

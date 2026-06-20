import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/stat_ring.dart';
import '../widgets/workout_card.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/hydration_card.dart';
import '../widgets/daily_schedule.dart';
import '../../workout/screens/workout_detail_screen.dart';

class HomeDashboard extends StatefulWidget {
  final VoidCallback? onProfileTap;
  HomeDashboard({super.key, this.onProfileTap});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

final List<Map<String, dynamic>> workoutRoutines = [
  {
    'id': '3_DAY_CYCLE_1',
    'name': '3 Days Cycle 1',
    'cycle': [
      {'title': 'Push (Chest, Tricep, Shoulder)', 'durationMinutes': 45, 'difficulty': 'Medium'},
      {'title': 'Pull (Back, Bicep)', 'durationMinutes': 45, 'difficulty': 'Medium'},
      {'title': 'Legs & Arms', 'durationMinutes': 50, 'difficulty': 'Hard'},
    ],
  },
  {
    'id': '3_DAY_CYCLE_2',
    'name': '3 Days Cycle 2',
    'cycle': [
      {'title': 'Push (Chest, Tricep)', 'durationMinutes': 40, 'difficulty': 'Medium'},
      {'title': 'Pull (Back, Bicep)', 'durationMinutes': 45, 'difficulty': 'Medium'},
      {'title': 'Legs, Shoulder & Arms', 'durationMinutes': 50, 'difficulty': 'Hard'},
    ],
  },
  {
    'id': '5_DAY_CYCLE',
    'name': '5 Days Cycle',
    'cycle': [
      {'title': 'Push (Chest, Tricep)', 'durationMinutes': 40, 'difficulty': 'Medium'},
      {'title': 'Pull (Back, Bicep)', 'durationMinutes': 45, 'difficulty': 'Medium'},
      {'title': 'Legs, Shoulder & Arms', 'durationMinutes': 50, 'difficulty': 'Hard'},
      {'title': 'Upper Body', 'durationMinutes': 45, 'difficulty': 'Hard'},
      {'title': 'Lower Body', 'durationMinutes': 50, 'difficulty': 'Hard'},
    ],
  },
];

class _HomeDashboardState extends State<HomeDashboard> with WidgetsBindingObserver {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  bool? _isGymModeState;
  bool get _isGymMode => _isGymModeState ?? false;
  set _isGymMode(bool val) => _isGymModeState = val;

  int _workoutWeekOffset = 0;

  void _showRoutineSelectorDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Workout Routine', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ...workoutRoutines.map((routine) {
                return ListTile(
                  title: Text(routine['name'] as String, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${(routine['cycle'] as List).length} Days Cycle'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final user = _auth.currentUser;
                    if (user != null) {
                      await _firestore.collection('users').doc(user.uid).set({
                        'routineId': routine['id'],
                        // Reset the start date so today becomes Day 1 of the new cycle
                        'routineStartDate': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAddDataDialog() {
    final stepsController = TextEditingController();
    final activeMinController = TextEditingController();
    final calsInController = TextEditingController();
    final sleepController = TextEditingController();
    final screenTimeController = TextEditingController();
    
    // variables for weekly chart
    final monController = TextEditingController();
    final tueController = TextEditingController();
    final wedController = TextEditingController();
    final thuController = TextEditingController();
    final friController = TextEditingController();
    final satController = TextEditingController();
    final sunController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Add Manual Data', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Activity', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryAccent)),
                SizedBox(height: 8),
                TextField(controller: stepsController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Steps Taken', prefixIcon: Icon(Icons.directions_walk))),
                SizedBox(height: 8),
                TextField(controller: activeMinController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Active Minutes', prefixIcon: Icon(Icons.local_fire_department))),
                SizedBox(height: 8),
                TextField(controller: calsInController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Calories Consumed', prefixIcon: Icon(Icons.restaurant))),
                SizedBox(height: 8),
                TextField(controller: sleepController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Sleep (Hours)', prefixIcon: Icon(Icons.bedtime))),
                SizedBox(height: 8),
                TextField(controller: screenTimeController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Screen Time (Hours)', prefixIcon: Icon(Icons.phone_android))),
                
                SizedBox(height: 24),
                Text('Weekly Chart (0.0 to 1.0)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryAccent)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(width: 60, child: TextField(controller: monController, decoration: InputDecoration(labelText: 'Mon'))),
                    SizedBox(width: 60, child: TextField(controller: tueController, decoration: InputDecoration(labelText: 'Tue'))),
                    SizedBox(width: 60, child: TextField(controller: wedController, decoration: InputDecoration(labelText: 'Wed'))),
                    SizedBox(width: 60, child: TextField(controller: thuController, decoration: InputDecoration(labelText: 'Thu'))),
                    SizedBox(width: 60, child: TextField(controller: friController, decoration: InputDecoration(labelText: 'Fri'))),
                    SizedBox(width: 60, child: TextField(controller: satController, decoration: InputDecoration(labelText: 'Sat'))),
                    SizedBox(width: 60, child: TextField(controller: sunController, decoration: InputDecoration(labelText: 'Sun'))),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!)),
            ),
            ElevatedButton(
              onPressed: () async {
                final steps = int.tryParse(stepsController.text.trim()) ?? 0;
                final activeMin = int.tryParse(activeMinController.text.trim()) ?? 0;
                final calsIn = int.tryParse(calsInController.text.trim()) ?? 0;
                final sleep = double.tryParse(sleepController.text.trim()) ?? 0.0;
                final screenTime = double.tryParse(screenTimeController.text.trim()) ?? 0.0;
                
                final mon = double.tryParse(monController.text.trim());
                final tue = double.tryParse(tueController.text.trim());
                final wed = double.tryParse(wedController.text.trim());
                final thu = double.tryParse(thuController.text.trim());
                final fri = double.tryParse(friController.text.trim());
                final sat = double.tryParse(satController.text.trim());
                final sun = double.tryParse(sunController.text.trim());

                final user = _auth.currentUser;
                if (user != null) {
                  Map<String, dynamic> dailyUpdate = {};
                  
                  if (steps > 0) dailyUpdate['steps'] = FieldValue.increment(steps);
                  if (activeMin > 0) dailyUpdate['activeMinutes'] = FieldValue.increment(activeMin);
                  if (calsIn > 0) dailyUpdate['calories'] = FieldValue.increment(calsIn);
                  if (sleep > 0) dailyUpdate['sleepHours'] = FieldValue.increment(sleep);
                  if (screenTime > 0) dailyUpdate['screenTime'] = FieldValue.increment(screenTime);

                  String dateIso = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

                  if (dailyUpdate.isNotEmpty) {
                    await _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('daily_tracking')
                        .doc(dateIso)
                        .set(dailyUpdate, SetOptions(merge: true));
                  }

                  if (calsIn > 0) {
                    await _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('logged_meals')
                        .add({
                      'title': 'Manual Quick Log',
                      'food': 'Custom',
                      'calories': calsIn,
                      'weightGrams': 0,
                      'date': dateIso,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                  }

                  Map<String, dynamic> globalUpdate = {};
                  Map<String, dynamic> weeklyProgress = {};
                  if (mon != null) weeklyProgress['Mon'] = mon;
                  if (tue != null) weeklyProgress['Tue'] = tue;
                  if (wed != null) weeklyProgress['Wed'] = wed;
                  if (thu != null) weeklyProgress['Thu'] = thu;
                  if (fri != null) weeklyProgress['Fri'] = fri;
                  if (sat != null) weeklyProgress['Sat'] = sat;
                  if (sun != null) weeklyProgress['Sun'] = sun;

                  if (weeklyProgress.isNotEmpty) {
                    globalUpdate['weeklyProgress'] = weeklyProgress;
                  }

                  if (globalUpdate.isNotEmpty) {
                    await _firestore.collection('users').doc(user.uid).set(globalUpdate, SetOptions(merge: true));
                  }
                }
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save Data', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: _showAddDataDialog,
          backgroundColor: AppTheme.primaryAccent,
          child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
        ).animate().scale(delay: 800.ms),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _firestore.collection('users').doc(user?.uid).snapshots(),
                builder: (context, snapshot) {
                  final userData = snapshot.data?.data() as Map<String, dynamic>?;
                  final name = userData?['name'] ?? 'Athlete';
                  
                  // Read dynamic data from Firestore instead of hardcoded variables
                  final int currentSteps = (userData?['steps'] as num?)?.toInt() ?? 0;
                  final int currentCalories = (userData?['calories'] as num?)?.toInt() ?? 0;
                  final double currentSleep = (userData?['sleepHours'] as num?)?.toDouble() ?? 0.0;
                  final double currentScreenTime = (userData?['screenTime'] as num?)?.toDouble() ?? 0.0;

                  return Column(
                    children: [
                      // Header Section
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good Morning,',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    name.split(' ').first,
                                    style: Theme.of(context).textTheme.displayMedium,
                                  ),
                                  SizedBox(height: 4),
                                  LiveClock(),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.settings, color: Theme.of(context).textTheme.bodyMedium!.color!),
                                  onPressed: _showRoutineSelectorDialog,
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: widget.onProfileTap,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppTheme.primaryAccent,
                                      child: Icon(Icons.person, color: Theme.of(context).colorScheme.surface),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                      ),
                      
                      // Daily Activity Stats Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user?.uid)
                              .collection('daily_tracking')
                              .doc('${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}')
                              .snapshots(),
                          builder: (context, snapshot) {
                            final dailyData = snapshot.data?.data() as Map<String, dynamic>?;
                            final int dailySteps = (dailyData?['steps'] as num?)?.toInt() ?? 0;
                            final int dailyActiveMin = (dailyData?['activeMinutes'] as num?)?.toInt() ?? 0;
                            final double dailySleep = (dailyData?['sleepHours'] as num?)?.toDouble() ?? 0.0;
                            final double dailyScreenTime = (dailyData?['screenTime'] as num?)?.toDouble() ?? 0.0;
                            final int dailyCalories = (dailyData?['calories'] as num?)?.toInt() ?? 0;

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
                                children: [
                                  Text(
                                    'Daily Activity',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge!.color!,
                                    ),
                                  ),
                                  SizedBox(height: 32),
                                  Wrap(
                                    alignment: WrapAlignment.spaceAround,
                                    spacing: 16,
                                    runSpacing: 32,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user?.uid)
                                              .collection('daily_tracking')
                                              .doc('${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}')
                                              .set({'steps': dailySteps + 500}, SetOptions(merge: true));
                                        },
                                        child: StatRing(
                                          current: dailySteps.toDouble(),
                                          max: 10000,
                                          label: 'Steps',
                                          valueText: dailySteps.toString(),
                                          color: AppTheme.primaryAccent,
                                        ),
                                      ),
                                      StatRing(
                                        current: dailyCalories.toDouble(),
                                        max: 2500, // standard max goal
                                        label: 'Cals In',
                                        valueText: dailyCalories.toString(),
                                        color: Colors.redAccent,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user?.uid)
                                              .collection('daily_tracking')
                                              .doc('${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}')
                                              .set({'activeMinutes': dailyActiveMin + 15}, SetOptions(merge: true));
                                        },
                                        child: StatRing(
                                          current: dailyActiveMin.toDouble(),
                                          max: 60,
                                          label: 'Active(m)',
                                          valueText: dailyActiveMin.toString(),
                                          color: Colors.orange.shade300,
                                        ),
                                      ),
                                      StatRing(
                                        current: dailySleep,
                                        max: 8.0,
                                        label: 'Sleep (hrs)',
                                        valueText: dailySleep.toStringAsFixed(1),
                                        color: Colors.indigo.shade400,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    ],
                  );
                },
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Hydration Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: HydrationCard().animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Weekly Chart Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: WeeklyChart().animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Recommended Programs Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'This week\'s workout plans:',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ).animate().fadeIn(delay: 500.ms),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: AppTheme.primaryAccent, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _workoutWeekOffset++;
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right, 
                            color: AppTheme.primaryAccent,
                            size: 20
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _workoutWeekOffset--;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 8)),
            
            // Home / Gym Toggle
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Home', style: TextStyle(color: !_isGymMode ? AppTheme.primaryAccent : Theme.of(context).textTheme.bodyMedium!.color!, fontWeight: FontWeight.bold, fontSize: 12)),
                    Switch(
                      value: _isGymMode,
                      activeColor: AppTheme.primaryAccent,
                      onChanged: (val) {
                        setState(() {
                          _isGymMode = val;
                        });
                      },
                    ),
                    Text('Gym', style: TextStyle(color: _isGymMode ? AppTheme.primaryAccent : Theme.of(context).textTheme.bodyMedium!.color!, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Recommended Programs List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 160,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('users').doc(user?.uid).snapshots(),
                  builder: (context, snapshot) {
                    final userData = snapshot.data?.data() as Map<String, dynamic>?;
                    final String routineId = userData?['routineId'] ?? '3_DAY_SPLIT';
                    final Timestamp? startDate = userData?['routineStartDate'];
                    
                    final currentRoutine = workoutRoutines.firstWhere((r) => r['id'] == routineId, orElse: () => workoutRoutines[0]);
                    final cycleList = currentRoutine['cycle'] as List;

                    final today = DateTime.now();
                    final endDate = today.subtract(Duration(days: 7 * _workoutWeekOffset));
                    final weekStartDate = endDate.subtract(Duration(days: 6));
                    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

                    return ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final dayDate = weekStartDate.add(Duration(days: index));
                        
                        int dayOfCycle = 0;
                        if (startDate != null) {
                          final start = startDate.toDate();
                          final cleanStart = DateTime(start.year, start.month, start.day);
                          final cleanDay = DateTime(dayDate.year, dayDate.month, dayDate.day);
                          
                          int diff = cleanDay.difference(cleanStart).inDays;
                          // Use true mathematical modulo to handle days before the start date gracefully
                          dayOfCycle = (diff % cycleList.length + cycleList.length) % cycleList.length;
                        }

                        final data = cycleList[dayOfCycle] as Map<String, dynamic>;
                        final isRealToday = dayDate.year == today.year && dayDate.month == today.month && dayDate.day == today.day;
                        
                        final dateString = '${dayDate.day} ${months[dayDate.month - 1]}';
                        final title = isRealToday ? 'Today: ${data['title']}' : '$dateString: ${data['title']}';

                        return WorkoutCard(
                          title: title,
                          durationMinutes: data['durationMinutes'] ?? 0,
                          difficulty: data['difficulty'] ?? 'Beginner',
                          onTap: () {
                            if (!isRealToday) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Previewing workout for $dateString!')),
                              );
                            }
                            // Navigate to workout detail
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutDetailScreen(
                                  workoutTitle: data['title'],
                                  isGymMode: _isGymMode,
                                  durationMinutes: data['durationMinutes'] ?? 45,
                                ),
                              ),
                            );
                          },
                        ).animate().fadeIn(delay: Duration(milliseconds: 600 + (index * 100))).slideX(begin: 0.2);
                      },
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Daily Schedule Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: DailySchedule().animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
              ),
            ),
            
            SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

class LiveClock extends StatelessWidget {
  LiveClock({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        
        int hour = now.hour;
        final ampm = hour >= 12 ? 'PM' : 'AM';
        if (hour == 0) hour = 12;
        if (hour > 12) hour -= 12;
        
        final minute = now.minute.toString().padLeft(2, '0');
        
        final dateStr = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
        final timeStr = '$hour:$minute $ampm';
        
        return Text(
          '$dateStr • $timeStr',
          style: TextStyle(
            color: AppTheme.primaryAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        );
      },
    );
  }
}

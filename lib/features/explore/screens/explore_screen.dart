import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/data/diet_data.dart';
import '../../reports/screens/daily_report_screen.dart';

class ExploreScreen extends StatefulWidget {
  ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with WidgetsBindingObserver {
  String _selectedGoal = 'Maintenance'; // Cutting, Bulking, Maintenance
  late DateTime _selectedDate;
  late ScrollController _dateScrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedDate = DateTime.now();
    _dateScrollController = ScrollController(initialScrollOffset: 30 * 70.0); // Rough center
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (_selectedDate.day != now.day || _selectedDate.month != now.month || _selectedDate.year != now.year) {
        setState(() {
          _selectedDate = now;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return "Today";
    }
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]}";
  }

  String _formatDateIso(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  final List<Map<String, String>> _foodSwaps = [
    {'bad': 'Sugar in Chai', 'good': 'Stevia or Jaggery (Gud)', 'reason': 'Lower glycemic spike'},
    {'bad': 'Deep Fried Samosa', 'good': 'Roasted Chana / Makhana', 'reason': 'High protein, much less fat'},
    {'bad': 'Store-bought Mithai', 'good': 'Dates (Khajoor)', 'reason': 'Natural energy without refined sugar'},
    {'bad': 'Maida (White Flour) Roti', 'good': 'Multigrain / Bajra Roti', 'reason': 'Higher fiber and micronutrients'},
    {'bad': 'Packaged Fruit Juice', 'good': 'Fresh Coconut Water', 'reason': 'No added sugar, high in electrolytes'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Scaffold(body: Center(child: Text('Please login')));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final dietPreference = data?['dietPreference'] ?? 'Omnivore (Any)';
          final dietPlans = get7DayDietPlans(dietPreference);

          return CustomScrollView(
            slivers: [
              _buildAppBar(dietPreference),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              _buildGoalSelector(),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              _buildDaySelector(),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              _buildMacroSummary(dietPlans),
              SliverToBoxAdapter(child: SizedBox(height: 24)),
              _buildConsumedMeals(),
              _buildDailyMeals(dietPlans),
              SliverToBoxAdapter(child: SizedBox(height: 32)),
              _buildFoodSwaps(),
              SliverToBoxAdapter(child: SizedBox(height: 32)),
              _buildSupplementsGuide(),
              SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        }
      ),
    );
  }

  Widget _buildAppBar(String preference) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          '$preference Diet',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Theme.of(context).colorScheme.surface),
            Positioned(
              right: -30,
              top: -30,
              child: Icon(
                Icons.restaurant_menu,
                size: 150,
                color: AppTheme.primaryAccent.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Your Goal', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14)),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Cutting', 'Maintenance', 'Bulking'].map((goal) {
                  final isSelected = _selectedGoal == goal;
                  return Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedGoal = goal;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryAccent : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryAccent : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          goal,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color!,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.1),
      ),
    );
  }

  Widget _buildDaySelector() {
    final today = DateTime.now();
    // Generate 15 days centered around the CURRENTLY SELECTED DATE
    final startDate = _selectedDate.subtract(Duration(days: 7));
    final dates = List.generate(15, (index) => startDate.add(Duration(days: index)));

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calendar', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14)),
                IconButton(
                  icon: Icon(Icons.calendar_month, color: AppTheme.primaryAccent),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppTheme.primaryAccent,
                              onPrimary: Colors.white,
                              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 4),
            SizedBox(
              height: 70,
              child: ListView.builder(
                controller: _dateScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
                  final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 60,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryAccent : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isToday && !isSelected ? AppTheme.primaryAccent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getDayOfWeek(date).substring(0, 3),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium!.color!,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color!,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: 0.1),
      ),
    );
  }

  Widget _buildMacroSummary(Map<String, Map<String, dynamic>> dietPlans) {
    final dayOfWeek = _getDayOfWeek(_selectedDate);
    final dayData = dietPlans[_selectedGoal]!['days'][dayOfWeek]!;
    final data = dayData['macros'] as Map<String, String>;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Target Macros', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14)),
              SizedBox(height: 4),
              Text(data['calories']!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMacroPip('Protein', data['protein']!, Colors.redAccent),
                  _buildMacroPip('Carbs', data['carbs']!, Colors.orangeAccent),
                  _buildMacroPip('Fats', data['fats']!, Colors.yellowAccent),
                ],
              ),
            ],
          ),
        ).animate(key: ValueKey(_selectedGoal)).fadeIn().scale(begin: Offset(0.95, 0.95)),
      ),
    );
  }

  Widget _buildMacroPip(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 12)),
      ],
    );
  }

  Widget _buildConsumedMeals() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return SliverToBoxAdapter(child: SizedBox.shrink());

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('logged_meals')
          .where('date', isEqualTo: _formatDateIso(_selectedDate))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final logs = snapshot.data!.docs.toList();
        logs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['timestamp'] as Timestamp?;
          final bTime = bData['timestamp'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime); // Descending
        });
        
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("${_formatDate(_selectedDate)} Logs", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!)),
                        IconButton(
                          icon: Icon(Icons.analytics, color: AppTheme.primaryAccent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DailyReportScreen(date: _selectedDate)),
                            );
                          },
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        final batch = FirebaseFirestore.instance.batch();
                        for (var doc in logs) {
                          batch.delete(doc.reference);
                        }
                        await batch.commit();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('All logs for ${_formatDate(_selectedDate)} cleared!'),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      child: Text('Clear All', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...logs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.greenAccent),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['title'] ?? 'Meal', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!)),
                              SizedBox(height: 4),
                              Text('${data['calories']} kcal', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: 0.1);
                }).toList(),
                SizedBox(height: 24), // Extra spacing before the next section
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyMeals(Map<String, Map<String, dynamic>> dietPlans) {
    final dayOfWeek = _getDayOfWeek(_selectedDate);
    final dayData = dietPlans[_selectedGoal]!['days'][dayOfWeek]!;
    final meals = dayData['meals'] as List;
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Meal Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!)),
            SizedBox(height: 16),
            ...meals.map((meal) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(meal['icon'], color: AppTheme.primaryAccent),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(meal['title'], style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryAccent)),
                            SizedBox(height: 4),
                            Text(meal['food'], style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!, fontSize: 14)),
                            if (meal['alternate'] != null) ...[
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.swap_horiz, size: 14, color: Theme.of(context).textTheme.bodyMedium!.color!),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Swap: ${meal['alternate']}',
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 12, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showLogMealBottomSheet(context, meal as Map<String, dynamic>),
                        icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryAccent, size: 28),
                        tooltip: 'Log Meal',
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _showCustomMealDialog,
                icon: Icon(Icons.add_circle, color: Theme.of(context).scaffoldBackgroundColor),
                label: Text('Add Custom Meal', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ).animate(key: ValueKey('meals_$_selectedGoal')).fadeIn().slideY(begin: 0.1),
      ),
    );
  }

  void _showCustomMealDialog() {
    final nameController = TextEditingController();
    final calsController = TextEditingController();
    final weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Custom Meal', style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyLarge!.color!)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Meal Name (e.g. Oatmeal)',
                  labelStyle: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
                ),
                style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyLarge!.color!),
              ),
              SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity (grams)',
                  labelStyle: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
                ),
                style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyLarge!.color!),
              ),
              SizedBox(height: 16),
              TextField(
                controller: calsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories',
                  labelStyle: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
                ),
                style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyLarge!.color!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium!.color!)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final cals = int.tryParse(calsController.text.trim()) ?? 0;
                final weight = double.tryParse(weightController.text.trim()) ?? 0;
                
                if (name.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('logged_meals')
                        .add({
                      'title': name,
                      'food': 'Custom Meal',
                      'calories': cals,
                      'weightGrams': weight,
                      'date': _formatDateIso(_selectedDate),
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logged Custom Meal: $name')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Log Meal', style: TextStyle(color: Theme.of(dialogContext).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showLogMealBottomSheet(BuildContext context, Map<String, dynamic> meal) {
    double weightInGrams = 300.0; // Assume standard combo meal weight is 300g
    int baseCals = meal['baseCalories'] as int? ?? 500;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetStateContext, setModalState) {
            // Calculate calories based on the ratio of selected weight vs base 300g weight
            int calculatedCals = (baseCals * (weightInGrams / 300.0)).round();
            return Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(sheetStateContext).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(sheetStateContext).textTheme.bodyMedium!.color!.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text('Log ${meal['title']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(sheetStateContext).textTheme.bodyLarge!.color!)),
                  SizedBox(height: 8),
                  Text(meal['food'], textAlign: TextAlign.center, style: TextStyle(color: Theme.of(sheetStateContext).textTheme.bodyMedium!.color!, fontSize: 14)),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('$calculatedCals', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryAccent)),
                      SizedBox(width: 8),
                      Text('kcal', style: TextStyle(color: Theme.of(sheetStateContext).textTheme.bodyMedium!.color!, fontSize: 18)),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text('Total Meal Weight', style: TextStyle(color: Theme.of(sheetStateContext).textTheme.bodyLarge!.color!, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Slider(
                    value: weightInGrams,
                    min: 50,
                    max: 800,
                    divisions: 30, // 25g steps
                    activeColor: AppTheme.primaryAccent,
                    inactiveColor: Theme.of(sheetStateContext).colorScheme.surface,
                    label: '${weightInGrams.round()}g',
                    onChanged: (val) {
                      setModalState(() {
                        weightInGrams = val;
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('50g', style: TextStyle(color: Theme.of(sheetStateContext).textTheme.bodyMedium!.color!, fontSize: 12)),
                        Text('300g (Avg)', style: TextStyle(color: Theme.of(sheetStateContext).textTheme.bodyMedium!.color!, fontSize: 12)),
                        Text('800g', style: TextStyle(color: Theme.of(sheetStateContext).textTheme.bodyMedium!.color!, fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('logged_meals')
                              .add({
                            'title': meal['title'],
                            'food': meal['food'],
                            'calories': calculatedCals,
                            'weightGrams': weightInGrams.round(),
                            'date': _formatDateIso(_selectedDate),
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('daily_tracking')
                              .doc(_formatDateIso(_selectedDate))
                              .set({'calories': FieldValue.increment(calculatedCals)}, SetOptions(merge: true));
                        }
                        if (mounted) {
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.greenAccent),
                                  SizedBox(width: 12),
                                  Expanded(child: Text('Logged $calculatedCals kcal (${weightInGrams.round()}g)!', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!, fontWeight: FontWeight.bold))),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Theme.of(context).colorScheme.surface,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryAccent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Log Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(sheetStateContext).scaffoldBackgroundColor)),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFoodSwaps() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('Smart Food Swaps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!)),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _foodSwaps.length,
              itemBuilder: (context, index) {
                final swap = _foodSwaps[index];
                return Container(
                  width: 200,
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.close, color: Colors.redAccent, size: 16),
                          SizedBox(width: 8),
                          Expanded(child: Text(swap['bad']!, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, decoration: TextDecoration.lineThrough))),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Icon(Icons.arrow_downward, color: AppTheme.primaryAccent, size: 16),
                      ),
                      Row(
                        children: [
                          Icon(Icons.check, color: Colors.greenAccent, size: 16),
                          SizedBox(width: 8),
                          Expanded(child: Text(swap['good']!, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(swap['reason']!, style: TextStyle(color: AppTheme.primaryAccent, fontSize: 10, fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ).animate().fadeIn(delay: 300.ms),
    );
  }

  Widget _buildSupplementsGuide() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supplements & Hydration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge!.color!)),
            SizedBox(height: 16),
            _buildGuideItem(Icons.water_drop, 'Water', 'Drink at least 3-4 Liters daily for optimal recovery and performance.', Colors.blueAccent, quickLogCalories: 0),
            _buildGuideItem(Icons.local_florist, 'Sugarcane Juice', 'Excellent natural post-workout energy booster, rich in carbs and minerals.', Colors.lightGreen, quickLogCalories: 180),
            _buildGuideItem(Icons.waves, 'Coconut Water', 'Natural electrolyte powerhouse for rapid hydration.', Colors.cyan, quickLogCalories: 45),
            _buildGuideItem(Icons.medical_services, 'ORS', 'Replenish sodium and essential electrolytes lost during intense sweating.', Colors.redAccent, quickLogCalories: 30),
            _buildGuideItem(Icons.fitness_center, 'Whey Protein', '1-2 scoops post-workout to hit your daily protein goals easily.', Colors.purpleAccent, quickLogCalories: 120),
            _buildGuideItem(Icons.bolt, 'Creatine Monohydrate', '5g daily to improve strength, power, and muscle fullness.', Colors.amberAccent, quickLogCalories: 0),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _showCustomSupplementDialog,
                icon: Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor),
                label: Text('Add Custom Supplement', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ).animate().fadeIn(delay: 400.ms),
      ),
    );
  }

  void _showCustomSupplementDialog() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Custom Supplement', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Supplement Name (e.g. BCAAs)',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryAccent)),
                ),
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!),
              ),
              SizedBox(height: 16),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories (optional)',
                  labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.7)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryAccent)),
                ),
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!),
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
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final calories = int.tryParse(caloriesController.text.trim()) ?? 0;
                  Navigator.pop(context);
                  _quickLogSupplement(name, calories);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Log Drink', style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _quickLogSupplement(String title, int calories) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dateIso = _formatDateIso(_selectedDate);
      
      // 1. Log the supplement as a meal
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('logged_meals')
          .add({
        'title': title,
        'food': 'Supplement',
        'calories': calories,
        'weightGrams': 0, // Not applicable
        'date': dateIso,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('daily_tracking')
          .doc(dateIso)
          .set({'calories': FieldValue.increment(calories)}, SetOptions(merge: true));

      // 2. If it's a water-based drink, increment daily hydration tracker!
      if (title.toLowerCase().contains('water')) {
        final dailyDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('daily_tracking')
            .doc(dateIso);
            
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(dailyDocRef);
          if (!snapshot.exists) {
            transaction.set(dailyDocRef, {'waterIntake': 1});
          } else {
            int currentIntake = snapshot.data()?['waterIntake'] ?? 0;
            transaction.update(dailyDocRef, {'waterIntake': currentIntake + 1});
          }
        });
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.greenAccent),
              SizedBox(width: 12),
              Expanded(child: Text('Logged $title ($calories kcal)!', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!, fontWeight: FontWeight.bold))),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }
  }

  Widget _buildGuideItem(IconData icon, String title, String desc, Color color, {int? quickLogCalories}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color!)),
                  SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14)),
                ],
              ),
            ),
            if (quickLogCalories != null) ...[
              SizedBox(width: 8),
              IconButton(
                onPressed: () => _quickLogSupplement(title, quickLogCalories),
                icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryAccent, size: 28),
                tooltip: 'Log Supplement',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

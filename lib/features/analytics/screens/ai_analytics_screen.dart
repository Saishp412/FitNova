import 'package:fitnova/core/secrets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import 'coach_nova_chat_screen.dart';

class AiAnalyticsScreen extends StatefulWidget {
  AiAnalyticsScreen({super.key});

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  
  bool _isLoadingAi = false;
  String _aiInsights = '';
  
  // Data for Charts
  List<FlSpot> _calorieSpots = [];
  Map<String, int> _dailyCalories = {};
  double _avgCals = 0;
  
  // Hardcoded as requested
  final String _openAiApiKey = openAiApiKey;

  @override
  void initState() {
    super.initState();
    _fetchDataAndAnalyze();
  }

  Future<void> _fetchDataAndAnalyze() async {
    setState(() => _isLoadingAi = true);
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final today = DateTime.now();
      final weekAgo = today.subtract(Duration(days: 6));
      final weekAgoIso = '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';
      
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('logged_meals')
          .where('date', isGreaterThanOrEqualTo: weekAgoIso)
          .get();

      _dailyCalories.clear();
      for (int i = 0; i < 7; i++) {
        final d = weekAgo.add(Duration(days: i));
        final iso = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        _dailyCalories[iso] = 0;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = data['date'] as String;
        final cals = (data['calories'] as num?)?.toInt() ?? 0;
        if (_dailyCalories.containsKey(date)) {
          _dailyCalories[date] = _dailyCalories[date]! + cals;
        }
      }

      final sortedDates = _dailyCalories.keys.toList()..sort();
      _calorieSpots = [];
      double x = 0;
      double totalCals = 0;
      for (String d in sortedDates) {
        _calorieSpots.add(FlSpot(x, _dailyCalories[d]!.toDouble()));
        totalCals += _dailyCalories[d]!;
        x += 1;
      }
      _avgCals = totalCals / 7.0;
      
      if (mounted) setState(() {});

      String prompt = "You are Fitnova AI, an elite fitness and nutrition coach. User's 7-day calorie intake:\n";
      for (String d in sortedDates) {
        prompt += "$d: ${_dailyCalories[d]} kcal\n";
      }
      prompt += "\nProvide a concise 3-sentence analysis. Point out trends and give one strong actionable tip.";

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are an advanced data-driven fitness coach.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _aiInsights = resData['choices'][0]['message']['content'];
            _isLoadingAi = false;
          });
        }
      } else {
        if (mounted) setState(() { _aiInsights = "Failed to generate AI insights."; _isLoadingAi = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _aiInsights = "An error occurred while fetching AI insights."; _isLoadingAi = false; });
    }
  }

  Widget _buildChartContainer(String title, Widget chart, {double height = 250}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Container(
        height: height,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05), blurRadius: 20, offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge!.color!)),
            SizedBox(height: 24),
            Expanded(child: chart),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppTheme.primaryAccent, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'AI Analytics',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                        ),
                      ],
                    ).animate().fadeIn().slideX(),
                    SizedBox(height: 8),
                    Text(
                      'Powered by OpenAI',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
            ),

            // 1. Line Chart: Calorie Trend
            SliverToBoxAdapter(
              child: _buildChartContainer(
                '7-Day Calorie Trend',
                _calorieSpots.isEmpty 
                  ? Center(child: CircularProgressIndicator())
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final sortedDates = _dailyCalories.keys.toList()..sort();
                                if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                                  final parts = sortedDates[value.toInt()].split('-');
                                  return Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text('${parts[2]}/${parts[1]}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 10)),
                                  );
                                }
                                return Text('');
                              },
                              reservedSize: 22,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _calorieSpots,
                            isCurved: true,
                            color: AppTheme.primaryAccent,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: AppTheme.primaryAccent.withValues(alpha: 0.1)),
                          ),
                        ],
                      ),
                    ),
              ).animate().fadeIn(delay: 300.ms).slideY(),
            ),

            // AI Insights Card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.surface, Color(0xFFFAF9F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.2), width: 1),
                    boxShadow: [BoxShadow(color: AppTheme.primaryAccent.withValues(alpha: 0.1), blurRadius: 30, offset: Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: AppTheme.primaryAccent, size: 24),
                          SizedBox(width: 12),
                          Text('Coach Nova Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge!.color!)),
                        ],
                      ),
                      SizedBox(height: 16),
                      _isLoadingAi 
                        ? Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
                        : Text(
                            _aiInsights.isNotEmpty ? _aiInsights : "Ready to analyze.",
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!, fontSize: 15, height: 1.5),
                          ).animate().fadeIn(),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(),
            ),

            // 2. Pie Chart: Estimated Macro Split
            SliverToBoxAdapter(
              child: _buildChartContainer(
                'Estimated Macro Split',
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(color: Colors.blue.shade300, value: 40, title: '40%\nCarbs', radius: 50, titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      PieChartSectionData(color: Colors.red.shade300, value: 30, title: '30%\nProtein', radius: 45, titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      PieChartSectionData(color: Colors.orange.shade300, value: 30, title: '30%\nFat', radius: 40, titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                height: 280,
              ).animate().fadeIn(delay: 500.ms).slideY(),
            ),

            // 3. Bar Chart: Daily Goal Adherence
            SliverToBoxAdapter(
              child: _buildChartContainer(
                'Goal Adherence (vs 2500 kcal)',
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final sortedDates = _dailyCalories.keys.toList()..sort();
                            if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                              final parts = sortedDates[value.toInt()].split('-');
                              return Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('${parts[2]}/${parts[1]}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 10)),
                              );
                            }
                            return Text('');
                          },
                          reservedSize: 22,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _calorieSpots.map((spot) {
                      return BarChartGroupData(
                        x: spot.x.toInt(),
                        barRods: [
                          BarChartRodData(
                            toY: spot.y,
                            color: spot.y > 2500 ? Colors.redAccent : AppTheme.primaryAccent,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 3000,
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(),
            ),

            // 4. Radar Chart: Consistency Radar
            SliverToBoxAdapter(
              child: _buildChartContainer(
                'Consistency Radar',
                RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    tickCount: 3,
                    ticksTextStyle: TextStyle(color: Colors.transparent),
                    gridBorderData: BorderSide(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.2)),
                    radarBorderData: BorderSide(color: Colors.transparent),
                    getTitle: (index, angle) {
                      final titles = ['Diet', 'Hydration', 'Workout', 'Sleep'];
                      return RadarChartTitle(text: titles[index], angle: angle);
                    },
                    dataSets: [
                      RadarDataSet(
                        fillColor: AppTheme.primaryAccent.withValues(alpha: 0.2),
                        borderColor: AppTheme.primaryAccent,
                        entryRadius: 3,
                        dataEntries: [
                          RadarEntry(value: (_avgCals > 0) ? 80 : 0), // Diet
                          RadarEntry(value: 65), // Hydration mock
                          RadarEntry(value: 90), // Workout mock
                          RadarEntry(value: 70), // Sleep mock
                        ],
                      ),
                    ],
                  ),
                ),
                height: 300,
              ).animate().fadeIn(delay: 700.ms).slideY(),
            ),

            // 5. Stacked Bar Chart: Meal Size Distribution
            SliverToBoxAdapter(
              child: _buildChartContainer(
                'Meal Size Distribution',
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final sortedDates = _dailyCalories.keys.toList()..sort();
                            if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                              final parts = sortedDates[value.toInt()].split('-');
                              return Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('${parts[2]}/${parts[1]}', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 10)),
                              );
                            }
                            return Text('');
                          },
                          reservedSize: 22,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _calorieSpots.map((spot) {
                      double morning = spot.y * 0.25;
                      double afternoon = spot.y * 0.45;
                      double evening = spot.y * 0.30;
                      return BarChartGroupData(
                        x: spot.x.toInt(),
                        barRods: [
                          BarChartRodData(
                            toY: spot.y,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                            rodStackItems: [
                              BarChartRodStackItem(0, morning, Colors.amber.shade300),
                              BarChartRodStackItem(morning, morning + afternoon, Colors.orange.shade400),
                              BarChartRodStackItem(morning + afternoon, spot.y, Colors.deepOrange.shade400),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton.extended(
          heroTag: 'ai_coach_fab',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CoachNovaChatScreen()));
          },
          backgroundColor: Theme.of(context).textTheme.bodyLarge!.color!,
          icon: Icon(Icons.chat_bubble_outline, color: Theme.of(context).colorScheme.surface),
          label: Text('Coach Nova Chat', style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold)),
        ).animate().scale(delay: 1000.ms),
      ),
    );
  }
}


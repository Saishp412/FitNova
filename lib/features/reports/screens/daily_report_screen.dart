import 'package:fitnova/core/secrets.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/theme/app_theme.dart';

class DailyReportScreen extends StatelessWidget {
  final DateTime date;
  
  DailyReportScreen({super.key, required this.date});

  String get _formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>> _fetchDailyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');

    final mealsQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logged_meals')
        .where('date', isEqualTo: _formattedDate)
        .get();

    final workoutsQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('logged_workouts')
        .where('date', isEqualTo: _formattedDate)
        .get();

    final trackingDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('daily_tracking')
        .doc(_formattedDate)
        .get();

    return {
      'meals': mealsQuery.docs.map((d) => d.data()).toList(),
      'workouts': workoutsQuery.docs.map((d) => d.data()).toList(),
      'tracking': trackingDoc.exists ? trackingDoc.data() : null,
    };
  }

  Future<String> _fetchAiSummary(int eaten, int burned, int net) async {
    const apiKey = openAiApiKey;
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are Coach Nova, an expert fitness AI.'},
            {'role': 'user', 'content': 'User stats for today: $eaten kcal eaten, $burned kcal burned, net balance $net kcal. Give a short 3-sentence performance overview and one quick tip.'}
          ],
          'temperature': 0.7,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['choices'][0]['message']['content'];
      }
    } catch (e) {}
    return 'Great effort today! Keep balancing your diet and workouts to hit your goals efficiently.';
  }

  Future<void> _generatePdf(BuildContext context, Map<String, dynamic> data) async {
    // Show loading snackbar before generating
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analyzing data & generating report...'), duration: Duration(seconds: 3)),
      );
    }

    final doc = pw.Document();

    final meals = data['meals'] as List;
    final workouts = data['workouts'] as List;

    int totalCaloriesIn = meals.fold(0, (sum, item) => sum + (item['calories'] as num).toInt());
    int totalCaloriesOut = workouts.fold(0, (sum, item) => sum + (item['calories'] as num).toInt());
    int netCalories = totalCaloriesIn - totalCaloriesOut;

    final aiSummary = await _fetchAiSummary(totalCaloriesIn, totalCaloriesOut, netCalories);

    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Container(color: PdfColor.fromHex('#F9F8F4')),
            );
          },
          theme: pw.ThemeData.withFont(
            base: fontRegular,
            bold: fontBold,
          ).copyWith(
            defaultTextStyle: pw.TextStyle(color: PdfColor.fromHex('#2C2A28')),
          ),
        ),
        build: (pw.Context context) {
          return [
            // Header Banner
            pw.Container(
              padding: pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFFFFF'),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(16)),
                border: pw.Border.all(color: PdfColor.fromHex('#8B7D6B'), width: 1),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('FITNOVA', style: pw.TextStyle(color: PdfColor.fromHex('#8B7D6B'), fontSize: 24, fontWeight: pw.FontWeight.bold, letterSpacing: 2)),
                      pw.Text('Daily Performance Report', style: pw.TextStyle(color: PdfColor.fromHex('#8F8A83'), fontSize: 14)),
                    ],
                  ),
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#8B7D6B'),
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Text(_formattedDate, style: pw.TextStyle(color: PdfColor.fromHex('#FFFFFF'), fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Summary Stats Row
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: _buildPdfStatCard('Calories Eaten', '$totalCaloriesIn', PdfColor.fromHex('#8B7D6B'))),
                pw.SizedBox(width: 16),
                pw.Expanded(child: _buildPdfStatCard('Calories Burned', '$totalCaloriesOut', PdfColor.fromHex('#8B7D6B'))),
                pw.SizedBox(width: 16),
                pw.Expanded(child: _buildPdfStatCard('Net Balance', '$netCalories', PdfColor.fromHex('#8B7D6B'))),
              ],
            ),
            pw.SizedBox(height: 32),
            
            // AI Insights Section
            pw.Container(
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#E0DCD3').withAlpha(0.2), // Light background
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(16)),
                border: pw.Border.all(color: PdfColor.fromHex('#8B7D6B'), width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('COACH NOVA INSIGHTS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#8B7D6B'), letterSpacing: 1.5)),
                  pw.SizedBox(height: 12),
                  pw.Text(aiSummary, style: pw.TextStyle(color: PdfColor.fromHex('#2C2A28'), lineSpacing: 1.5)),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // Bar Chart comparing In vs Out
            pw.Text('CALORIE BREAKDOWN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2C2A28'), letterSpacing: 1.5)),
            pw.SizedBox(height: 16),
            pw.Container(
              height: 200,
              padding: pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFFFFF'),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(16)),
                border: pw.Border.all(color: PdfColor.fromHex('#8B7D6B'), width: 1),
              ),
              child: pw.Chart(
                left: pw.Container(
                  alignment: pw.Alignment.topCenter,
                  margin: const pw.EdgeInsets.only(right: 5, top: 10),
                  child: pw.Transform.rotateBox(
                    angle: math.pi / 2,
                    child: pw.Text('Calories', style: pw.TextStyle(fontSize: 10)),
                  ),
                ),
                bottom: pw.Container(
                  alignment: pw.Alignment.centerRight,
                  margin: const pw.EdgeInsets.only(top: 5),
                  child: pw.Text('Metric', style: pw.TextStyle(fontSize: 10)),
                ),
                grid: pw.CartesianGrid(
                  xAxis: pw.FixedAxis([0, 1, 2], buildLabel: (v) {
                    if (v == 0) return pw.Text('Eaten');
                    if (v == 1) return pw.Text('Burned');
                    if (v == 2) return pw.Text('Net');
                    return pw.Text('');
                  }),
                  yAxis: pw.FixedAxis(
                    [0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000],
                    buildLabel: (v) => pw.Text(v.toInt().toString(), style: pw.TextStyle(fontSize: 8)),
                  ),
                ),
                datasets: [
                  pw.BarDataSet(
                    color: PdfColor.fromHex('#8B7D6B'),
                    width: 30,
                    data: [
                      pw.PointChartValue(0, totalCaloriesIn.toDouble()),
                      pw.PointChartValue(1, totalCaloriesOut.toDouble()),
                      pw.PointChartValue(2, netCalories.toDouble()),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),
            
            // Daily Tracking Section
            if (data['tracking'] != null) ...[
              pw.Text('DAILY ACTIVITY & HYDRATION', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2C2A28'), letterSpacing: 1.5)),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: _buildPdfStatCard('Steps', '${data['tracking']['steps'] ?? 0}', PdfColor.fromHex('#4CAF50'))),
                  pw.SizedBox(width: 8),
                  pw.Expanded(child: _buildPdfStatCard('Water (Glasses)', '${data['tracking']['waterIntake'] ?? 0}', PdfColor.fromHex('#2196F3'))),
                  pw.SizedBox(width: 8),
                  pw.Expanded(child: _buildPdfStatCard('Active (mins)', '${data['tracking']['activeMinutes'] ?? 0}', PdfColor.fromHex('#FF9800'))),
                  pw.SizedBox(width: 8),
                  pw.Expanded(child: _buildPdfStatCard('Sleep (hrs)', '${data['tracking']['sleepHours'] ?? 0.0}', PdfColor.fromHex('#3F51B5'))),
                ],
              ),
              pw.SizedBox(height: 32),
            ],

            // Workouts Section
            pw.Text('WORKOUTS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2C2A28'), letterSpacing: 1.5)),
            pw.SizedBox(height: 12),
            if (workouts.isEmpty)
              pw.Text('No workouts logged.', style: pw.TextStyle(color: PdfColor.fromHex('#8F8A83')))
            else
              pw.TableHelper.fromTextArray(
                context: context,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#FFFFFF')),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#8B7D6B')),
                rowDecoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E0DCD3'), width: 0.5)),
                ),
                cellStyle: pw.TextStyle(color: PdfColor.fromHex('#2C2A28')),
                cellAlignment: pw.Alignment.centerLeft,
                data: <List<String>>[
                  <String>['Exercise', 'Duration', 'Calories Burned'],
                  for (var w in workouts)
                    <String>[w['title'] ?? 'Workout', '${w['durationMinutes']} mins', '${w['calories']} kcal'],
                ],
              ),
            
            pw.SizedBox(height: 32),

            // Meals Section
            pw.Text('MEALS & SUPPLEMENTS', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#2C2A28'), letterSpacing: 1.5)),
            pw.SizedBox(height: 12),
            if (meals.isEmpty)
              pw.Text('No meals logged.', style: pw.TextStyle(color: PdfColor.fromHex('#8F8A83')))
            else
              pw.TableHelper.fromTextArray(
                context: context,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#FFFFFF')),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#8B7D6B')),
                rowDecoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#E0DCD3'), width: 0.5)),
                ),
                cellStyle: pw.TextStyle(color: PdfColor.fromHex('#2C2A28')),
                cellAlignment: pw.Alignment.centerLeft,
                data: <List<String>>[
                  <String>['Food Item', 'Portion', 'Calories Eaten'],
                  for (var m in meals)
                    <String>[m['food'] ?? m['title'] ?? 'Meal', '${m['weightGrams']} g', '${m['calories']} kcal'],
                ],
              ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: pw.EdgeInsets.only(top: 20),
            child: pw.Text('Generated by FitNova', style: pw.TextStyle(color: PdfColor.fromHex('#8F8A83'), fontSize: 10)),
          );
        },
      ),
    );

    final bytes = await doc.save();
    
    // Universally use Printing.sharePdf. 
    // On Web, it downloads the file.
    // On Android/iOS, it opens the native share sheet (allowing Save to Files, WhatsApp, etc.), 
    // bypassing all Android 13+ Scoped Storage Permission errors!
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'FitNova_Report_$_formattedDate.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge!.color!),
        title: Text('Report: $_formattedDate', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchDailyData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading report: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          }

          final data = snapshot.data!;
          final meals = data['meals'] as List;
          final workouts = data['workouts'] as List;

          int totalCaloriesIn = meals.fold(0, (sum, item) => sum + (item['calories'] as num).toInt());
          int totalCaloriesOut = workouts.fold(0, (sum, item) => sum + (item['calories'] as num).toInt());
          int netCalories = totalCaloriesIn - totalCaloriesOut;

          return Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, 'Eaten', '$totalCaloriesIn kcal', Colors.greenAccent)),
                    SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, 'Burned', '$totalCaloriesOut kcal', Colors.orangeAccent)),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text('Net Balance', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('$netCalories kcal', style: TextStyle(color: AppTheme.primaryAccent, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Detailed Breakdown List
                Expanded(
                  child: ListView(
                    children: [
                      Text('Workouts', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      if (workouts.isEmpty) Text('No workouts logged.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!)),
                      ...workouts.map((w) => ListTile(
                        leading: Icon(Icons.fitness_center, color: Colors.orangeAccent),
                        title: Text(w['title'] ?? 'Workout', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!)),
                        trailing: Text('-${w['calories']} kcal', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      )),
                      
                      SizedBox(height: 24),
                      
                      Text('Meals & Supplements', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      if (meals.isEmpty) Text('No meals logged.', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!)),
                      ...meals.map((m) => ListTile(
                        leading: Icon(Icons.restaurant, color: Colors.greenAccent),
                        title: Text(m['food'] ?? m['title'] ?? 'Meal', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!)),
                        trailing: Text('+${m['calories']} kcal', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      )),
                    ],
                  ),
                ),
                
                // PDF Button
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => _generatePdf(context, data),
                    icon: Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: Text('Download PDF Report', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: AppTheme.primaryAccent.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!, fontSize: 14)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStatCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFFFFF'),
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: PdfColor.fromHex('#E0DCD3'), width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(color: PdfColor.fromHex('#8F8A83'), fontSize: 10)),
          pw.SizedBox(height: 8),
          pw.Text('$value kcal', style: pw.TextStyle(color: color, fontSize: 18, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}


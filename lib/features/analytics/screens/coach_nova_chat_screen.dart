import 'package:fitnova/core/secrets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';

class CoachNovaChatScreen extends StatefulWidget {
  CoachNovaChatScreen({super.key});

  @override
  State<CoachNovaChatScreen> createState() => _CoachNovaChatScreenState();
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class _CoachNovaChatScreenState extends State<CoachNovaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final String _openAiApiKey = openAiApiKey;
  
  String _systemContext = "You are Coach Nova, an elite AI fitness coach for the app Fitnova. Be concise, motivating, and highly analytical.";

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(text: "Hey there! I'm Coach Nova. I've analyzed your recent logs. What's on your mind today?", isUser: false));
  }

  Future<String> _fetchUserContext() async {
    final user = _auth.currentUser;
    if (user == null) return "";
    try {
      final today = DateTime.now();
      final weekAgo = today.subtract(Duration(days: 6));
      final weekAgoIso = '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';
      
      final todayIso = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('logged_meals')
          .where('date', isGreaterThanOrEqualTo: weekAgoIso)
          .get();

      int totalCals = 0;
      for (var doc in snapshot.docs) {
        totalCals += (doc.data()['calories'] as num?)?.toInt() ?? 0;
      }
      
      final trackingDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('daily_tracking')
          .doc(todayIso)
          .get();

      final trackingData = trackingDoc.data() ?? {};
      final waterIntake = trackingData['waterIntake'] ?? 0;
      final steps = trackingData['steps'] ?? 0;
      final activeMin = trackingData['activeMinutes'] ?? 0;
      final sleep = trackingData['sleepHours'] ?? 0;

      // Calculate today's workout task
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final String routineId = userData['routineId'] ?? '3_DAY_CYCLE_1';
      final Timestamp? startDate = userData['routineStartDate'];
      
      final List<Map<String, dynamic>> routines = [
        {
          'id': '3_DAY_CYCLE_1',
          'cycle': [
            {'title': 'Push (Chest, Tricep, Shoulder)'},
            {'title': 'Pull (Back, Bicep)'},
            {'title': 'Legs & Arms'},
          ],
        },
        {
          'id': '3_DAY_CYCLE_2',
          'cycle': [
            {'title': 'Push (Chest, Tricep)'},
            {'title': 'Pull (Back, Bicep)'},
            {'title': 'Legs, Shoulder & Arms'},
          ],
        },
        {
          'id': '5_DAY_CYCLE',
          'cycle': [
            {'title': 'Push (Chest, Tricep)'},
            {'title': 'Pull (Back, Bicep)'},
            {'title': 'Legs, Shoulder & Arms'},
            {'title': 'Upper Body'},
            {'title': 'Lower Body'},
          ],
        },
      ];
      
      final currentRoutine = routines.firstWhere((r) => r['id'] == routineId, orElse: () => routines[0]);
      final cycleList = currentRoutine['cycle'] as List;
      
      String todaysWorkout = "Rest Day";
      if (startDate != null) {
        final start = startDate.toDate();
        final cleanStart = DateTime(start.year, start.month, start.day);
        final cleanDay = DateTime(today.year, today.month, today.day);
        
        int diff = cleanDay.difference(cleanStart).inDays;
        int dayOfCycle = (diff % cycleList.length + cycleList.length) % cycleList.length;
        todaysWorkout = cycleList[dayOfCycle]['title'] ?? "Rest Day";
      }

      final List<dynamic> tasks = userData['tasks'] ?? [];
      String taskString = "No tasks scheduled for today.";
      if (tasks.isNotEmpty) {
        final taskList = tasks.map((t) => "- ${t['title']} at ${t['time']} (${t['isDone'] ? 'Done' : 'Pending'})").join(", ");
        taskString = "Today's scheduled tasks: $taskList.";
      }

      return "The user has consumed approximately $totalCals kcal in the last 7 days. Today they have drank $waterIntake glasses of water, taken $steps steps, have $activeMin active minutes, and $sleep hours of sleep. The user's scheduled workout task for today is: '$todaysWorkout'. $taskString Inform them of this if they ask.";
    } catch (e) {
      return "";
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Prepare message history
    final dynamicContext = await _fetchUserContext();
    List<Map<String, String>> apiMessages = [
      {'role': 'system', 'content': '$_systemContext $dynamicContext'}
    ];

    for (var msg in _messages) {
      apiMessages.add({'role': msg.isUser ? 'user' : 'assistant', 'content': msg.text});
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': apiMessages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        final reply = resData['choices'][0]['message']['content'];
        setState(() {
          _messages.add(ChatMessage(text: reply, isUser: false));
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(text: "Sorry, I'm having trouble connecting right now.", isUser: false));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "An error occurred.", isUser: false));
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyLarge!.color!),
        title: Row(
          children: [
            Icon(Icons.psychology, color: AppTheme.primaryAccent),
            SizedBox(width: 8),
            Text('Coach Nova', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppTheme.primaryAccent),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? AppTheme.primaryAccent : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Theme.of(context).colorScheme.surface : Theme.of(context).textTheme.bodyLarge!.color!,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!),
              decoration: InputDecoration(
                hintText: 'Ask Nova anything...',
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.6)),
                border: InputBorder.none,
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primaryAccent,
            radius: 24,
            child: IconButton(
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.surface, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}


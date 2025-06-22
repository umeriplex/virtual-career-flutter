// interview_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/core/components/custom_text_field.dart';
import 'package:virtual_career/features/mock_interview/view/result_view.dart';

import '../../../core/constant/app_constants.dart';
import '../model/interview_model.dart';

class InterviewScreen extends StatefulWidget {
  final InterviewCategory category;
  final InterviewLevel level;

  const InterviewScreen({
    super.key,
    required this.category,
    required this.level,
  });

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _interviewStarted = false;
  bool _interviewCompleted = false;
  InterviewResult? _result;
  int _currentQuestionIndex = 0;
  List<InterviewQuestion> _questions = [];

  // Gemini API setup
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showInterviewInstructions();
    });
  }

  void _initializeGemini() {
    const apiKey = AppConstants.geminiKey; // Replace with your actual API key
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
    _chat = _model.startChat();
  }

  Future<void> _showInterviewInstructions() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Interview Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${widget.category.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Level: ${widget.level.name}'),
            const SizedBox(height: 16),
            const Text('This interview will consist of:'),
            Text('- ${widget.level.questionCount} questions'),
            const Text('- Text-based conversation'),
            const Text('- Evaluation after each answer'),
            const SizedBox(height: 16),
            const Text(
              'Please provide thoughtful answers to the best of your ability.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startInterview();
            },
            child: const Text('Start Interview'),
          ),
        ],
      ),
    );
  }

  Future<void> _startInterview() async {
    setState(() {
      _interviewStarted = true;
    });

    // Generate interview questions based on category and level
    final prompt = '''
    You are conducting a ${widget.level.name.toLowerCase()} level interview about ${widget.category.name}.
    Generate ${widget.level.questionCount} interview questions in JSON format like this:
    {
      "questions": [
        {"question": "Question 1"},
        {"question": "Question 2"}
      ]
    }
    Questions should progress from basic to advanced concepts.
    Return only the JSON, no additional text.
    ''';

    try {
      setState(() => _isLoading = true);
      final response = await _model.generateContent([Content.text(prompt)]);
      var jsonResponse = response.text ?? '';

      if (jsonResponse.startsWith('```json') || jsonResponse.startsWith('```')) {
        jsonResponse = jsonResponse.substring(7);
      }
      if (jsonResponse.endsWith('```json') || jsonResponse.endsWith('```')) {
        jsonResponse = jsonResponse.substring(0, jsonResponse.length - 3);
      }

      // Parse the questions
      final parsed = json.decode(jsonResponse);
      final questions = (parsed['questions'] as List)
          .map((q) => InterviewQuestion(question: q['question']))
          .toList();

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      // Ask the first question
      _askQuestion(0);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to start interview. Please try again.');
    }
  }

  void _askQuestion(int index) {
    if (index >= _questions.length) {
      _completeInterview();
      return;
    }

    setState(() {
      _currentQuestionIndex = index;
      _messages.add(ChatMessage(
        content: _questions[index].question,
        isUser: false,
      ));
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    if(_isLoading){
      return;
    }

    setState(() {
      _messages.add(ChatMessage(content: message, isUser: true));
      _messageController.clear();
    });

    _scrollToBottom();

    if (_interviewCompleted) return;

    // Evaluate the answer
    await _evaluateAnswer(message);
  }

  Future<void> _evaluateAnswer(String answer) async {
    setState(() => _isLoading = true);

    try {
      final currentQuestion = _questions[_currentQuestionIndex].question;

      final prompt = '''
      Evaluate this interview answer and return JSON response:
      {
        "valid": boolean, // whether answer is relevant
        "error": string?, // if answer is not valid
        "ideal_answer": string?, // if answer is valid
        "score": number?, // 0-100 score for the answer
        "feedback": string? // brief feedback
      }

      Question: "$currentQuestion"
      Answer: "$answer"

      Rules:
      - If answer is irrelevant (like "haha", "lala", etc.), set valid=false and provide error
      - If answer is relevant, provide ideal answer, score and feedback
      - Score should consider accuracy, depth and clarity
      - Return only JSON, no additional text
      ''';

      var response = await _model.generateContent([Content.text(prompt)]);
      var jsonResponseText = response.text ?? '';

      debugPrint("_evaluateAnswer: $response, : $jsonResponseText");


      if (jsonResponseText.startsWith('```json') || jsonResponseText.startsWith('```')) {
        jsonResponseText = jsonResponseText.substring(7);
      }
      if (jsonResponseText.endsWith('```json') || jsonResponseText.endsWith('```')) {
        jsonResponseText = jsonResponseText.substring(0, jsonResponseText.length - 3);
      }

      debugPrint("_evaluateAnswer: $response, : $jsonResponseText");




      final jsonResponse = json.decode(jsonResponseText);

      if (jsonResponse['valid'] == false) {
        _messages.add(ChatMessage(
          content: jsonResponse['error'] ?? 'Please provide a relevant answer',
          isUser: false,
        ));
      } else {
        // Store the evaluation
        _questions[_currentQuestionIndex] = InterviewQuestion(
          question: currentQuestion,
          userAnswer: answer,
          idealAnswer: jsonResponse['ideal_answer'],
          score: jsonResponse['score']?.toDouble(),
        );

        // Add feedback to chat
        _messages.add(ChatMessage(
          content: jsonResponse['feedback'] ?? 'Thank you for your answer',
          isUser: false,
        ));

        // Ask next question after a delay
        Future.delayed(const Duration(seconds: 2), () {
          _askQuestion(_currentQuestionIndex + 1);
        });
      }
    } catch (e) {
      _messages.add(ChatMessage(
        content: 'Error evaluating answer. Please try again.',
        isUser: false,
      ));
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> _completeInterview() async {
    setState(() {
      _interviewCompleted = true;
      _isLoading = true;
    });

    // Calculate overall score
    final answeredQuestions = _questions.where((q) => q.score != null).toList();
    final totalScore = answeredQuestions.isEmpty
        ? 0
        : answeredQuestions.map((q) => q.score!).reduce((a, b) => a + b) /
        answeredQuestions.length;

    // Generate feedback
    final prompt = '''
  Generate interview results in JSON format:
  {
    "overall_score": number, // 0-100
    "strengths": [string], // list of strengths
    "improvements": [string], // list of areas to improve
    "summary": string // detailed summary paragraph
  }

  Based on these answers:
  ${_questions.map((q) => 'Q: ${q.question}\nA: ${q.userAnswer ?? "No answer"}').join('\n\n')}

  Rules:
  - Be constructive and specific
  - Highlight 2-3 strengths
  - Suggest 2-3 improvements
  - Provide a 3-4 sentence summary
  - Return only JSON, no additional text or markdown
  ''';

    try {
      setState(() => _isLoading = true);
      final response = await _model.generateContent([Content.text(prompt)]);
      var jsonResponseText = response.text ?? '{}';

      // Clean up the response if it contains markdown code blocks
      jsonResponseText = jsonResponseText.replaceAll('```json', '').replaceAll('```', '').trim();

      final jsonResponse = json.decode(jsonResponseText);

      // Create the result object
      final result = InterviewResult(
        overallScore: totalScore.toDouble(),
        strengths: List<String>.from(jsonResponse['strengths'] ?? []),
        improvements: List<String>.from(jsonResponse['improvements'] ?? []),
        questions: _questions,
        summary: jsonResponse['summary'] ?? 'No summary available',
        completedAt: DateTime.now(),
      );

      // Navigate to results screen instead of showing dialog
      Get.offNamed(RouteNames.interviewResult, arguments: { "category" : widget.category, "level" : widget.level, "result" : result });


    } catch (e) {
      debugPrint('Error parsing interview results: $e');
      setState(() => _isLoading = false);

      // Fallback if JSON parsing fails
      final result = InterviewResult(
        overallScore: totalScore.toDouble(),
        strengths: ['Good communication skills'],
        improvements: ['Could use more technical depth'],
        questions: _questions,
        summary: 'You completed the interview with an overall score of ${totalScore.toStringAsFixed(1)}%. '
            'Review your answers to identify areas for improvement.',
        completedAt: DateTime.now(),
      );

      Get.offNamed(RouteNames.interviewResult, arguments: { "category" : widget.category, "level" : widget.level, "result" : result });
    }
  }

  void _showResults() {
    if (_result == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Interview Results'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Overall Score: ${_result!.overallScore.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Strengths:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._result!.strengths.map((s) => Text('- $s')).toList(),
              const SizedBox(height: 16),
              const Text(
                'Areas for Improvement:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._result!.improvements.map((i) => Text('- $i')).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.name} Interview'),
        actions: [
          if (_interviewStarted && !_interviewCompleted)
            TextButton(
              onPressed: _completeInterview,
              child: const Text(
                'End Interview',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(
                  message: message,
                  isLoading: _isLoading && index == _messages.length - 1,
                );
              },
            ),
          ),
          if (_interviewStarted && !_interviewCompleted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Expanded(
                  //   child: TextField(
                  //     controller: _messageController,
                  //     decoration: InputDecoration(
                  //       hintText: 'Type your answer...',
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(24),
                  //       ),
                  //       contentPadding: const EdgeInsets.symmetric(
                  //         horizontal: 16,
                  //         vertical: 12,
                  //       ),
                  //     ),
                  //     onSubmitted: (_) => _sendMessage(),
                  //   ),
                  // ),
                  Expanded(
                    child: CustomTextField(
                      controller: _messageController,
                      hintText: "type your answer...",
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLoading;

  const _ChatBubble({
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: message.isUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: message.isUser
                ? Theme.of(context).primaryColor
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  message.content,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                DateFormat('hh:mm a').format(message.timestamp),
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white70
                      : Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
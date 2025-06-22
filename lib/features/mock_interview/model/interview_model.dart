// interview_model.dart
class InterviewCategory {
  final String id;
  final String name;
  final String icon;

  InterviewCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class InterviewLevel {
  final String id;
  final String name;
  final int questionCount;

  InterviewLevel({
    required this.id,
    required this.name,
    required this.questionCount,
  });
}

class InterviewQuestion {
  final String question;
  final String? idealAnswer;
  final String? userAnswer;
  final double? score;

  InterviewQuestion({
    required this.question,
    this.idealAnswer,
    this.userAnswer,
    this.score,
  });
}

// interview_model.dart
class InterviewResult {
  final double overallScore;
  final List<String> strengths;
  final List<String> improvements;
  final List<InterviewQuestion> questions;
  final String summary;
  final DateTime completedAt;

  InterviewResult({
    required this.overallScore,
    required this.strengths,
    required this.improvements,
    required this.questions,
    required this.summary,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
// lib/models/exam_models.dart

class ExamListItem {
  final int id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;

  ExamListItem({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
  });

  factory ExamListItem.fromJson(Map<String, dynamic> j) => ExamListItem(
        id: j['id'],
        title: j['title'],
        durationMinutes: j['durationMinutes'],
        totalQuestions: j['totalQuestions'],
      );
}

class QuestionOption {
  final String optionKey;
  final String optionText;
  QuestionOption({required this.optionKey, required this.optionText});
  factory QuestionOption.fromJson(Map<String, dynamic> j) =>
      QuestionOption(optionKey: j['optionKey'], optionText: j['optionText']);
}

class QuestionDto {
  final int id;
  final int questionNumber;
  final String questionText;
  final List<QuestionOption> options;
  QuestionDto({required this.id, required this.questionNumber, required this.questionText, required this.options});
  factory QuestionDto.fromJson(Map<String, dynamic> j) => QuestionDto(
        id: j['id'],
        questionNumber: j['questionNumber'],
        questionText: j['questionText'],
        options: (j['options'] as List).map((o) => QuestionOption.fromJson(o)).toList(),
      );
}

class PassageGroupDto {
  final int id;
  final String? passageText;
  final String? imagePath;
  final int partNumber;
  final List<QuestionDto> questions;
  PassageGroupDto({required this.id, this.passageText, this.imagePath, required this.partNumber, required this.questions});
  factory PassageGroupDto.fromJson(Map<String, dynamic> j) => PassageGroupDto(
        id: j['id'],
        passageText: j['passageText'],
        imagePath: j['imagePath'],
        partNumber: j['partNumber'],
        questions: (j['questions'] as List).map((q) => QuestionDto.fromJson(q)).toList(),
      );
}

class ExamDetail {
  final int id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final List<QuestionDto> level1Questions;
  final List<PassageGroupDto> level2Groups;

  ExamDetail({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.level1Questions,
    required this.level2Groups,
  });

  factory ExamDetail.fromJson(Map<String, dynamic> j) => ExamDetail(
        id: j['id'],
        title: j['title'],
        durationMinutes: j['durationMinutes'],
        totalQuestions: j['totalQuestions'],
        level1Questions: (j['level1Questions'] as List).map((q) => QuestionDto.fromJson(q)).toList(),
        level2Groups: (j['level2Groups'] as List).map((g) => PassageGroupDto.fromJson(g)).toList(),
      );

  /// Trả về tất cả câu hỏi theo thứ tự số câu
  List<QuestionDto> get allQuestions {
    final all = <QuestionDto>[...level1Questions];
    for (final g in level2Groups) {
      all.addAll(g.questions);
    }
    all.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    return all;
  }
}

class ExamResult {
  final long attemptId;
  final int totalCorrect;
  final int totalWrong;
  final int totalSkipped;
  final double scorePercent;

  ExamResult({
    required this.attemptId,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalSkipped,
    required this.scorePercent,
  });

  factory ExamResult.fromJson(Map<String, dynamic> j) => ExamResult(
        attemptId: j['attemptId'],
        totalCorrect: j['totalCorrect'],
        totalWrong: j['totalWrong'],
        totalSkipped: j['totalSkipped'],
        scorePercent: (j['scorePercent'] as num).toDouble(),
      );
}

// ignore: non_constant_identifier_names
typedef long = int;

// lib/services/exam_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/exam_models.dart';

class ExamService {
  static final ExamService _instance = ExamService._internal();
  factory ExamService() => _instance;
  ExamService._internal();

  final String _base = AppConfig.baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Thêm Authorization header nếu dùng JWT:
        // 'Authorization': 'Bearer $token',
      };

  // ──────────────────────────────────────────────────────────────
  // Danh sách đề thi
  // ──────────────────────────────────────────────────────────────
  Future<List<ExamListItem>> getExams() async {
    final resp = await http.get(
      Uri.parse('$_base/api/exam/list'),
      headers: _headers,
    );
    _checkStatus(resp);
    final decoded = jsonDecode(resp.body);
    final List data = (decoded is Map && decoded.containsKey('result'))
        ? (decoded['result'] as List)
        : (decoded as List);
    return data.map((j) => ExamListItem.fromJson(j)).toList();
  }

  // ──────────────────────────────────────────────────────────────
  // Chi tiết đề thi
  // ──────────────────────────────────────────────────────────────
  Future<ExamDetail> getExamDetail(int examId) async {
    final resp = await http.get(
      Uri.parse('$_base/api/exam/detail/$examId'),
      headers: _headers,
    );
    _checkStatus(resp);
    final decoded = jsonDecode(resp.body);
    final Map<String, dynamic> data = (decoded is Map && decoded.containsKey('result'))
        ? (decoded['result'] as Map<String, dynamic>)
        : (decoded as Map<String, dynamic>);
    return ExamDetail.fromJson(data);
  }

  // ──────────────────────────────────────────────────────────────
  // Bắt đầu lần thi
  // ──────────────────────────────────────────────────────────────
  Future<int> startAttempt(int examId) async {
    final resp = await http.post(
      Uri.parse('$_base/api/exam/start/$examId'),
      headers: _headers,
    );
    _checkStatus(resp);
    final decoded = jsonDecode(resp.body);
    final Map<String, dynamic> data = (decoded is Map && decoded.containsKey('result'))
        ? (decoded['result'] as Map<String, dynamic>)
        : (decoded as Map<String, dynamic>);
    return data['attemptId'] as int;
  }

  // ──────────────────────────────────────────────────────────────
  // Nộp bài
  // ──────────────────────────────────────────────────────────────
  Future<ExamResult> submitAttempt({
    required int attemptId,
    required Map<int, String?> answers, // questionId → selectedAnswer
    required bool isTimedOut,
  }) async {
    final body = {
      'attemptId': attemptId,
      'isTimedOut': isTimedOut,
      'answers': answers.entries
          .map((e) => {'questionId': e.key, 'selectedAnswer': e.value})
          .toList(),
    };

    final resp = await http.post(
      Uri.parse('$_base/api/exam/submit'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _checkStatus(resp);
    final decoded = jsonDecode(resp.body);
    final Map<String, dynamic> data = (decoded is Map && decoded.containsKey('result'))
        ? (decoded['result'] as Map<String, dynamic>)
        : (decoded as Map<String, dynamic>);
    return ExamResult.fromJson(data);
  }

  void _checkStatus(http.Response resp) {
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final msg = _tryParseError(resp.body);
      throw Exception('Lỗi server (${resp.statusCode}): $msg');
    }
  }

  String _tryParseError(String body) {
    try {
      final j = jsonDecode(body);
      return j['message'] ?? body;
    } catch (_) {
      return body;
    }
  }
}

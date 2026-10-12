// lib/screens/exam_taking_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/exam_models.dart';
import '../services/exam_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class ExamTakingScreen extends StatefulWidget {
  final int examId;
  final String examTitle;
  const ExamTakingScreen({super.key, required this.examId, required this.examTitle});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen>
    with TickerProviderStateMixin {
  final _service = ExamService();
  ExamDetail? _exam;
  List<QuestionDto> _allQuestions = [];
  int _currentIndex = 0;
  int? _attemptId;
  final Map<int, String?> _answers = {};

  late Timer _timer;
  int _secondsLeft = 75 * 60;
  bool _loading = true;
  bool _submitted = false;
  bool _warned5Min = false;
  bool _isTimeUp = false;

  late AnimationController _questionAnim;
  late Animation<double> _questionFade;
  late Animation<Offset> _questionSlide;

  @override
  void initState() {
    super.initState();
    _questionAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _questionFade = CurvedAnimation(parent: _questionAnim, curve: Curves.easeOut);
    _questionSlide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _questionAnim, curve: Curves.easeOut));
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final exam = await _service.getExamDetail(widget.examId);
      final attemptId = await _service.startAttempt(widget.examId);
      setState(() {
        _exam = exam;
        _allQuestions = exam.allQuestions;
        _attemptId = attemptId;
        _loading = false;
      });
      _startTimer();
      _questionAnim.forward();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        setState(() => _isTimeUp = true);
        _onTimeUp();
      } else {
        setState(() => _secondsLeft--);
        if (_secondsLeft == 300 && !_warned5Min) {
          _warned5Min = true;
          HapticFeedback.mediumImpact();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text('Còn 5 phút! Hãy kiểm tra lại bài làm.',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ]),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
        }
      }
    });
  }

  void _onTimeUp() async {
    if (_submitted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StyledDialog(
        icon: Icons.timer_off_rounded,
        iconColor: AppColors.danger,
        title: 'Hết Giờ!',
        content: 'Thời gian làm bài đã kết thúc.\nBài thi sẽ được tự động nộp.',
        actions: [
          _DialogButton(
            label: 'Nộp Bài',
            color: AppColors.danger,
            onTap: () {
              Navigator.pop(context);
              _submitExam(isTimedOut: true);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSubmit() async {
    final unanswered = _allQuestions.where((q) => _answers[q.id] == null).length;
    bool proceed = true;

    if (unanswered > 0) {
      proceed = await showDialog<bool>(
            context: context,
            builder: (_) => _StyledDialog(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
              title: 'Còn Câu Chưa Làm',
              content: 'Bạn còn $unanswered câu chưa trả lời.\nBạn có chắc muốn nộp bài không?',
              actions: [
                _DialogButton(
                  label: 'Tiếp Tục Làm',
                  color: AppColors.textSecondary,
                  outlined: true,
                  onTap: () => Navigator.pop(context, false),
                ),
                _DialogButton(
                  label: 'Nộp Bài',
                  color: AppColors.warning,
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ) ??
          false;
    }

    if (proceed) _submitExam(isTimedOut: false);
  }

  Future<void> _submitExam({required bool isTimedOut}) async {
    if (_submitted || _attemptId == null) return;
    _submitted = true;
    _timer.cancel();

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang nộp bài...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final result = await _service.submitAttempt(
        attemptId: _attemptId!,
        answers: _answers,
        isTimedOut: isTimedOut,
      );

      if (mounted) {
        Navigator.pop(context); // dismiss loading
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, anim, __) => FadeTransition(
              opacity: anim,
              child: ResultScreen(result: result, examTitle: widget.examTitle),
            ),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Nộp bài thất bại: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        _submitted = false;
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _questionAnim.dispose();
    super.dispose();
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _timerColor {
    if (_secondsLeft > 600) return AppColors.success;
    if (_secondsLeft > 180) return AppColors.warning;
    return AppColors.danger;
  }

  void _goToQuestion(int index) {
    if (index == _currentIndex) return;
    _questionAnim.reverse().then((_) {
      setState(() => _currentIndex = index);
      _questionAnim.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Đang tải đề thi...',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }
    if (_allQuestions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('Không có câu hỏi',
              style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
        ),
      );
    }

    final q = _allQuestions[_currentIndex];
    final isL2 =
        _exam!.level2Groups.any((g) => g.questions.any((qq) => qq.id == q.id));
    PassageGroupDto? passage;
    if (isL2) {
      passage = _exam!.level2Groups
          .firstWhere((g) => g.questions.any((qq) => qq.id == q.id));
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildTopBar(),
          _buildProgressBar(),
          Expanded(
            child: SlideTransition(
              position: _questionSlide,
              child: FadeTransition(
                opacity: _questionFade,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      if (passage != null) ...[
                        _PassageCard(passage: passage),
                        const SizedBox(height: 12),
                      ],
                      _QuestionCard(
                        question: q,
                        questionIndex: _currentIndex,
                        selectedAnswer: _answers[q.id],
                        onAnswerSelected: (key) {
                          if (_isTimeUp) return;
                          HapticFeedback.selectionClick();
                          setState(() => _answers[q.id] = key);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              // Back / Nộp bài
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => _StyledDialog(
                      icon: Icons.exit_to_app_rounded,
                      iconColor: AppColors.warning,
                      title: 'Thoát Bài Thi?',
                      content: 'Tiến độ bài làm sẽ bị mất nếu bạn thoát ra.',
                      actions: [
                        _DialogButton(
                          label: 'Ở Lại',
                          color: AppColors.primary,
                          onTap: () => Navigator.pop(context, false),
                        ),
                        _DialogButton(
                          label: 'Thoát',
                          color: AppColors.danger,
                          outlined: true,
                          onTap: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && mounted) Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.examTitle,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Timer
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _timerColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _timerColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, color: _timerColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _timerText,
                      style: GoogleFonts.inter(
                          color: _timerColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          fontFeatures: [const FontFeature.tabularFigures()]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final answered = _answers.values.where((v) => v != null).length;
    final total = _allQuestions.length;
    return Container(
      color: AppColors.primary.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Câu ${_currentIndex + 1}/$total',
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / total,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$answered đã làm',
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isLast = _currentIndex >= _allQuestions.length - 1;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // Previous
              _NavButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: _currentIndex > 0
                    ? () => _goToQuestion(_currentIndex - 1)
                    : null,
              ),
              const SizedBox(width: 12),
              // Overview
              Expanded(
                child: GestureDetector(
                  onTap: _showOverview,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.grid_view_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 5),
                            Text(
                              'Tổng Quan',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_answers.values.where((v) => v != null).length}/${_allQuestions.length} câu',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Next or Submit
              if (!isLast)
                _NavButton(
                  icon: Icons.arrow_forward_ios_rounded,
                  onTap: () => _goToQuestion(_currentIndex + 1),
                  filled: true,
                )
              else
                GestureDetector(
                  onTap: _confirmSubmit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Nộp Bài',
                            style: GoogleFonts.inter(
                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOverview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Text('Tổng Quan Bài Làm',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    // Legend
                    _OverviewLegend(Colors.green, 'Đã làm'),
                    const SizedBox(width: 10),
                    _OverviewLegend(AppColors.border, 'Chưa làm'),
                    const SizedBox(width: 10),
                    _OverviewLegend(AppColors.primary, 'Đang xem'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(height: 1, color: AppColors.border),
              ),
              const SizedBox(height: 8),
              // Stats row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _OverviewStat(
                      label: 'Đã làm',
                      value: _answers.values.where((v) => v != null).length.toString(),
                      color: AppColors.success,
                    ),
                    Container(width: 1, height: 40, color: AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _OverviewStat(
                      label: 'Chưa làm',
                      value: (_allQuestions.length -
                              _answers.values.where((v) => v != null).length)
                          .toString(),
                      color: AppColors.textSecondary,
                    ),
                    Container(width: 1, height: 40, color: AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _OverviewStat(
                      label: 'Tổng số',
                      value: _allQuestions.length.toString(),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _allQuestions.length,
                  itemBuilder: (_, i) {
                    final qq = _allQuestions[i];
                    final answered = _answers[qq.id] != null;
                    final isCurrent = i == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _goToQuestion(i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primary
                              : answered
                                  ? AppColors.success.withOpacity(0.15)
                                  : AppColors.bg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.primary
                                : answered
                                    ? AppColors.success
                                    : AppColors.border,
                            width: isCurrent ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${qq.questionNumber}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: isCurrent
                                    ? Colors.white
                                    : answered
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                              ),
                            ),
                            if (answered && !isCurrent)
                              const SizedBox(height: 2),
                            if (answered && !isCurrent)
                              const Icon(Icons.check, size: 10, color: AppColors.success),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _confirmSubmit();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text('Nộp Bài Ngay',
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// WIDGETS
// ──────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  const _NavButton({required this.icon, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: filled
              ? (enabled ? AppColors.primary : AppColors.border)
              : (enabled ? AppColors.bg : AppColors.bg),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: filled
                  ? Colors.transparent
                  : (enabled ? AppColors.primary : AppColors.border)),
        ),
        alignment: Alignment.center,
        child: Icon(icon,
            size: 18,
            color: filled
                ? Colors.white
                : (enabled ? AppColors.primary : AppColors.textHint)),
      ),
    );
  }
}

class _OverviewLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _OverviewLegend(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
        ],
      );
}

class _OverviewStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _OverviewStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      );
}

// ─── Passage Card ────────────────────────────────────────────────────────────

class _PassageCard extends StatefulWidget {
  final PassageGroupDto passage;
  const _PassageCard({required this.passage});

  @override
  State<_PassageCard> createState() => _PassageCardState();
}

class _PassageCardState extends State<_PassageCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.08),
                    AppColors.primary.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: _expanded ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Part ${widget.passage.partNumber}',
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Đọc Đoạn Văn',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 14),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.passage.imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(widget.passage.imagePath!, fit: BoxFit.contain),
                    ),
                  if (widget.passage.passageText != null)
                    Text(
                      widget.passage.passageText!,
                      style: GoogleFonts.inter(
                          fontSize: 14, height: 1.7, color: AppColors.textPrimary),
                    ),
                ],
              ),
            ),
            secondChild: const SizedBox(height: 0),
            crossFadeState:
                _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ─── Question Card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final QuestionDto question;
  final int questionIndex;
  final String? selectedAnswer;
  final ValueChanged<String?> onAnswerSelected;

  const _QuestionCard({
    required this.question,
    required this.questionIndex,
    this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Câu ${questionIndex + 1}  •  TOEIC #${question.questionNumber}',
                    style: GoogleFonts.inter(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
                const Spacer(),
                if (selectedAnswer != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text('Đã chọn $selectedAnswer',
                            style: GoogleFonts.inter(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Question text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              question.questionText,
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w600, height: 1.6,
                  color: AppColors.textPrimary),
            ),
          ),
          // Options
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: question.options.map((opt) => _OptionTile(
                    option: opt,
                    isSelected: selectedAnswer == opt.optionKey,
                    onTap: () => onAnswerSelected(
                        selectedAnswer == opt.optionKey ? null : opt.optionKey),
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatefulWidget {
  final QuestionOption option;
  final bool isSelected;
  final VoidCallback onTap;
  const _OptionTile({required this.option, required this.isSelected, required this.onTap});

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primary.withOpacity(0.06)
                : AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : AppColors.border,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isSelected ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.option.optionKey,
                  style: GoogleFonts.inter(
                    color: widget.isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.option.optionText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: widget.isSelected ? AppColors.primary : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
              if (widget.isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dialog ───────────────────────────────────────────────────────────────────

class _StyledDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final List<_DialogButton> actions;

  const _StyledDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(content,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: actions.length > 1
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.center,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(10),
          border: outlined ? Border.all(color: color) : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: outlined ? color : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

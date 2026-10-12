// lib/screens/result_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/exam_models.dart';
import '../theme/app_theme.dart';
import 'exam_list_screen.dart';

class ResultScreen extends StatefulWidget {
  final ExamResult result;
  final String examTitle;

  const ResultScreen({super.key, required this.result, required this.examTitle});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnim;
  late AnimationController _fadeAnim;
  late Animation<double> _scoreTween;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();

    _scoreAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _scoreTween = Tween<double>(begin: 0, end: widget.result.scorePercent / 100)
        .animate(CurvedAnimation(parent: _scoreAnim, curve: Curves.easeOutCubic));

    _fadeIn = CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 200), () {
      _scoreAnim.forward();
      _fadeAnim.forward();
    });
  }

  @override
  void dispose() {
    _scoreAnim.dispose();
    _fadeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.result.scorePercent;
    final gradeInfo = _getGradeInfo(score);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: gradeInfo.color,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradeInfo.gradientColors,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      // Score circle
                      AnimatedBuilder(
                        animation: _scoreTween,
                        builder: (_, __) => _AnimatedScoreRing(
                          progress: _scoreTween.value,
                          score: score,
                          grade: gradeInfo.grade,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        gradeInfo.emoji + ' ' + gradeInfo.label,
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.examTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text('Kết Quả Bài Thi',
                  style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              collapseMode: CollapseMode.pin,
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _slideIn,
              child: FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Stats row
                      Row(
                        children: [
                          _StatCard(
                            label: 'Câu Đúng',
                            value: widget.result.totalCorrect,
                            color: AppColors.success,
                            icon: Icons.check_circle_rounded,
                            gradient: AppGradients.successGradient,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            label: 'Câu Sai',
                            value: widget.result.totalWrong,
                            color: AppColors.danger,
                            icon: Icons.cancel_rounded,
                            gradient: AppGradients.dangerGradient,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            label: 'Bỏ Qua',
                            value: widget.result.totalSkipped,
                            color: AppColors.textSecondary,
                            icon: Icons.remove_circle_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Accuracy bar
                      _AccuracySection(result: widget.result),
                      const SizedBox(height: 20),

                      // Feedback
                      _FeedbackCard(score: score, gradeInfo: gradeInfo),
                      const SizedBox(height: 20),

                      // Score breakdown
                      _ScoreBreakdown(result: widget.result),
                      const SizedBox(height: 32),

                      // Action buttons
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, anim, __) => FadeTransition(
                                    opacity: anim,
                                    child: const ExamListScreen(),
                                  ),
                                ),
                                (route) => false,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 10),
                                    Text('Về Danh Sách Đề',
                                        style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Score Ring ──────────────────────────────────────────────────────

class _AnimatedScoreRing extends StatelessWidget {
  final double progress;
  final double score;
  final String grade;
  final Color color;

  const _AnimatedScoreRing({
    required this.progress,
    required this.score,
    required this.grade,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                    fontSize: 32, fontWeight: FontWeight.w900, color: color),
              ),
              Text(grade,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    // Background ring
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Stat Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final Gradient gradient;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              '$value',
              style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── Accuracy Section ────────────────────────────────────────────────────────

class _AccuracySection extends StatelessWidget {
  final ExamResult result;
  const _AccuracySection({required this.result});

  @override
  Widget build(BuildContext context) {
    final total = result.totalCorrect + result.totalWrong + result.totalSkipped;
    final correctPct = total > 0 ? result.totalCorrect / total : 0.0;
    final wrongPct = total > 0 ? result.totalWrong / total : 0.0;
    final skippedPct = total > 0 ? result.totalSkipped / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Phân Tích Kết Quả',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                if (correctPct > 0)
                  Expanded(
                    flex: (correctPct * 100).round(),
                    child: Container(height: 10, color: AppColors.success),
                  ),
                if (wrongPct > 0)
                  Expanded(
                    flex: (wrongPct * 100).round(),
                    child: Container(height: 10, color: AppColors.danger),
                  ),
                if (skippedPct > 0)
                  Expanded(
                    flex: (skippedPct * 100).round(),
                    child: Container(height: 10, color: AppColors.border),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BarLegend(color: AppColors.success,
                  label: 'Đúng (${(correctPct * 100).toStringAsFixed(1)}%)'),
              const SizedBox(width: 16),
              _BarLegend(color: AppColors.danger,
                  label: 'Sai (${(wrongPct * 100).toStringAsFixed(1)}%)'),
              const SizedBox(width: 16),
              _BarLegend(color: AppColors.textHint,
                  label: 'Bỏ (${(skippedPct * 100).toStringAsFixed(1)}%)'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _BarLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ],
      );
}

// ─── Feedback Card ────────────────────────────────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  final double score;
  final _GradeInfo gradeInfo;
  const _FeedbackCard({required this.score, required this.gradeInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradeInfo.color.withOpacity(0.08),
            gradeInfo.color.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradeInfo.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(gradeInfo.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gradeInfo.label,
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w800, color: gradeInfo.color)),
                const SizedBox(height: 4),
                Text(gradeInfo.tip,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score Breakdown ─────────────────────────────────────────────────────────

class _ScoreBreakdown extends StatelessWidget {
  final ExamResult result;
  const _ScoreBreakdown({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Chi Tiết Điểm',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          _ScoreRow('Số câu đúng', '${result.totalCorrect} / ${result.totalCorrect + result.totalWrong + result.totalSkipped}', AppColors.success),
          const SizedBox(height: 10),
          _ScoreRow('Tỷ lệ đúng', '${result.scorePercent.toStringAsFixed(1)}%', AppColors.primary),
          const SizedBox(height: 10),
          _ScoreRow('TOEIC ước tính',
              _estimateToeicScore(result.scorePercent), const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  String _estimateToeicScore(double pct) {
    // Reading section max 495
    final reading = (pct / 100 * 495).round();
    return '~$reading / 495 điểm Reading';
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ScoreRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(value,
                style: GoogleFonts.inter(
                    color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      );
}

// ─── Grade Info ───────────────────────────────────────────────────────────────

class _GradeInfo {
  final String grade;
  final String label;
  final String tip;
  final String emoji;
  final Color color;
  final List<Color> gradientColors;

  const _GradeInfo({
    required this.grade,
    required this.label,
    required this.tip,
    required this.emoji,
    required this.color,
    required this.gradientColors,
  });
}

_GradeInfo _getGradeInfo(double score) {
  if (score >= 90) {
    return const _GradeInfo(
      grade: 'Xuất Sắc',
      label: 'Tuyệt vời! Kết quả xuất sắc!',
      tip: 'Bạn đang ở top learners. Hãy tiếp tục duy trì và cải thiện tốc độ làm bài.',
      emoji: '🏆',
      color: Color(0xFF10B981),
      gradientColors: [Color(0xFF059669), Color(0xFF10B981)],
    );
  } else if (score >= 70) {
    return const _GradeInfo(
      grade: 'Khá',
      label: 'Khá tốt! Tiếp tục cố gắng!',
      tip: 'Bạn đang tiến bộ tốt. Hãy ôn lại những phần còn yếu để đạt điểm cao hơn.',
      emoji: '⭐',
      color: Color(0xFF3B82F6),
      gradientColors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
    );
  } else if (score >= 50) {
    return const _GradeInfo(
      grade: 'Trung Bình',
      label: 'Kết quả trung bình',
      tip: 'Bạn cần ôn luyện thêm. Hãy tập trung vào ngữ pháp và từ vựng để cải thiện.',
      emoji: '💪',
      color: Color(0xFFF59E0B),
      gradientColors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    );
  } else {
    return const _GradeInfo(
      grade: 'Cần Cố Gắng',
      label: 'Đừng nản lòng!',
      tip: 'Hãy ôn tập thêm từ vựng, ngữ pháp và luyện đọc mỗi ngày. Bạn sẽ tiến bộ!',
      emoji: '📚',
      color: Color(0xFFEF4444),
      gradientColors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    );
  }
}

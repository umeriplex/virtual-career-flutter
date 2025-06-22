// result_screen.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:virtual_career/config/routes/route_name.dart';
import 'package:virtual_career/core/components/custom_button.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';

import '../model/interview_model.dart';

class ResultScreen extends StatefulWidget {
  final InterviewResult result;
  final InterviewCategory category;
  final InterviewLevel level;

  const ResultScreen({
    super.key,
    required this.result,
    required this.category,
    required this.level,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.result.overallScore,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      if (widget.result.overallScore > 70) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildScoreCircle() {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 200.w,
          height: 200.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 140.w,
                height: 140.w,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 12,
                  color: Colors.grey[200],
                ),
              ),
              // Score progress
              SizedBox(
                width: 140.w,
                height: 140.w,
                child: CircularProgressIndicator(
                  value: _scoreAnimation.value / 100,
                  strokeWidth: 12,
                  color: _getScoreColor(widget.result.overallScore),
                ),
              ),
              // Score text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${_scoreAnimation.value.toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineOpenSans.copyWith(fontSize: 28),
                  ),
                  Text(
                    widget.result.overallScore > 70 ? 'Excellent!' :
                    widget.result.overallScore > 50 ? 'Good Job!' : 'Keep Practicing!',
                    style: AppTextStyles.captionOpenSans

                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(widget.category.icon, width: 50.w, height: 50.w,),
          const SizedBox(width: 6),
          Text(
            '${widget.category.name} • ${widget.level.name}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms)
        .slide(begin: const Offset(0, -0.2));
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 4, right: 8),
                child: Icon(Icons.circle, size: 8),
              ),
              Expanded(child: Text(item)),
            ],
          ),
        )),
      ],
    )
        .animate()
        .fadeIn(delay: 300.ms)
        .slide(begin: const Offset(0.2, 0));
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(widget.result.summary),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms)
        .slide(begin: const Offset(0, 0.2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Results'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildCategoryBadge(),
                const SizedBox(height: 30),
                _buildScoreCircle(),
                const SizedBox(height: 30),
                _buildSection('Strengths', widget.result.strengths),
                const SizedBox(height: 20),
                _buildSection('Areas for Improvement', widget.result.improvements),
                const SizedBox(height: 20),
                _buildSummaryCard(),
                const SizedBox(height: 20),
                const SizedBox(height: 20),

                CustomButton(title: "Go Home", onPressed: () => Get.offAllNamed(RouteNames.navBar)),
              ],
            ),
          ),
          // Confetti effect for high scores
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.orange,
                Colors.pink,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

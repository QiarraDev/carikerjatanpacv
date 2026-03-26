import 'package:flutter/material.dart';
import '../../core/api_service.dart';

class AssessmentPage extends StatefulWidget {
  final String jobId;
  final String jobTitle;

  const AssessmentPage({super.key, required this.jobId, required this.jobTitle});

  @override
  State<AssessmentPage> createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  List<dynamic> _questions = [];
  int _currentIdx = 0;
  int _score = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    try {
      final response = await ApiService().getAssessment(widget.jobId);
      setState(() {
        _questions = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _answer(int selectedIdx) {
    if (selectedIdx == _questions[_currentIdx]['correct_answer']) {
      _score += 50; // Sesuai dummy (2 soal)
    }

    if (_currentIdx < _questions.length - 1) {
      setState(() => _currentIdx++);
    } else {
      _finishHeader();
    }
  }

  void _finishHeader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Ujian Selesai!'),
        content: Text('Skor Anda: $_score/100'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup Dialog
              Navigator.pop(context, _score); // Kembali ke Home dengan skor
            },
            child: const Text('LANJUTKAN LAMARAN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final q = _questions[_currentIdx];

    return Scaffold(
      appBar: AppBar(title: Text('Tes: ${widget.jobTitle}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (_currentIdx + 1) / _questions.length),
            const SizedBox(height: 32),
            Text(
              'Pertanyaan ${_currentIdx + 1}/${_questions.length}',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              q['question_text'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ...List.generate(
              (q['options'] as List).length,
              (idx) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () => _answer(idx),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                    ),
                    child: Text(q['options'][idx], style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

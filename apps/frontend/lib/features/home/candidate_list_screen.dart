import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/api_service.dart';

class CandidateListScreen extends StatefulWidget {
  const CandidateListScreen({super.key});

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> {
  List<dynamic> _candidates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    try {
      final response = await ApiService().getCandidates();
      final List<dynamic> remoteCandidates = response.data;
      
      // 🎭 DATA DUMMY DENGAN PARAMETER RANKING
      final dummyCandidates = [
        {
          "full_name": "Angga Adi Wibowo",
          "job_title": "Senior Flutter Developer",
          "skills": ["Flutter", "Dart", "Firebase", "Clean Architecture"],
          "video_url": "https://assets.mixkit.co/videos/preview/mixkit-man-working-on-his-laptop-308-large.mp4",
          "skill_match": 0.95,
          "test_score": 90,
          "video_duration": 45,
          "experience": 5,
        },
        {
          "full_name": "Siti Nurhaliza",
          "job_title": "UI/UX Designer",
          "skills": ["Figma", "Adobe XD", "Prototyping"],
          "video_url": "https://assets.mixkit.co/videos/preview/mixkit-girl-in-glasses-holding-a-smartphone-1234-large.mp4",
          "skill_match": 0.85,
          "test_score": 95,
          "video_duration": 20,
          "experience": 3,
        },
        {
          "full_name": "Budi Santoso",
          "job_title": "Backend Engineer",
          "skills": ["Node.js", "NestJS", "MongoDB"],
          "video_url": "https://assets.mixkit.co/videos/preview/mixkit-young-man-typing-on-a-laptop-42174-large.mp4",
          "skill_match": 0.70,
          "test_score": 80,
          "video_duration": 50,
          "experience": 2,
        },
      ];

      List<dynamic> allCandidates = [...remoteCandidates, ...dummyCandidates];

      // 🧠 HITUNG RANKING SCORE
      for (var c in allCandidates) {
        double skillMatch = c['skill_match'] ?? 0.7;
        double testScore = (c['test_score'] ?? 75) / 100.0;
        double videoQuality = (c['video_duration'] ?? 25) > 30 ? 1.0 : 0.5;
        double experience = (c['experience'] ?? 1) / 10.0; // max scale 10 years

        // Formula: (0.4 * Skill Match) + (0.3 * Test Score) + (0.2 * Video Quality) + (0.1 * Experience)
        double score = (0.4 * skillMatch) + (0.3 * testScore) + (0.2 * videoQuality) + (0.1 * experience);
        c['ranking_score'] = (score * 100).toInt();
      }

      // 🏆 SORTING (DESCENDING)
      allCandidates.sort((a, b) => b['ranking_score'].compareTo(a['ranking_score']));

      setState(() {
        _candidates = allCandidates;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Kandidat Potensial"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _candidates.isEmpty
              ? const Center(child: Text("Belum ada kandidat terdaftar."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _candidates.length,
                  itemBuilder: (context, index) {
                    return CandidateCard(
                      candidate: _candidates[index],
                      isTop: index == 0,
                    );
                  },
                ),
    );
  }
}

class CandidateCard extends StatelessWidget {
  final dynamic candidate;
  final bool isTop;
  const CandidateCard({super.key, required this.candidate, this.isTop = false});

  @override
  Widget build(BuildContext context) {
    final name = candidate['full_name'] ?? candidate['name'] ?? "Anonymous";
    final jobTitle = candidate['job_title'] ?? "Candidate";
    final skills = (candidate['skills'] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isTop ? Border.all(color: Colors.orange.shade300, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isTop ? Colors.orange.withOpacity(0.1) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isTop)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                width: double.infinity,
                color: Colors.orange.shade50,
                child: const Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Top Candidate",
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            // TOP SECTION: INFO
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 30,
                    backgroundColor: isTop ? Colors.orange.shade100 : const Color(0xFFE0F2FE),
                    child: Icon(Icons.person, color: isTop ? Colors.orange : const Color(0xFF0EA5E9), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        Text(
                          jobTitle,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${candidate['ranking_score'] ?? 85}%",
                      style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  )
                ],
              ),
            ),
            
            // SKILLS SECTION
            if (skills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 6,
                  children: skills.take(3).map((s) => _skillTag(s)).toList(),
                ),
              ),
              
            const SizedBox(height: 12),

            // ACTION SECTION
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                         _showVideoDialog(context, candidate['video_url']);
                      },
                      icon: const Icon(Icons.play_circle_fill, size: 20, color: Color(0xFF10B981)),
                      label: const Text("Tonton Video", style: TextStyle(color: Color(0xFF10B981))),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final userId = candidate['_id'];
                      if (userId != null) {
                        await ApiService().shortlistCandidate(userId);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${candidate['full_name']} berhasil masuk shortlist! ⭐"),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("SHORTLIST"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillTag(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showVideoDialog(BuildContext context, String? url) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kandidat ini belum mengunggah video.")));
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(url: url),
    );
  }
}

class VideoPlayerDialog extends StatefulWidget {
  final String url;
  const VideoPlayerDialog({super.key, required this.url});

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: _initialized ? _controller.value.aspectRatio : 16 / 9,
            child: _initialized 
                ? ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: VideoPlayer(_controller))
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Text("Video Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                 IconButton(
                   onPressed: () => Navigator.pop(context),
                   icon: const Icon(Icons.close, color: Colors.white),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

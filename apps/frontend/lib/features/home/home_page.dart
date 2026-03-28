import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_service.dart';
import '../assessment/assessment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _allJobs = []; // Master data
  List<dynamic> _jobs = [];    // Displayed data
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      // 👤 Fetch User Profile to get Skills
      dynamic userProfile;
      if (userId != null) {
        final profileRes = await ApiService().getProfile(userId);
        userProfile = profileRes.data;
      }

      final response = await ApiService().getJobs();
      final List<dynamic> fetchedJobs = response.data;

      // 🤖 Calculate Auto-Matching Score
      for (var job in fetchedJobs) {
        double skillMatch = 0.0;
        final requiredSkills = (job['required_skills'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
        final userSkills = (userProfile?['skills'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];

        if (requiredSkills.isNotEmpty) {
          int count = 0;
          for (var s in userSkills) {
            if (requiredSkills.contains(s)) count++;
          }
          skillMatch = count / requiredSkills.length;
        }

        // Formula: (0.5 * Skill Match) + (0.3 * Test Score) + (0.2 * Activity)
        double testScore = (userProfile?['test_score'] ?? 80) / 100.0;
        double activity = 0.9; // Dummy constant for now
        
        double finalScore = (0.5 * skillMatch) + (0.3 * testScore) + (0.2 * activity);
        job['match_score'] = (finalScore * 100).clamp(60, 99).toInt(); // Clamp for nice demo
      }

      setState(() {
        _allJobs = fetchedJobs;
        _jobs = List.from(_allJobs);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter(RangeValues salary, String location) {
    setState(() {
      _jobs = _allJobs.where((job) {
        // Mocking salary & location for the demo
        // (In real app, this would be part of job data from DB)
        final jobSalary = (job['title'].length % 20) + 5; // Simulating salary 5-25jt
        final jobLocation = (job['company'].length % 3 == 0) ? 'Remote' : (job['company'].length % 3 == 1 ? 'Jakarta' : 'Bali');

        final matchesSalary = jobSalary >= salary.start && jobSalary <= salary.end;
        final matchesLocation = location == jobLocation;

        return matchesSalary && matchesLocation;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Cari Kerja"),
        centerTitle: false,
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (_) => const FilterSheet(),
              );

              if (result != null && mounted) {
                final salary = result['salary'] as RangeValues;
                final location = result['location'] as String;
                _applyFilter(salary, location);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menampilkan Lowongan di $location (${_jobs.length} ditemukan)'),
                    backgroundColor: const Color(0xFF4F46E5),
                  ),
                );
              }
            },
          ),
          IconButton(onPressed: _fetchJobs, icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),
      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(blurRadius: 15, offset: const Offset(0, 5), color: Colors.black.withOpacity(0.05))
                ],
              ),
              child: TextField(
                onChanged: (val) {
                  // Tambahan: Filter by Search
                  setState(() {
                    _jobs = _allJobs.where((job) => job['title'].toString().toLowerCase().contains(val.toLowerCase())).toList();
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF4F46E5)),
                  hintText: "Cari pekerjaan atau perusahaan...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 📋 JOB LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _jobs.isEmpty 
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Tidak ada lowongan yang sesuai filter.', style: TextStyle(color: Colors.grey)),
                        TextButton(onPressed: _fetchJobs, child: const Text('Reset Filter'))
                      ],
                    ))
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      return AnimatedJobCard(
                        key: ValueKey(_jobs[index]['_id']), // Key ensures animations trigger correctly
                        delay: 100 * index,
                        job: _jobs[index],
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}

class AnimatedJobCard extends StatefulWidget {
  final int delay;
  final dynamic job;

  const AnimatedJobCard({super.key, required this.delay, required this.job});

  @override
  State<AnimatedJobCard> createState() => _AnimatedJobCardState();
}

class _AnimatedJobCardState extends State<AnimatedJobCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(BuildContext context) async {
    final jobId = widget.job['_id'];
    try {
      // 💼 Apply Job (Real)
      await ApiService().applyJob(jobId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lamaran terkirim 🚀")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim lamaran: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    // Mock simulation for display
    final simulatedLocation = (job['company'].length % 3 == 0) ? 'Remote' : (job['company'].length % 3 == 1 ? 'Jakarta' : 'Bali');
    final simulatedSalary = (job['title'].length % 20) + 5;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          child: AnimatedScale(
            scale: isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Hero(
              tag: 'job_${job['_id']}',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.04), offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.business, color: Color(0xFF4F46E5)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(job['title'],
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B))),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "🔥 ${job['match_score'] ?? 85}%",
                                        style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(job['company'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Text("$simulatedSalary jt / bln", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(simulatedLocation, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: (job['required_skills'] as List)
                            .take(3)
                            .map((s) => _skillChip(s.toString()))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Baru Saja", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ElevatedButton(
                            onPressed: () => _apply(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                            ),
                            child: const Text("APPLY", style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _skillChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  RangeValues salaryRange = const RangeValues(5, 15);
  String selectedLocation = "Remote";
  final locations = ["Remote", "Jakarta", "Bali", "Surabaya"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const Text("Filter Pekerjaan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
               IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Estimasi Range Gaji", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          RangeSlider(
            values: salaryRange,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: const Color(0xFF4F46E5),
            labels: RangeLabels("${salaryRange.start.round()} jt", "${salaryRange.end.round()} jt"),
            onChanged: (value) => setState(() => salaryRange = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${salaryRange.start.round()}jt", style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
              Text("${salaryRange.end.round()}jt", style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 32),
          const Text("Lokasi Favorit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: locations.map((loc) {
              final isSelected = selectedLocation == loc;
              return ChoiceChip(
                label: Text(loc),
                selected: isSelected,
                onSelected: (_) => setState(() => selectedLocation = loc),
                selectedColor: const Color(0xFF4F46E5),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                backgroundColor: Colors.grey.shade100,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "salary": salaryRange,
                  "location": selectedLocation,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("Terapkan Filter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../../core/api_service.dart';
import '../../core/upload_service.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _controller;
  bool _isUploading = false;
  File? _videoFile;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final response = await ApiService().getProfile(userId!);
      setState(() {
        _userData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _recordVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 60),
    );

    if (video != null) {
      _videoFile = File(video.path);
      _controller = VideoPlayerController.file(_videoFile!)
        ..initialize().then((_) {
          setState(() {});
          _controller?.play();
          _controller?.setLooping(true);
        });

      setState(() => _isUploading = true);
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        
        // 🎥 1. UPLOAD (Mock/Cloudinary Sim)
        final url = await UploadService.uploadVideo(_videoFile!);
        
        if (url != null) {
          // 🧠 2. SAVE ke backend
          await ApiService().saveProfileVideo(userId!, url);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video Resume Berhasil Diunggah!')));
            _fetchProfile(); // Refresh for strength calculation
          }
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengunggah video!')));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  double _calculateProfileStrength() {
    if (_userData == null) return 0.2;
    double strength = 0.2; // Start with 20% for registered
    if (_userData!['name'] != null && _userData!['name'].isNotEmpty) strength += 0.2;
    if (_userData!['job_title'] != null && _userData!['job_title'].isNotEmpty) strength += 0.2;
    if (_userData!['skills'] != null && (_userData!['skills'] as List).isNotEmpty) strength += 0.2;
    if (_userData!['video_url'] != null && _userData!['video_url'].isNotEmpty) strength += 0.2;
    return strength > 1.0 ? 1.0 : strength;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final name = _userData?['name'] ?? 'User';
    final title = _userData?['job_title'] ?? 'Lengkapi Pekerjaan Anda';
    final location = _userData?['location'] ?? 'Lengkapi Lokasi';
    final skills = (_userData?['skills'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final bio = _userData?['bio'] ?? 'Lengkapi Deskripsi Diri Anda.';
    final strength = _calculateProfileStrength();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔥 HEADER (Integrated Premium Gradient)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
                boxShadow: [
                   BoxShadow(color: Color(0x664F46E5), blurRadius: 20, offset: Offset(0, 10))
                ]
              ),
              child: Column(
                children: [
                   CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 47,
                      backgroundColor: Colors.indigo.shade50,
                      child: const Icon(Icons.person, size: 45, color: Color(0xFF4F46E5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$title 🚀",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "📍 $location • ⭐ Score 82",
                    style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🎥 VIDEO RESUME CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "🎥 Video Resume",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (_isUploading)
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1497215728101-856f4ea42174?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=60'),
                          fit: BoxFit.cover,
                          opacity: 0.3
                        )
                      ),
                      child: Center(
                         child: _controller != null && _controller!.value.isInitialized
                            ? ClipRRect(borderRadius: BorderRadius.circular(16), child: VideoPlayer(_controller!))
                            : const Icon(Icons.play_circle_fill, color: Colors.white70, size: 64),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _recordVideo,
                        icon: const Icon(Icons.videocam, color: Colors.white),
                        label: const Text("UPDATE VIDEO", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🧠 SKILLS
            _sectionTitle("Keahlian Utama"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: skills.isEmpty 
                    ? [const Text('Belum ada skill ditambahkan', style: TextStyle(color: Colors.grey))]
                    : skills.map((s) => _skillChip(s)).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // 🧾 ABOUT
            _sectionTitle("Tentang Saya"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  bio,
                  style: const TextStyle(color: Color(0xFF4B5563), height: 1.5, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ⭐ PROFILE STRENGTH
            _sectionTitle("Profile Strength"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: strength,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade100,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${(strength * 100).toInt()}% Complete", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                        const Text("Lengkapi profil agar dilirik HR!", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 🔥 BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage(initialData: _userData!)),
                    );
                    if (result == true) _fetchProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
                  ),
                  child: const Text("EDIT PROFIL LENGKAP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ),
    );
  }

  Widget _skillChip(String text) {
    return Chip(
      label: Text(text, style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFFE0E7FF),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

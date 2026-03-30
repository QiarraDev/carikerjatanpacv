import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'register_page.dart';
import '../main_navigation.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Staggered slide animations for each element
    _slideAnimations = List.generate(6, (index) {
      final start = 0.1 + (index * 0.1);
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOutBack),
      ));
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final role = prefs.getString('user_role');
    
    if (token != null && role != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainNavigation(initialRole: role)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // 💎 PREMIUM LOGO / ICON
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimations[0],
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                      ),
                      child: const Hero(
                        tag: 'app_logo',
                        child: Icon(Icons.work_history_rounded, size: 80, color: Color(0xFF818CF8)),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimations[1],
                    child: Column(
                      children: [
                        const Text(
                          "CariKerja",
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const Text(
                          "Tanpa CV — cukup skill & video",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 1),

                // 🛡️ TRUST SIGNALS (Social Proof)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimations[2],
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTrustItem(Icons.people_alt_rounded, "10.000+", "Pengguna"),
                          const SizedBox(width: 12),
                          Container(width: 1, height: 20, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(width: 12),
                          _buildTrustItem(Icons.business_rounded, "500+", "Perusahaan"),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // 🎯 SELEKSI PERAN (CANDIDATE)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimations[3],
                    child: _buildActionCard(
                      title: "🔥 Cari Kerja",
                      subtitle: "Dapatkan pekerjaan tanpa CV, cukup tunjukkan skill lewat video",
                      icon: Icons.person_search_rounded,
                      color: const Color(0xFF818CF8),
                      isPrimary: true,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage(role: 'candidate'))),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🎯 SELEKSI PERAN (RECRUITER)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimations[4],
                    child: _buildActionCard(
                      title: "🏢 Rekrut",
                      subtitle: "Temukan talenta terbaik dengan video profile singkat",
                      icon: Icons.business_center_rounded,
                      color: const Color(0xFF94A3B8),
                      isPrimary: false,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage(role: 'recruiter'))),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // 🔗 LOGIN LINK
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimations[5],
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                      child: RichText(
                        text: const TextSpan(
                          text: "Sudah punya akun? ",
                          style: TextStyle(color: Color(0xFF94A3B8)),
                          children: [
                            TextSpan(
                              text: "Masuk",
                              style: TextStyle(
                                color: Color(0xFF818CF8),
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0x80818CF8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6366F1).withOpacity(0.8)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (isPrimary)
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 25,
              spreadRadius: -5,
              offset: const Offset(0, 12),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 🌫️ GLASS EFFECT (BACKDROP FILTER)
            if (!isPrimary)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    Colors.white.withOpacity(0.03),
                    BlendMode.srcOver,
                  ),
                  child: Container(color: Colors.transparent),
                ),
              ),
            
            Material(
              color: isPrimary ? Colors.transparent : Colors.white.withOpacity(0.05),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isPrimary
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: Border.all(
                    color: isPrimary ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.12),
                    width: isPrimary ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                    child: Row(
                      children: [
                        // 🎨 ICON CONTAINER
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isPrimary ? Colors.white.withOpacity(0.2) : color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              if (isPrimary)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                            ],
                          ),
                          child: Icon(
                            icon,
                            color: isPrimary ? Colors.white : color,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        
                        // 📝 TEXT CONTENT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: isPrimary ? 0.5 : 0,
                                  shadows: [
                                    if (isPrimary)
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 4,
                                      )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: isPrimary ? Colors.white.withOpacity(0.9) : const Color(0xFF94A3B8),
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: isPrimary ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // ➡️ ARROW
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: isPrimary ? Colors.white70 : Colors.white24,
                          size: 18,
                        ),
                      ],
                    ),
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

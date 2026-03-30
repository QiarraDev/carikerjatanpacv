import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'role_selection_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController controller = PageController();
  late AnimationController _bgController;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌈 ANIMATED GRADIENT BACKGROUND
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(
                        const Color(0xFF0F172A),
                        const Color(0xFF1E293B),
                        _bgController.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF1E293B),
                        const Color(0xFF4F46E5),
                        _bgController.value,
                      )!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),

          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: const [
              OnboardPage(
                title: "Cari Kerja Lebih Mudah",
                subtitle: "Tanpa CV, cukup tunjukkan skill kamu lewat video",
                lottieUrl: "https://assets9.lottiefiles.com/packages/lf20_ktwnwv5m.json",
                fallbackIcon: Icons.video_call_rounded,
              ),
              OnboardPage(
                title: "Langsung Dilihat HR",
                subtitle: "HR bisa lihat video kamu tanpa ribet screening",
                lottieUrl: "https://assets3.lottiefiles.com/packages/lf20_w51pcehl.json",
                fallbackIcon: Icons.people_alt_rounded,
              ),
              OnboardPage(
                title: "Dapatkan Job Lebih Cepat",
                subtitle: "Matching otomatis berdasarkan skill kamu",
                lottieUrl: "https://assets2.lottiefiles.com/packages/lf20_8ne8m7p8.json",
                fallbackIcon: Icons.flash_on_rounded,
              ),
            ],
          ),

          // 🔥 BOTTOM CONTROL
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                  effect: WormEffect(
                    dotColor: Colors.white.withOpacity(0.2),
                    activeDotColor: Colors.white,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),

                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLastPage
                      ? ElevatedButton(
                          key: const ValueKey('start_btn'),
                          onPressed: () async {
                            // ✅ SAVE ONBOARDING STATUS
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('seen_onboarding', true);

                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RoleSelectionScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: const Text("Mulai Sekarang", 
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        )
                      : TextButton(
                          key: const ValueKey('next_btn'),
                          onPressed: () {
                            if (controller.hasClients) {
                              controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          child: const Text("Selanjutnya",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                        ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String lottieUrl;
  final IconData fallbackIcon;

  const OnboardPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lottieUrl,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 1000),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 60 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              height: 250,
              alignment: Alignment.center,
              child: Lottie.network(
                lottieUrl,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                    ),
                    child: Icon(fallbackIcon, size: 100, color: const Color(0xFF818CF8)),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 40),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

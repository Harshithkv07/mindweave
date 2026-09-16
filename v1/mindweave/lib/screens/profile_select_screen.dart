import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'caretaker_dashboard.dart';

/// Entry screen for MindWeave: a Netflix-style profile picker.
///
/// Instead of a form with credentials, the app opens straight to exactly two
/// large, unmistakable profile tiles — "Patient View" and "Caretaker" — and
/// tapping one immediately unfolds that person's experience. This keeps the
/// very first decision a patient with cognitive impairment ever has to make
/// as simple as choosing a picture, not typing a password.
class ProfileSelectScreen extends StatelessWidget {
  const ProfileSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.screenWash),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: AppGradients.hero,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
                        boxShadow: softCardShadow(opacity: 0.25),
                      ),
                      child: const Icon(
                        Icons.psychology_alt_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'MindWeave',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Who is using MindWeave?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Exactly two profile tiles — patient and caretaker.
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 420;
                        final tiles = [
                          _ProfileTile(
                            label: 'Patient View',
                            subtitle: 'Games, reminders & voice help',
                            icon: Icons.face_rounded,
                            gradient: AppGradients.hero,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(
                                    name: 'Margaret',
                                    language: 'English',
                                  ),
                                ),
                              );
                            },
                          ),
                          _ProfileTile(
                            label: 'Caretaker',
                            subtitle: 'Analytics & care oversight',
                            icon: Icons.shield_rounded,
                            gradient: AppGradients.heroDeep,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CaretakerDashboardScreen(
                                    patientName: 'Margaret',
                                  ),
                                ),
                              );
                            },
                          ),
                        ];

                        if (isNarrow) {
                          return Column(
                            children: [
                              tiles[0],
                              const SizedBox(height: 20),
                              tiles[1],
                            ],
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: tiles[0]),
                            const SizedBox(width: 24),
                            Expanded(child: tiles[1]),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusExtraLarge),
            boxShadow: softCardShadow(opacity: 0.1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: softCardShadow(opacity: 0.2),
                ),
                child: Icon(icon, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

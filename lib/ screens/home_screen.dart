import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'password_checker_screen.dart';
import 'url_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'Security Toolkit',
        subtitle: 'Your pocket cyber-safety kit',
        icon: Icons.shield_outlined,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'What would you like\nto check today?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pick a tool below. Results come from trusted security databases.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _ToolCard(
            icon: Icons.password_rounded,
            colors: const [AppColors.primary, Color(0xFF3B82F6)],
            title: 'Password Checker',
            description:
            'Find out if a password has appeared in known data breaches.',
            screen: const PasswordCheckerScreen(),
          ),
          const SizedBox(height: 14),
          _ToolCard(
            icon: Icons.link_rounded,
            colors: const [AppColors.secondary, Color(0xFFEC4899)],
            title: 'URL Scanner',
            description:
            'Scan a link with dozens of security engines before you open it.',
            screen: const UrlScannerScreen(),
          ),
          const SizedBox(height: 28),
          const InfoNote(
            icon: Icons.lock_outline,
            text:
            'Your password is never sent anywhere. Only the first 5 characters of its hash leave your phone.',
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.colors,
    required this.title,
    required this.description,
    required this.screen,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String description;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
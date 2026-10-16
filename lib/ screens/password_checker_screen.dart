import 'dart:async';
import 'package:flutter/material.dart';
import '../models/password_check_result.dart';
import '../services/password_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class PasswordCheckerScreen extends StatefulWidget {
  const PasswordCheckerScreen({super.key});

  @override
  State<PasswordCheckerScreen> createState() => _PasswordCheckerScreenState();
}

class _PasswordCheckerScreenState extends State<PasswordCheckerScreen> {
  final TextEditingController _controller = TextEditingController();
  final PasswordService _service = PasswordService();

  bool _obscure = true;
  bool _isLoading = false;
  PasswordCheckResult? _result;
  String? _error;

  Future<void> _check() async {
    final password = _controller.text;
    if (password.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await _service.checkPassword(password);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  String _friendlyError(Object e) {
    if (e is TimeoutException) {
      return 'The server took too long to respond. Make sure the backend is running and try again.';
    }
    final text = e.toString();
    if (text.contains('SocketException') || text.contains('ClientException')) {
      return 'Could not reach the server. Make sure the backend is running.';
    }
    return text.replaceFirst('Exception: ', '');
  }

  String _formatCount(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'Password Checker',
        subtitle: 'Has it appeared in a data breach?',
        icon: Icons.password_rounded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter a password to check',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'We compare it against a database of real leaked passwords.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _check(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Type a password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _check,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Check password'),
            ),
            const SizedBox(height: 24),
            _buildResult(),
            const SizedBox(height: 24),
            const InfoNote(
              icon: Icons.lock_outline,
              text:
              'Your password never leaves your phone. Only the first 5 characters of its hash are sent to the server.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const LoadingPanel(message: 'Checking breach database...');
    }

    if (_error != null) {
      return StatusBanner(
        color: AppColors.danger,
        icon: Icons.error_outline_rounded,
        title: 'Something went wrong',
        message: _error!,
      );
    }

    final r = _result;
    if (r == null) return const SizedBox.shrink();

    if (r.isBreached) {
      return StatusBanner(
        color: AppColors.danger,
        icon: Icons.gpp_bad_outlined,
        title: 'Password compromised',
        message:
        'This password has appeared ${_formatCount(r.count)} times in known data breaches. Do not use it anywhere.',
      );
    }

    return const StatusBanner(
      color: AppColors.success,
      icon: Icons.verified_user_outlined,
      title: 'No known leaks',
      message:
      'This password was not found in known data breaches. Still, use a long, unique password for every account.',
    );
  }
}
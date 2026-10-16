import 'dart:async';
import 'package:flutter/material.dart';
import '../models/url_scan_result.dart';
import '../services/url_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class UrlScannerScreen extends StatefulWidget {
  const UrlScannerScreen({super.key});

  @override
  State<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends State<UrlScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  final UrlService _service = UrlService();

  bool _isLoading = false;
  UrlScanResult? _result;
  String? _error;

  Future<void> _scan() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await _service.checkUrl(url);
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'URL Scanner',
        subtitle: 'Check a link before you open it',
        icon: Icons.link_rounded,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste a link to scan',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'The link is checked by dozens of security engines. It is never opened.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _scan(),
              decoration: const InputDecoration(
                labelText: 'Website URL',
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _scan,
              icon: const Icon(Icons.radar_rounded),
              label: const Text('Scan URL'),
            ),
            const SizedBox(height: 24),
            _buildResult(),
            const SizedBox(height: 24),
            const InfoNote(
              icon: Icons.info_outline_rounded,
              text:
              'Only scan public links. Scanned URLs may be visible to other users of the scanning service.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_isLoading) {
      return const LoadingPanel(
        message: 'Scanning the URL...\nThis can take up to a minute.',
      );
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

    final Color color;
    final IconData icon;
    final String title;
    final String message;

    if (!r.isCompleted) {
      color = AppColors.secondary;
      icon = Icons.hourglass_top_rounded;
      title = 'Scan still running';
      message = 'The scan has not finished yet. Please scan again in a moment.';
    } else if (r.isDangerous) {
      color = AppColors.danger;
      icon = Icons.gpp_bad_outlined;
      title = 'Dangerous link';
      message =
      '${r.malicious} security engines flagged this URL as malicious. Do not open it.';
    } else if (r.isSuspicious) {
      color = AppColors.warning;
      icon = Icons.warning_amber_rounded;
      title = 'Suspicious link';
      message =
      '${r.suspicious} security engines flagged this URL as suspicious. Be careful.';
    } else {
      color = AppColors.success;
      icon = Icons.verified_user_outlined;
      title = 'No threats found';
      message =
      'None of the security engines flagged this URL. Stay careful with links you do not trust.';
    }

    return StatusBanner(
      color: color,
      icon: icon,
      title: title,
      message: message,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Malicious',
                  value: r.malicious,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Suspicious',
                  value: r.suspicious,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Harmless',
                  value: r.harmless,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'Undetected',
                  value: r.undetected,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Checked by ${r.totalEngines} security engines',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
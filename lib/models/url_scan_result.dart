class UrlScanResult {
  final String status; // queued, in-progress, completed
  final int malicious;
  final int suspicious;
  final int harmless;
  final int undetected;

  UrlScanResult({
    required this.status,
    required this.malicious,
    required this.suspicious,
    required this.harmless,
    required this.undetected,
  });

  factory UrlScanResult.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    return UrlScanResult(
      status: json['status'],
      malicious: stats['malicious'],
      suspicious: stats['suspicious'],
      harmless: stats['harmless'],
      undetected: stats['undetected'],
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isDangerous => malicious > 0;
  bool get isSuspicious => suspicious > 0;
  int get totalEngines => malicious + suspicious + harmless + undetected;
}
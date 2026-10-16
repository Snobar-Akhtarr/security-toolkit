class PasswordCheckResult {
  final bool isBreached;  // leak mein aaya ya nahi
  final int count;        // kitni baar aaya

  PasswordCheckResult({
    required this.isBreached,
    required this.count,
  });

  factory PasswordCheckResult.fromJson(Map<String, dynamic> json) {
    return PasswordCheckResult(
      isBreached: json['isBreached'],
      count: json['count'],
    );
  }
}
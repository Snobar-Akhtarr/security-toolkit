import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/url_scan_result.dart';
import 'api_config.dart';

class UrlService {

  Future<String> _startScan(String url) async {
    final response = await http
        .post(
      Uri.parse('${ApiConfig.baseUrl}/url-scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
    return jsonDecode(response.body)['analysisId'];
  }


  Future<UrlScanResult> _getReport(String id) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/url-report/$id'))
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
    return UrlScanResult.fromJson(jsonDecode(response.body));
  }


  void _checkResponse(http.Response response) {
    if (response.statusCode == 200) return;

    String message = 'Server error: ${response.statusCode}';
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['error'] != null) {
        message = data['error'].toString();
      }
    } catch (_) {}
    throw Exception(message);
  }


  Future<UrlScanResult> checkUrl(String url) async {
    final id = await _startScan(url);

    UrlScanResult? last;
    for (var i = 0; i < 5; i++) {

      await Future.delayed(const Duration(seconds: 15));
      last = await _getReport(id);
      if (last.isCompleted) return last;
    }
    return last!;
  }
}
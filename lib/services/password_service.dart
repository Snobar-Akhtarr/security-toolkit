import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../models/password_check_result.dart';
import 'api_config.dart';

class PasswordService {
  Future<PasswordCheckResult> checkPassword(String password) async {

    final hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final prefix = hash.substring(0, 5);
    final suffix = hash.substring(5);


    final url = Uri.parse('${ApiConfig.baseUrl}/password-range/$prefix');
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }


    final List<dynamic> list = jsonDecode(response.body);
    for (final item in list) {
      if (item['suffix'] == suffix) {
        return PasswordCheckResult(isBreached: true, count: item['count']);
      }
    }
    return PasswordCheckResult(isBreached: false, count: 0);
  }
}
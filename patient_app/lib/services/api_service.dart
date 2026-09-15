import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';

class ApiService {
  String? token;
  int? userId;

  Future<void> login(String email, String password) async {
    final r = await http.post(
      Uri.parse('${AppConfig.baseUrl}/auth/login'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'email':email,'password':password}),
    );
    if (r.statusCode >= 400) throw Exception('Login failed');
    final d=jsonDecode(r.body);
    token=d['access_token'];
    userId=d['user']['id'];
  }

  Map<String,String> get headers => {
    'Content-Type':'application/json',
    if(token != null) 'Authorization':'Bearer $token',
  };

  Future<void> submitSession({
    required String gameType,
    required int difficulty,
    required double accuracy,
    required double responseTime,
    required int mistakes,
  }) async {
    if(token == null || userId == null) throw Exception('Not logged in');
    final r=await http.post(
      Uri.parse('${AppConfig.baseUrl}/sessions'),
      headers: headers,
      body: jsonEncode({
        'patient_id':userId,
        'game_type':gameType,
        'difficulty':difficulty,
        'accuracy':accuracy,
        'response_time':responseTime,
        'mistakes':mistakes,
        'completed':true
      }),
    );
    if(r.statusCode>=400) throw Exception('Could not save session');
  }

  Future<Map<String,dynamic>> recommendation() async {
    final r=await http.get(Uri.parse('${AppConfig.baseUrl}/patients/$userId/recommendation'),headers:headers);
    if(r.statusCode>=400) throw Exception('Could not load recommendation');
    return jsonDecode(r.body);
  }
}

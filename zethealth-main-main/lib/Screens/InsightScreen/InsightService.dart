import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zet_health/Models/CategorizeValueModel.dart';


class InsightService {
  // static const String baseUrl = "http://10.0.2.2:5000";
  static const String baseUrl = "http://staging.zethealth.com";

  static Future<CategorizeValueResponse?> fetchInsights(String userId) async {
    try {
      final url = Uri.parse("$baseUrl/unified/$userId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return CategorizeValueResponse.fromJson(data);
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception while fetching insights: $e");
      return null;
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.72:5000';

  static Future<Map<String, dynamic>> getSensors() async {
    final response = await http.get(Uri.parse('$baseUrl/sensors'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Sauvegarder dans Firestore
      await FirebaseFirestore.instance.collection('sensors_data').add({
        'temperature': data['temperature (C)'],
        'luminosite': data['luminosite (Lux)'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      return data;
    }
    throw Exception('Échec de la récupération des données des capteurs');
  }

  static Future<bool> setLedState(String led, int state) async {
    final response = await http.get(
      Uri.parse('$baseUrl/led-$led?state=$state'),
    );
    return response.statusCode == 200;
  }

  static Future<bool> setThreshold({double? light, double? temp}) async {
    String queryParams = '';
    if (light != null) queryParams += 'light=$light';
    if (temp != null) {
      if (queryParams.isNotEmpty) queryParams += '&';
      queryParams += 'temp=$temp';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/set-seuil?$queryParams'),
    );
    return response.statusCode == 200;
  }
}
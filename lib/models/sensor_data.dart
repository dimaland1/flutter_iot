import 'package:cloud_firestore/cloud_firestore.dart';

class SensorData {
  final double temperature;
  final double luminosity;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.luminosity,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: json['temperature (C)'].toDouble(),
      luminosity: json['luminosite (Lux)'].toDouble(),
      timestamp: DateTime.now(),
    );
  }

  factory SensorData.fromFirestore(Map<String, dynamic> doc) {
    return SensorData(
      temperature: doc['temperature'].toDouble(),
      luminosity: doc['luminosite'].toDouble(),
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'luminosite': luminosity,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
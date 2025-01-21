import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({Key? key}) : super(key: key);

  @override
  _SensorsScreenState createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  Map<String, dynamic>? _sensorData;
  Timer? _timer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Actualiser toutes les 30 secondes
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final data = await ApiService.getSensors();
      setState(() {
        _sensorData = data;
        _isLoading = false;
        _error = null;
      });
      print('Données reçues: $_sensorData'); // Debug print
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Erreur lors de la récupération des données: $e'); // Debug print
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Données des Capteurs'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_sensorData == null) {
      return const Center(
        child: Text('Aucune donnée disponible'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSensorCard(
          'Température',
          _sensorData!['temperature (C)']?.toString() ?? 'N/A',
          '°C',
          Icons.thermostat,
          Colors.red,
        ),
        const SizedBox(height: 16),
        _buildSensorCard(
          'Luminosité',
          _sensorData!['luminosite (Lux)']?.toString() ?? 'N/A',
          'Lux',
          Icons.light_mode,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSensorCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
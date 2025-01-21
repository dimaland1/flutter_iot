import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ThresholdScreen extends StatefulWidget {
  const ThresholdScreen({Key? key}) : super(key: key);

  @override
  _ThresholdScreenState createState() => _ThresholdScreenState();
}

class _ThresholdScreenState extends State<ThresholdScreen> {
  final _lightController = TextEditingController();
  final _tempController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration des Seuils'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _lightController,
                      decoration: const InputDecoration(
                        labelText: 'Seuil de luminosité (%)',
                        helperText: 'Entre 0 et 100%',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tempController,
                      decoration: const InputDecoration(
                        labelText: 'Seuil de température (°C)',
                        helperText: 'Entre -40 et 125°C',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updateThresholds,
                      child: const Text('Mettre à jour les seuils'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateThresholds() async {
    try {
      double? light = _lightController.text.isNotEmpty
          ? double.parse(_lightController.text)
          : null;
      double? temp = _tempController.text.isNotEmpty
          ? double.parse(_tempController.text)
          : null;

      if (light != null && (light < 0 || light > 100)) {
        throw Exception('Le seuil de luminosité doit être entre 0 et 100%');
      }
      if (temp != null && (temp < -40 || temp > 125)) {
        throw Exception('Le seuil de température doit être entre -40 et 125°C');
      }

      final success = await ApiService.setThreshold(light: light, temp: temp);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seuils mis à jour avec succès')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
}
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LedControlScreen extends StatefulWidget {
  const LedControlScreen({Key? key}) : super(key: key);

  @override
  _LedControlScreenState createState() => _LedControlScreenState();
}

class _LedControlScreenState extends State<LedControlScreen> with TickerProviderStateMixin {
  int _redLedState = 0;
  int _greenLedState = 0;
  late AnimationController _redPulseController;
  late AnimationController _greenPulseController;
  bool _isRedLoading = false;
  bool _isGreenLoading = false;

  @override
  void initState() {
    super.initState();
    _redPulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _greenPulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _redPulseController.dispose();
    _greenPulseController.dispose();
    super.dispose();
  }

  Future<void> _updateLedState(String led, int state) async {
    if (led == 'red') {
      setState(() => _isRedLoading = true);
    } else {
      setState(() => _isGreenLoading = true);
    }

    try {
      final success = await ApiService.setLedState(led, state);
      if (success) {
        setState(() {
          if (led == 'red') {
            _redLedState = state;
          } else {
            _greenLedState = state;
          }
        });
      } else {
        _showError('Échec de la mise à jour de la LED');
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      setState(() {
        if (led == 'red') {
          _isRedLoading = false;
        } else {
          _isGreenLoading = false;
        }
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrôle des LEDs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLedControl(
              'LED Rouge',
              _redLedState,
              Colors.red,
              _isRedLoading,
              _redPulseController,
                  (value) => _updateLedState('red', value),
            ),
            const SizedBox(height: 32),
            _buildLedControl(
              'LED Verte',
              _greenLedState,
              Colors.green,
              _isGreenLoading,
              _greenPulseController,
                  (value) => _updateLedState('green', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedControl(
      String title,
      int currentState,
      Color color,
      bool isLoading,
      AnimationController pulseController,
      Function(int) onChanged,
      ) {
    return Card(
      elevation: 4,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: currentState == 1 ? color : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentState == 1
                            ? color.withOpacity(0.2 + 0.3 * pulseController.value)
                            : Colors.grey.withOpacity(0.1),
                      ),
                    );
                  },
                ),
                Icon(
                  Icons.lightbulb,
                  size: 60,
                  color: currentState == 1
                      ? color
                      : currentState == -1
                      ? color.withOpacity(0.5)
                      : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStateButton('Éteinte', 0, currentState, color, onChanged),
                _buildStateButton('Allumée', 1, currentState, color, onChanged),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateButton(
      String label,
      int state,
      int currentState,
      Color color,
      Function(int) onChanged,
      ) {
    final isSelected = currentState == state;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : null, backgroundColor: isSelected ? color : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: isSelected ? 8 : 2,
        ),
        onPressed: () => onChanged(state),
        child: Text(label),
      ),
    );
  }
}
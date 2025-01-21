import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sensors_data')
            .orderBy('timestamp', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: _buildChart(data),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        'Temp: ${item['temperature']}°C, Lum: ${item['luminosite']} Lux',
                      ),
                      subtitle: Text(
                        'Date: ${(item['timestamp'] as Timestamp)
                            .toDate()
                            .toString()}',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChart(List<QueryDocumentSnapshot> data) {
    final temperatureData = data.map((doc) {
      final item = doc.data() as Map<String, dynamic>;
      return {
        'time': (item['timestamp'] as Timestamp).toDate(),
        'value': item['temperature'],
      };
    }).toList();

    final luminosityData = data.map((doc) {
      final item = doc.data() as Map<String, dynamic>;
      return {
        'time': (item['timestamp'] as Timestamp).toDate(),
        'value': item['luminosite'],
      };
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Température'),
              Tab(text: 'Luminosité'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLineChart(temperatureData, 'Température (°C)'),
                _buildLineChart(luminosityData, 'Luminosité (Lux)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> data, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            // Configuration du titre de gauche (axe Y)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            // Configuration du titre du bas (axe X)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= data.length || value < 0) {
                    return const Text('');
                  }
                  final date = data[value.toInt()]['time'] as DateTime;
                  return Text(
                    '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            // Titre du haut
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // Titre de droite
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value['value'].toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: data.isEmpty ? 0 : data.map((e) => e['value'] as num).reduce((a,
              b) => a < b ? a : b).toDouble() - 1,
          maxY: data.isEmpty ? 10 : data.map((e) => e['value'] as num).reduce((
              a, b) => a > b ? a : b).toDouble() + 1,
        ),
      ),
    );
  }
}
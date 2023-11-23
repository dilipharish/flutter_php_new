import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_php_new/constants.dart';

class LineChartSamplealloc extends StatefulWidget {
  @override
  State<LineChartSamplealloc> createState() => _LineChartSampleallocState();
}

class _LineChartSampleallocState extends State<LineChartSamplealloc> {
  late List<FlSpot> spots;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchDataFromDatabase();
  }

  Future<void> _fetchDataFromDatabase() async {
    final List<FlSpot> data = [];

    final connection = await MySqlConnection.connect(settings);

    try {
      final currentDate = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = currentDate.subtract(Duration(days: i));
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        final results = await connection.query(
            'SELECT COUNT(*) as count FROM Receiver WHERE DATE(date_of_allocation) = ?',
            [formattedDate]);

        var donorCount = results.first.fields['count'] as int;
        // donorCount *= 4;
        data.add(FlSpot((6 - i).toDouble(), donorCount.toDouble()));
      }

      setState(() {
        spots = data;
        _isLoading = false;
      });
    } finally {
      await connection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Color.fromARGB(255, 192, 67, 223),
                  barWidth: 1,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(show: false),
                  aboveBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                ),
              ],
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: true),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Color.fromARGB(255, 41, 75, 249),
                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                    return lineBarsSpot.map((lineBarSpot) {
                      return LineTooltipItem(
                        'Previous Day ${6 - lineBarSpot.x.toInt()}: ${lineBarSpot.y.toInt()} donors',
                        TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          );
  }
}

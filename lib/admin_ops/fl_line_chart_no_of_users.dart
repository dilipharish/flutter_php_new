import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:flutter_php_new/constants.dart';

class LineChartSample6 extends StatefulWidget {
  @override
  State<LineChartSample6> createState() => _LineChartSample5State();
}

class _LineChartSample5State extends State<LineChartSample6> {
  late List<FlSpot> spots;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchDataUsersFromDatabase();
  }

  Future<void> _fetchDataUsersFromDatabase() async {
    final List<FlSpot> data = [];

    final connection = await MySqlConnection.connect(settings);

    try {
      final currentDate = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final startOfWeek = currentDate.subtract(Duration(days: i * 7));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        final formattedStartDate = DateFormat('yyyy-MM-dd').format(startOfWeek);
        final formattedEndDate = DateFormat('yyyy-MM-dd').format(endOfWeek);

        final results = await connection.query(
          'SELECT CAST(SUM(users_count) AS UNSIGNED) as count FROM (SELECT COUNT(*) as users_count FROM users WHERE date_of_user_registration BETWEEN ? AND ? GROUP BY DATE(date_of_user_registration)) as subquery',
          [formattedStartDate, formattedEndDate],
        );

        var userCount = results.first.fields['count'] as int?;
        userCount ??= 0; // If userCount is null, assign 0

        data.add(FlSpot(
            (6 - i).toDouble(), userCount!.toDouble())); // Convert to double

        setState(() {
          spots = data;
          _isLoading = false;
        });
      }
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
                  color: Color.fromARGB(255, 225, 155, 24),
                  barWidth: 0.9,
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
                  tooltipBgColor: Colors.blueAccent,
                  getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                    return lineBarsSpot.map((lineBarSpot) {
                      return LineTooltipItem(
                        'Previous Week ${6 - lineBarSpot.x.toInt()}: ${lineBarSpot.y.toInt()} registered Users',
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

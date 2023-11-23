import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_php_new/admin_ops/dart_model.dart';
import 'package:flutter_php_new/constants.dart';
import 'package:mysql1/mysql1.dart';

class BarChartWidget extends StatefulWidget {
  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  List<DataModel> _list = List<DataModel>.empty(growable: true);
  late MySqlConnection connection;

  Future<void> fetchDataFromDatabase() async {
    connection = await MySqlConnection.connect(settings);

    Results result = await connection.query(
        'SELECT organ_name, COUNT(*) as count FROM Organ WHERE organ_availability = 1 GROUP BY organ_name');
    for (var row in result) {
      print("Organ Name: ${row['organ_name']}, Count: ${row['count']}");
      _list.add(DataModel(
          key: row['organ_name'].toString(), value: row['count'].toString()));
    }

    await connection.close();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromDatabase(); // Fetch data when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: Container(
                color: Colors.white,
                height: 100,
                width: 200,
              ),
              flex: 2),
          Expanded(
              child: Container(
                color: Colors.white,
                height: 100,
                width: 200,
                child: BarChart(
                  BarChartData(
                    backgroundColor: Colors.white,
                    barGroups: _chartGroups(),
                    borderData: FlBorderData(
                        border: const Border(
                            bottom: BorderSide(), left: BorderSide())),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(sideTitles: _bottomTitles),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        interval: 3,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      )),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
              flex: 2),
        ],
      ),
    );
  }

  List<BarChartGroupData> _chartGroups() {
    List<BarChartGroupData> list = [];

    for (int i = 0; i < _list.length; i++) {
      double count = double.parse(_list[i].value!);
      list.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: count,
          color: const Color.fromARGB(255, 78, 255, 34),
          width: 16,
        )
      ]));
    }

    return list;
  }

  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = '';
          switch (value.toInt()) {
            case 0:
              text = 'LKidney';
              break;
            case 1:
              text = 'RKidney';
              break;
            case 2:
              text = 'Eyes';
              break;
            case 3:
              text = 'Heart';
              break;
            case 4:
              text = 'Liver';
              break;
            case 5:
              text = 'Blood';
              break;
          }

          return Text(
            text,
            style: TextStyle(fontSize: 10),
          );
        },
      );
}

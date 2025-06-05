import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(PulseSimulatorApp());
}

class PulseSimulatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador de Pulso',
      theme: ThemeData.dark(),
      home: PulseSimulatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PulseSimulatorScreen extends StatefulWidget {
  @override
  _PulseSimulatorScreenState createState() => _PulseSimulatorScreenState();
}

class _PulseSimulatorScreenState extends State<PulseSimulatorScreen> {
  int pulse = 70;
  bool isRunning = false;

  Timer? waveTimer;
  Timer? pulseTimer;

  List<FlSpot> wavePoints = [];
  double x = 0;

  void startSimulation() {
    // Timer para la onda (se actualiza cada 100 ms)
    waveTimer = Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      setState(() {
        x += 0.1;
        wavePoints.add(FlSpot(x, sin(x) + 1));

        if (wavePoints.length > 50) {
          wavePoints.removeAt(0);
        }
      });
    });

    // Timer para el valor del pulso (cada 2 segundos)
    pulseTimer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {
        pulse = 60 + Random().nextInt(41); // entre 60 y 100 bpm
        print("Nuevo valor simulado: $pulse bpm");
      });
    });

    setState(() {
      isRunning = true;
    });
  }

  void stopSimulation() {
    waveTimer?.cancel();
    pulseTimer?.cancel();
    setState(() {
      isRunning = false;
      wavePoints.clear();
      x = 0;
    });
  }

  @override
  void dispose() {
    waveTimer?.cancel();
    pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simulador de Pulso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Pulso Simulado:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              '$pulse bpm',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 2,
                  lineTouchData: LineTouchData(enabled: false),
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: wavePoints,
                      isStrokeCapRound: true,
                      barWidth: 2,
                      color: Colors.redAccent,
                      dotData: FlDotData(show: false),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: isRunning ? stopSimulation : startSimulation,
              child: Text(isRunning ? 'Detener' : 'Iniciar'),
            ),
          ],
        ),
      ),
    );
  }
}



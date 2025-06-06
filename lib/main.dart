import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const PulseSimulatorApp());
}

class PulseSimulatorApp extends StatelessWidget {
  const PulseSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador de Pulso',
      theme: ThemeData.dark(),
      home: const PulseSimulatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PulseSimulatorScreen extends StatefulWidget {
  const PulseSimulatorScreen({super.key});

  @override
  State<PulseSimulatorScreen> createState() => _PulseSimulatorScreenState();
}

class _PulseSimulatorScreenState extends State<PulseSimulatorScreen> {
  int bpm = 75;
  Timer? bpmTimer;
  Timer? graphTimer;
  bool isRunning = false;
  List<FlSpot> wavePoints = [];
  double time = 0;
  final Random random = Random();

  void startSimulation() {
    bpmTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        bpm = random.nextBool()
            ? 60 + random.nextInt(40) // Rango normal
            : random.nextBool()
            ? 50 + random.nextInt(10) // Rango bajo
            : 100 + random.nextInt(20); // Rango alto
      });
    });

    graphTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      double frequency = bpm / 60; // ciclos por segundo
      double value = _ppgWaveform(time % 1.0) + random.nextDouble() * 0.02;
      setState(() {
        time += frequency * 0.05;
        wavePoints.add(FlSpot(time, value));
        if (wavePoints.length > 100) {
          wavePoints.removeAt(0);
        }
      });
    });

    setState(() => isRunning = true);
  }

  void stopSimulation() {
    bpmTimer?.cancel();
    graphTimer?.cancel();
    setState(() {
      isRunning = false;
      wavePoints.clear();
      time = 0;
    });
  }

  double _ppgWaveform(double t) {
    // Señal tipo PPG modelada artificialmente
    return exp(-pow((t - 0.2) * 15, 2).toDouble()) +
        0.4 * exp(-pow((t - 0.35) * 20, 2).toDouble());
  }

  @override
  void dispose() {
    bpmTimer?.cancel();
    graphTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Pulso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text('Pulso Simulado:',
                style: TextStyle(fontSize: 24, color: Colors.white70)),
            const SizedBox(height: 10),
            Text('$bpm bpm',
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 30),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 1.4,
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: wavePoints,
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.redAccent,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          if (index == wavePoints.length - 1) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.redAccent,
                              strokeWidth: 1.5,
                              strokeColor: Colors.white,
                            );
                          } else {
                            return FlDotCirclePainter(
                              radius: 0,
                              color: Colors.transparent,
                              strokeWidth: 0,
                              strokeColor: Colors.transparent,
                            );
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
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



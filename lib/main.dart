import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const PulseSimulatorApp());

class PulseSimulatorApp extends StatelessWidget {
  const PulseSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador de Pulso',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const PulseSimulatorScreen(),
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
  Timer? updateTimer;
  Timer? graphTimer;
  double x = 0;
  List<FlSpot> wavePoints = [];
  bool isRunning = false;
  int simulationStep = 0;

  @override
  void dispose() {
    updateTimer?.cancel();
    graphTimer?.cancel();
    super.dispose();
  }

  void startSimulation() {
    // Cambia el bpm cada 5 segundos: 100 → 75 → 50 → repetir
    updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() {
        simulationStep++;
        if (simulationStep % 3 == 0) {
          bpm = 100;
        } else if (simulationStep % 3 == 1) {
          bpm = 75;
        } else {
          bpm = 50;
        }
      });
    });

    // Genera la señal basada en el BPM
    graphTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        double period = 60.0 / bpm; // tiempo entre latidos en segundos
        double t = x % period;

        double y = generatePulseShape(t / period);
        wavePoints.add(FlSpot(x, y));

        if (wavePoints.length > 120) {
          wavePoints.removeAt(0);
        }

        x += 0.05;
      });
    });

    setState(() => isRunning = true);
  }

  // Onda tipo pulso simulada
  double generatePulseShape(double phase) {
    if (phase < 0.1) {
      return sin(phase * pi * 10); // pico agudo
    } else if (phase < 0.25) {
      return 0.3 * sin((phase - 0.1) * pi * 6); // caída
    } else {
      return 0.05 * sin((phase - 0.25) * pi * 4); // retorno bajo
    }
  }

  void stopSimulation() {
    updateTimer?.cancel();
    graphTimer?.cancel();
    setState(() => isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de Pulso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pulso Simulado:', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text('$bpm bpm', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  minY: -0.2,
                  maxY: 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: wavePoints,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      color: Colors.redAccent,
                    ),
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



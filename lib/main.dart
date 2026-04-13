import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mengambil daftar kamera yang tersedia
  final cameras = await availableCameras();
  runApp(MaterialApp(home: CloudDetector(cameras: cameras)));
}

class CloudDetector extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CloudDetector({super.key, required this.cameras});

  @override
  State<CloudDetector> createState() => _CloudDetectorState();
}

class _CloudDetectorState extends State<CloudDetector> {
  late CameraController controller;
  double? heading = 0; // Untuk Kompas
  double altitude = 0; // Untuk Ketinggian
  double tilt = 0;     // Untuk Kemiringan

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi Kamera
    controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });

    // Inisialisasi Kompas
    FlutterCompass.events?.listen((event) {
      setState(() => heading = event.heading);
    });

    // Inisialisasi Kemiringan (Accelerometer)
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() => tilt = event.y); // Logika sederhana kemiringan
    });
    
    // Ambil Ketinggian
    _getAltitude();
  }

  void _getAltitude() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() => altitude = position.altitude);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) return Container();
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller), // Tampilan Kamera
          Positioned(
            bottom: 50, left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Arah: ${heading?.toStringAsFixed(0)}°", style: style),
                Text("Ketinggian: ${altitude.toStringAsFixed(1)} m", style: style),
                Text("Kemiringan: ${tilt.toStringAsFixed(1)}°", style: style),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final style = const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold);
}

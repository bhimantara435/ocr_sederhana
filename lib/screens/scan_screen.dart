import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'result_screen.dart';

late List<CameraDescription> cameras;

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller; 
  bool _isCameraReady = false;   
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("Tidak ada kamera terdeteksi!");
        return;
      }

      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      print("Gagal inisialisasi kamera: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<String> _ocrFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedText.text;
  }

  Future<void> _takePicture() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) return;
      final XFile image = await _controller!.takePicture();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Memproses OCR, mohon tunggu...')),
      );

      final ocrText = await _ocrFromFile(File(image.path));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(ocrText: ocrText)),
      );
    } catch (e) {
      // Pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pemindaian Gagal! Periksa Izin Kamera atau coba lagi."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Custom Loading Screen
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.yellow),
              SizedBox(height: 20),
              Text(
                'Memuat Kamera... Harap tunggu.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kamera OCR')),
      body: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera),
              label: const Text('Ambil Foto & Scan'),
            ),
          ),
        ],
      ),
    );
  }
}

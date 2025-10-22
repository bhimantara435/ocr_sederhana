import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 🔹 Import plugin TTS
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final String ocrText;

  const ResultScreen({super.key, required this.ocrText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FlutterTts flutterTts = FlutterTts(); // 🔹 Inisialisasi FlutterTts

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("id-ID"); // 🔹 Set bahasa ke Bahasa Indonesia
  }

  @override
  void dispose() {
    flutterTts.stop(); // 🔹 Hentikan suara saat halaman ditutup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            widget.ocrText.isEmpty
                ? 'Tidak ada teks ditemukan.'
                : widget.ocrText,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),

      // 🔹 Tambahkan dua tombol aksi
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "speakButton",
            onPressed: () async {
              if (widget.ocrText.isNotEmpty) {
                await flutterTts.speak(widget.ocrText);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Tidak ada teks untuk dibacakan."),
                  ),
                );
              }
            },
            child: const Icon(Icons.volume_up),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "homeButton",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}

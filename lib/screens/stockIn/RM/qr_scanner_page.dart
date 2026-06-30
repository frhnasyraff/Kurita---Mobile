import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scans a rack/location QR code and returns the raw scanned string
/// (the location's qr_token) via Navigator.pop.
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  static const primary = Color(0xFF17335C);
  bool _handled = false;
  String? _lastRawSeen; // shown on screen for debugging, even if not yet "handled"

  // Explicit controller with permissive settings — the bare default
  // MobileScanner widget (no controller) was missing detections that a
  // phone's native scanner read fine on the same QR code. formats: [qrCode]
  // and a faster detection speed give the analyzer more chances per second
  // to lock onto the code instead of relying on defaults.
  late final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
    detectionTimeoutMs: 250,
  );

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null || code.isEmpty) return;

    setState(() => _lastRawSeen = code);

    if (_handled) return;
    _handled = true;
    Navigator.pop(context, code);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('SCAN RACK QR'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke QR code pada rack',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
            ),
          ),
          // Debug feedback — shows the raw value as soon as ANY frame
          // decodes successfully, even before the page pops. If this stays
          // blank while pointing at a known-good QR, the analyzer truly
          // isn't decoding any frames. If it briefly flashes a value but the
          // page doesn't navigate away, the bug is in the pop/handling logic
          // instead of detection itself.
          if (_lastRawSeen != null)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Detected: $_lastRawSeen',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
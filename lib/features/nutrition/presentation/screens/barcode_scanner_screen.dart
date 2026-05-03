import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    autoStart: false,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );

  bool _hasScanned = false;
  bool _isScannerReady = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _startScanner();
  }

  Future<void> _startScanner() async {
    try {
      await _scannerController.start();

      if (!mounted) return;

      setState(() {
        _isScannerReady = true;
        _cameraError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isScannerReady = false;
        _cameraError =
            'No se pudo iniciar la cámara. Revisa los permisos o la cámara del emulador.';
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcodes = capture.barcodes;

    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;

    if (code == null || code.trim().isEmpty) return;

    setState(() {
      _hasScanned = true;
    });

    Navigator.pop(context, code.trim());
  }

  Future<void> _toggleTorch() async {
    if (!_isScannerReady) return;

    try {
      await _scannerController.toggleTorch();
    } catch (_) {
      _showMessage('No se pudo activar el flash');
    }
  }

  Future<void> _switchCamera() async {
    if (!_isScannerReady) return;

    try {
      await _scannerController.switchCamera();
    } catch (_) {
      _showMessage('No se pudo cambiar de cámara');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textMain,
        ),
        title: const Text(
          'Escanear alimento',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isScannerReady ? _toggleTorch : null,
            icon: Icon(
              Icons.flash_on,
              color: _isScannerReady
                  ? AppColors.primary
                  : AppColors.textMain.withValues(alpha: 0.35),
            ),
          ),
          IconButton(
            onPressed: _isScannerReady ? _switchCamera : null,
            icon: Icon(
              Icons.cameraswitch,
              color: _isScannerReady
                  ? AppColors.secondary
                  : AppColors.textMain.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_cameraError == null)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.videocam_off_outlined,
                        color: AppColors.error,
                        size: 42,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _cameraError!,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _startScanner,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'REINTENTAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_cameraError == null)
            Center(
              child: Container(
                width: 280,
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
              ),
            ),

          if (_cameraError == null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.5),
                    width: 0.7,
                  ),
                ),
                child: Text(
                  _isScannerReady
                      ? 'Apunta la cámara al código de barras del producto.'
                      : 'Iniciando cámara...',
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';

class BarcodeScannerScreen extends StatefulWidget {
  BarcodeScannerScreen({super.key});

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
            AppLocalizations.of(context)!.nutritionCameraError;
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
      _showMessage(AppLocalizations.of(context)!.nutritionFlashError);
    }
  }

  Future<void> _switchCamera() async {
    if (!_isScannerReady) return;

    try {
      await _scannerController.switchCamera();
    } catch (_) {
      _showMessage(AppLocalizations.of(context)!.nutritionCameraSwitchError);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: context.colors.textMain,
        ),
        title: Text(
          'Escanear alimento',
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isScannerReady ? _toggleTorch : null,
            icon: Icon(
              Icons.flash_on,
              color: _isScannerReady
                  ? context.colors.primary
                  : context.colors.textMain.withOpacity(0.35),
            ),
          ),
          IconButton(
            onPressed: _isScannerReady ? _switchCamera : null,
            icon: Icon(
              Icons.cameraswitch,
              color: _isScannerReady
                  ? context.colors.secondary
                  : context.colors.textMain.withOpacity(0.35),
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
                padding: EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam_off_outlined,
                        color: AppColors.error,
                        size: 42,
                      ),
                      SizedBox(height: 16),
                      Text(
                        _cameraError!,
                        style: TextStyle(
                          color: context.colors.textMain,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _startScanner,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
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
                    color: context.colors.primary,
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
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: context.colors.surface.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: context.colors.divider.withOpacity(0.5),
                    width: 0.7,
                  ),
                ),
                child: Text(
                  _isScannerReady
                      ? AppLocalizations.of(context)!.nutritionCameraHint
                      : AppLocalizations.of(context)!.nutritionCameraStarting,
                  style: TextStyle(
                    color: context.colors.textMain,
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

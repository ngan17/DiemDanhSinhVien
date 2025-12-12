import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/attendant_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final int eventDetailId;
  final String eventName;
  final String? session;

  const BarcodeScannerScreen({
    Key? key,
    required this.eventDetailId,
    this.eventName = 'Sự kiện',
    this.session,
  }) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode, BarcodeFormat.code128, BarcodeFormat.ean13],
  );
  bool _isProcessing = false;
  bool _flashOn = false;
  int _successCount = 0;
  DateTime? _lastScanTime;
  String? _lastScannedCode; // Lưu mã vừa quét
  
  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // Phát âm thanh beep khi quét
  Future<void> _playBeep({bool isSuccess = true}) async {
    try {
      if (isSuccess) {
        await SystemSound.play(SystemSoundType.click);
      } else {
        await SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  Future<void> _handleBarcode(String barcode) async {
    // ← THÊM: Kiểm tra nếu đang xử lý thì bỏ qua
    if (_isProcessing) {
      return;
    }

    // ← THÊM: Debounce - nếu quét cùng mã trong 1.5 giây thì chỉ hiện thông báo ngắn
    final now = DateTime.now();
    if (_lastScannedCode == barcode && 
        _lastScanTime != null && 
        now.difference(_lastScanTime!) < const Duration(milliseconds: 1500)) {
      // Chỉ hiện SnackBar ngắn, không block quét
      _showQuickMessage(' Vừa quét mã này rồi', isWarning: true);
      await _playBeep(isSuccess: false);
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastScannedCode = barcode;
      _lastScanTime = now;
    });

    // Phát âm thanh beep ngay khi quét được
    await _playBeep(isSuccess: true);

    try {
      final result = await AttendantService.attendByBarcode(
        eventDetailId: widget.eventDetailId,
        barcode: barcode,
      );

      if (mounted) {
        final isSuccess = result['success'] == true;

        if (isSuccess) {
          _successCount++;
          setState(() {});

          // ← Hiện SnackBar thành công (giữ nguyên)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '✓ ${result['studentName']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'MSSV: ${result['studentId']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          // ← SỬA: Chỉ hiện SnackBar thay vì Dialog
          await _playBeep(isSuccess: false);
          _showErrorSnackBar(result);
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
    } catch (e) {
      if (mounted) {
        await _playBeep(isSuccess: false);
        _showErrorSnackBar({'success': false, 'message': 'Lỗi: $e'});
        await Future.delayed(const Duration(milliseconds: 800));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // ← THÊM: Hiện thông báo nhanh không chặn quét
  void _showQuickMessage(String message, {bool isWarning = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isWarning ? Icons.warning : Icons.info,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isWarning ? Colors.orange : Colors.blue,
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ← THÊM: Hiện lỗi bằng SnackBar thay vì Dialog
  void _showErrorSnackBar(Map<String, dynamic> result) {
    final studentInfo = result['studentName'] != null
        ? '${result['studentName']} (${result['studentId']})'
        : '';
    
    final message = result['message'] ?? 'Có lỗi xảy ra';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Điểm danh thất bại!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            if (studentInfo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                studentInfo,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(milliseconds: 2500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _toggleFlash() {
    setState(() => _flashOn = !_flashOn);
    _cameraController.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quét mã điểm danh', style: TextStyle(fontSize: 18)),
            Text(
              widget.eventName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          if (_successCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_successCount ✓',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: _flashOn ? 'Tắt đèn flash' : 'Bật đèn flash',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            placeholderBuilder: (context, child) {
              return const ColoredBox(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              );
            },
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _handleBarcode(barcodes.first.rawValue!);
              }
            },
          ),
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? Colors.orange : Colors.green,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomPaint(
                painter: ScannerOverlayPainter(isProcessing: _isProcessing),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _isProcessing
                      ? Colors.orange
                      : Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: _isProcessing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Đang xử lý...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Đưa mã vào khung để quét',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  final bool isProcessing;

  ScannerOverlayPainter({required this.isProcessing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isProcessing ? Colors.orange : Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30;

    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

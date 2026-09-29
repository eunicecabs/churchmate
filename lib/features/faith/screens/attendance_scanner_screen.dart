import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../core/services/auth_service.dart';
import '../../qr/services/person_scan_service.dart';

/// Scanner for Youth Members and Youth Leaders, opened from an event
/// (route argument = eventId). Scanning an Elder/Member ID QR ("ELD-0001" /
/// "MEM-0001") saves a scan record for the signed-in scanner, counts the
/// person in that event's Live Attendance, and shows the result immediately
/// (no history is shown here).
class AttendanceScannerScreen extends StatefulWidget {
  const AttendanceScannerScreen({super.key});

  @override
  State<AttendanceScannerScreen> createState() => _AttendanceScannerScreenState();
}

class _ScanView {
  final IconData icon;
  final Color color;
  final String title;
  final String? name;
  final String? role;
  final String message;
  const _ScanView(this.icon, this.color, this.title, this.message, {this.name, this.role});
}

class _AttendanceScannerScreenState extends State<AttendanceScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final PersonScanService _personScan = PersonScanService();
  bool _isProcessing = false;
  _ScanView? _view;
  String? _eventId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String) _eventId = arg;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final code = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (code == null) return;

    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    try {
      _ScanView view;
      if (PersonScanService.isPersonQr(code)) {
        final r = await _personScan.scan(rawCode: code, scanner: user, eventId: _eventId);
        view = _viewForPerson(r);
      } else {
        view = const _ScanView(Icons.error, AppColors.statusAlert, 'Invalid QR',
            'This is not an Elder/Member ID QR code.');
      }
      if (!mounted) return;
      setState(() => _view = view);
    } catch (_) {
      if (!mounted) return;
      setState(() => _view = const _ScanView(Icons.error, AppColors.statusAlert, 'Scan Failed',
          'Something went wrong while scanning. Please try again.'));
    }
  }

  _ScanView _viewForPerson(PersonScanResult r) {
    switch (r.status) {
      case PersonScanStatus.success:
        return _ScanView(Icons.check_circle, AppColors.statusSuccess, 'Scan Successful', '',
            name: r.personName, role: r.personRole);
      case PersonScanStatus.alreadyScanned:
        return _ScanView(Icons.info, AppColors.statusPending, 'Already Scanned', r.message,
            name: r.personName, role: r.personRole);
      case PersonScanStatus.inactive:
        return _ScanView(Icons.block, AppColors.statusAlert, 'QR Deactivated', r.message,
            name: r.personName, role: r.personRole);
      default:
        return _ScanView(Icons.error, AppColors.statusAlert, 'Scan Failed', r.message);
    }
  }

  void _scanAgain() {
    setState(() {
      _isProcessing = false;
      _view = null;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final view = _view;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Scan QR', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Scan frame overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54, width: 2),
                borderRadius: BorderRadius.circular(AppRadius.container),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.prominent)),
              ),
              child: SafeArea(
                top: false,
                child: view == null
                    ? const Text(
                        'Point your camera at an Elder/Member ID QR.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(view.icon, color: view.color, size: 40),
                          const SizedBox(height: 8),
                          Text(view.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                          if (view.name != null) ...[
                            const SizedBox(height: 6),
                            Text(view.name!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
                            if (view.role != null)
                              Text(view.role!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                          ],
                          if (view.message.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(view.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                          ],
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _scanAgain,
                            style: AppButtonStyles.primary,
                            child: const Text('Scan Again'),
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

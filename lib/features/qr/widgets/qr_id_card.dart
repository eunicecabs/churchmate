import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/theme.dart';
import '../models/qr_person_model.dart';

/// Printable ID card: name, role, ID and the QR. The QR encodes ONLY the ID
/// (e.g. "ELD-0001") - no personal information.
class QrIdCard extends StatelessWidget {
  final QrPerson person;
  final GlobalKey repaintKey;
  const QrIdCard({super.key, required this.person, required this.repaintKey});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('ChurchMate', style: AppTextStyles.labelSm),
          const SizedBox(height: 8),
          QrImageView(
            data: person.qrId,
            version: QrVersions.auto,
            size: 190,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
            dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(person.name, textAlign: TextAlign.center, style: AppTextStyles.headlineMd),
          Text(person.role, style: AppTextStyles.bodyMd),
          const SizedBox(height: 2),
          Text(person.qrId, style: AppTextStyles.labelLg),
        ]),
      ),
    );
  }
}

/// Renders the card to a PNG and opens the share sheet (save to gallery/files,
/// send to a printer app, etc.). Uses packages already in pubspec.yaml.
Future<void> shareQrCard(GlobalKey key, String qrId) async {
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;
  final image = await boundary.toImage(pixelRatio: 3);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  if (bytes == null) return;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$qrId.png');
  await file.writeAsBytes(bytes.buffer.asUint8List());
  await Share.shareXFiles([XFile(file.path)], text: qrId);
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Shows a book cover from a Storage/network URL, or (fallback storage) from
/// base64 bytes saved on the book document. Falls back to [fallback] (the
/// existing default book icon) when nothing valid is available, the image was
/// deleted, or the network is down - it never throws.
class BookCover extends StatelessWidget {
  final String? url;
  final String? base64Data;
  final double width;
  final double height;
  final Widget fallback;

  const BookCover({
    super.key,
    required this.url,
    this.base64Data,
    required this.width,
    required this.height,
    required this.fallback,
  });

  bool get _validUrl {
    final u = url?.trim();
    if (u == null || u.isEmpty) return false;
    final uri = Uri.tryParse(u);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  Uint8List? get _bytes {
    final b = base64Data;
    if (b == null || b.isEmpty) return null;
    try {
      return base64Decode(b);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_validUrl) {
      return Image.network(
        url!.trim(),
        width: width,
        height: height,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
          );
        },
        errorBuilder: (context, error, stackTrace) => _fromBytesOrFallback(),
      );
    }
    return _fromBytesOrFallback();
  }

  Widget _fromBytesOrFallback() {
    final bytes = _bytes;
    if (bytes == null) return fallback;
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

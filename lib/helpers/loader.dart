import 'package:flutter/material.dart';

class Loader {
  static OverlayEntry? _entry;
  static bool _open = false;

  Loader._();
  static void show() {
    _entry ??= OverlayEntry(
      builder: (context) {
        return Container(
          color: Colors.black54,
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      },
    );

    if (!_open) {
      _open = true;
      // ignore: deprecated_member_use
      //asuka.addOverlay(_entry!);
      // asuka.AsukaMaterialBanner;
    }
  }

  static void hide() {
    if (_open) {
      _open = false;
      _entry?.remove();
    }
  }
}

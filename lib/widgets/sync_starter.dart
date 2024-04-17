import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SyncStarter extends StatefulWidget {
  const SyncStarter({super.key, required this.child, required this.onSync});

  final Widget child;
  final void Function() onSync;
  @override
  State<SyncStarter> createState() => _SyncStarterState();
}

class _SyncStarterState extends State<SyncStarter> {
  static const double syncThreshold = 200;

  Offset _pullOffset = Offset.zero;
  Offset _startOffset = Offset.zero;
  @override
  Widget build(BuildContext context) {
    final isThreshold = _pullOffset.dy > syncThreshold;
    final alphaValue = isThreshold ? 255 : (_pullOffset.dy / syncThreshold * 255).toInt();

    return Listener(
      onPointerDown: (details) {
        _startOffset = details.position;
      },
      onPointerMove: (details) {
        if (details.delta.dy == 0) return;

        setState(() {
          _pullOffset = details.position - _startOffset;
        });
      },
      onPointerUp: (details) {
        if (isThreshold) {
          widget.onSync();
        }
        setState(() {
          _pullOffset = Offset.zero;
        });
      },
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          widget.child,
          Positioned(
            top: (!isThreshold ? _pullOffset.dy : syncThreshold) - 50,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: !isThreshold ? Theme.of(context).colorScheme.background.withAlpha(alphaValue) : Theme.of(context).colorScheme.primary.withAlpha(alphaValue),
              child: Icon(
                !isThreshold ? Ionicons.cloud_outline : Ionicons.cloud_download_outline,
                color: !isThreshold ? Theme.of(context).colorScheme.primary.withAlpha(alphaValue) : Theme.of(context).colorScheme.background.withAlpha(alphaValue),
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SyncIndicator extends StatefulWidget {
  const SyncIndicator({super.key, required this.state, required this.hasData, required this.textColor});
  final ConnectionState state;
  final bool hasData;
  final Color textColor;

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (widget.state == ConnectionState.done && widget.hasData) {
      return Padding(
        padding: const EdgeInsets.only(right: 30),
        child: Row(
          children: [
            Icon(
              Ionicons.checkmark_circle_outline,
              color: widget.textColor,
            ),
            Text(
              " Synchronisiert",
              style: TextStyle(color: widget.textColor),
            )
          ],
        ),
      );
    }
    if (widget.state == ConnectionState.done) {
      return Padding(
        padding: const EdgeInsets.only(right: 30),
        child: Row(
          children: [
            Icon(
              Ionicons.cloud_offline_outline,
              color: widget.textColor,
            ),
            Text(
              " Fehler",
              style: TextStyle(color: widget.textColor),
            )
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Row(
        children: [
          RotationTransition(
            turns: AnimationController(
              duration: const Duration(seconds: 1, milliseconds: 500),
              vsync: this,
            )..repeat(),
            child: Icon(
              Ionicons.sync_outline,
              color: widget.textColor,
            ),
          ),
          Text(
            " Synchronisiere",
            style: TextStyle(color: widget.textColor),
          )
        ],
      ),
    );
  }
}

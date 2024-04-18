import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SyncIndicator extends StatefulWidget {
  const SyncIndicator({super.key, required this.state, required this.hasData});
  final ConnectionState state;
  final bool hasData;

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> with TickerProviderStateMixin {
  late final AnimationController _positionController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );
  late final Animation<Offset> _position = Tween<Offset>(
    begin: Offset(1.5, 0),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _positionController,
      curve: Curves.ease,
    ),
  );

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;

    if (widget.state == ConnectionState.done && widget.hasData) {
      Future.delayed(const Duration(seconds: 2), () {
        // Check again for condition, because the state could have been changed if the user reloaded too early
        if (widget.state == ConnectionState.done && widget.hasData) {
          _positionController.reverse();
        }
      });
      return buildContainer(
        Colors.green,
        Icon(
          Ionicons.checkmark_circle_outline,
          color: color,
        ),
        " Synchronisiert",
        color,
      );
    }

    if (widget.state == ConnectionState.done) {
      return buildContainer(
        Colors.red,
        Icon(
          Ionicons.cloud_offline_outline,
          color: color,
        ),
        " Fehler",
        color,
      );
    }
    _positionController.forward();
    return buildContainer(
      Colors.orange,
      RotationTransition(
        turns: AnimationController(
          duration: const Duration(seconds: 1, milliseconds: 500),
          vsync: this,
        )..repeat(),
        child: Icon(
          Ionicons.sync_outline,
          color: color,
        ),
      ),
      " Synchronisiere",
      color,
    );
  }

  Widget buildContainer(Color color, Widget icon, String text, Color textColor) {
    return SlideTransition(
      position: _position,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 150,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withAlpha(150),
                blurRadius: 5,
                offset: const Offset(4, 3),
              ),
            ]),
        child: Row(
          children: [
            icon,
            Text(
              text,
              style: TextStyle(color: textColor),
            )
          ],
        ),
      ),
    );
  }
}

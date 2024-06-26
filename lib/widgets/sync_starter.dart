import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SyncStarter extends StatefulWidget {
  const SyncStarter({super.key, required this.child, required this.onSync});

  final Widget child;
  final void Function() onSync;
  @override
  State<SyncStarter> createState() => _SyncStarterState();
}

class _SyncStarterState extends State<SyncStarter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const double syncThreshold = 200;
  bool isSyncing = false;
  Offset _pullOffset = Offset.zero;
  Offset _startOffset = Offset.zero;
  @override
  Widget build(BuildContext context) {
    final isThreshold = _pullOffset.dy > syncThreshold;
    final alphaValue = isThreshold ? 255 : (_pullOffset.dy / syncThreshold * 255).toInt();

    return Listener(
      onPointerDown: (details) {
        _controller.stop();
        _startOffset = details.position;
      },
      onPointerMove: (details) {
        if (details.delta.dy == 0 || _startOffset == Offset.zero) return;

        setState(() {
          _pullOffset = details.position - _startOffset;
        });
      },
      onPointerUp: (details) {
        if (isThreshold) {
          widget.onSync();
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              isSyncing = false;
              _controller.reset();
              _pullOffset = Offset.zero;
            });
          });
          setState(() {
            isSyncing = true;
          });
        } else {
          late final Animation<Offset> animation;
          animation = Tween<Offset>(
            begin: _pullOffset,
            end: Offset.zero,
          ).animate(_controller)
            ..addListener(() {
              setState(() {
                _pullOffset = animation.value;
              });
            });
          _controller.reset();
          _controller.forward();
        }
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Only allow pull down, if no other scrollable is active in the widget tree
          if (notification is ScrollStartNotification) {
            // Check if the scrollable is at the top
            if (notification.metrics.pixels != 0) {
              _startOffset = Offset.zero;
            }
          }
          return false;
        },
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            widget.child,
            Positioned(
              top: (!isThreshold ? _pullOffset.dy : syncThreshold) - 50,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: !isThreshold ? Theme.of(context).colorScheme.surface.withAlpha(alphaValue) : Theme.of(context).colorScheme.primary.withAlpha(alphaValue),
                child: Icon(
                  isSyncing
                      ? Ionicons.sync_outline
                      : !isThreshold
                          ? Ionicons.cloud_outline
                          : Ionicons.cloud_download_outline,
                  color: !isThreshold ? Theme.of(context).colorScheme.primary.withAlpha(alphaValue) : Theme.of(context).colorScheme.surface.withAlpha(alphaValue),
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

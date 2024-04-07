import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class SettingsPopup extends StatefulWidget {
  SettingsPopup({
    required this.icons,
    required this.onIconTapped,
    required this.child,
  });
  final List<IconData>? icons;
  ValueChanged<int>? onIconTapped;
  final Widget child;

  @override
  State createState() => SettingsPopupState();
}

class SettingsPopupState extends State<SettingsPopup> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset) {
        return Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              child: ModalBarrier(
                color: Theme.of(context).colorScheme.onBackground.withAlpha(130),
                onDismiss: (() {
                  _controller.reverse();
                }),
              ),
              builder: ((context, child) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: Interval(0.0, 1, curve: InstantOne()),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _controller,
                      curve: Interval(0.0, 1, curve: Curves.easeOut),
                    ),
                    child: child,
                  ),
                );
              }),
            ),
            CenterAbout(
              position: Offset(offset.dx, offset.dy - widget.icons!.length * 35.0 - 25),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.icons!.length, (int index) {
                    return _buildChild(index);
                  }).toList()),
            ),
          ],
        );
      },
      child: InkWell(
        onTap: () {
          if (_controller.isDismissed) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        },
        child: widget.child,
      ),
    );
  }

  Widget _buildChild(int index) {
    return Container(
      height: 70.0,
      width: 56.0,
      alignment: FractionalOffset.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 1.0 - index / widget.icons!.length / 2.0, curve: Curves.easeOut),
        ),
        child: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.background,
          mini: true,
          child: Icon(widget.icons![index], color: Theme.of(context).colorScheme.primary),
          onPressed: () => _onTapped(index),
        ),
      ),
    );
  }

  void _onTapped(int index) {
    _controller.reverse();
    widget.onIconTapped!(index);
  }
}

class AnchoredOverlay extends StatelessWidget {
  final bool showOverlay;
  final Widget Function(BuildContext, Offset anchor) overlayBuilder;
  final Widget child;

  const AnchoredOverlay({
    super.key,
    required this.showOverlay,
    required this.overlayBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return OverlayBuilder(
        showOverlay: showOverlay,
        overlayBuilder: (BuildContext overlayContext) {
          RenderBox box = context.findRenderObject() as RenderBox;
          final center = box.size.center(box.localToGlobal(const Offset(0.0, 0.0)));
          return overlayBuilder(overlayContext, center);
        },
        child: child,
      );
    });
  }
}

class OverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final Widget Function(BuildContext) overlayBuilder;
  final Widget child;

  const OverlayBuilder({
    super.key,
    this.showOverlay = false,
    required this.overlayBuilder,
    required this.child,
  });

  @override
  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  late OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();

    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) => syncWidgetAndOverlay());
  }

  @override
  void dispose() {
    if (isShowingOverlay()) {
      hideOverlay();
    }

    super.dispose();
  }

  bool isShowingOverlay() => overlayEntry != null;

  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: widget.overlayBuilder,
    );
    addToOverlay(overlayEntry!);
  }

  void addToOverlay(OverlayEntry entry) async {
    Overlay.of(context)!.insert(entry);
  }

  void hideOverlay() {
    overlayEntry!.remove();
    overlayEntry = null;
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay) {
      showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class CenterAbout extends StatelessWidget {
  final Offset position;
  final Widget child;

  const CenterAbout({
    super.key,
    required this.position,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: child,
      ),
    );
  }
}

class InstantOne extends Curve {
  @override
  double transformInternal(double t) {
    return t == 0 ? 0 : 1;
  }
}

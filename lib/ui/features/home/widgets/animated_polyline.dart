import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:where_im_at/utils/extensions/build_context_extensions.dart';
import 'package:where_im_at/utils/extensions/int_extensions.dart';

class AnimatedPolyline extends StatefulWidget {
  const AnimatedPolyline(this.points, {super.key});

  final List<LatLng> points;

  @override
  State<AnimatedPolyline> createState() => _AnimatedPolylineState();
}

class _AnimatedPolylineState extends State<AnimatedPolyline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  List<LatLng> _currentPoints = [];

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(duration: 2.seconds, vsync: this);

    // Initialize Animation
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn)
          ..addListener(_updateCurrentPoints);

    // Start Animation
    _controller.forward();
  }

  void _updateCurrentPoints() {
    final portion = _animation.value;
    final visibleCount = (widget.points.length * portion).ceil();
    setState(() {
      _currentPoints = widget.points.take(visibleCount).toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PolylineLayer(
      polylines: [
        Polyline(
          points: _currentPoints,
          color: context.colorScheme.primary,
          strokeWidth: 4,
        ),
      ],
    );
  }
}

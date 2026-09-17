import 'dart:math' as math;

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/zekrni_header.dart';
import '../application/qibla_controller.dart';
import '../domain/qibla_direction.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key, required this.controller});

  final QiblaController controller;

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late Future<QiblaDirection> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.value(widget.controller.savedLocationDirection());
  }

  void _useCurrentLocation() {
    setState(() {
      _future = widget.controller.currentLocationDirection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ZekrniHeader(
              title: 'القبلة',
              subtitle: 'اتجاه دقيق من موقعك إلى الكعبة',
            ),
            Expanded(
              child: FutureBuilder<QiblaDirection>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return _QiblaError(
                      message: snapshot.error.toString(),
                      onRetry: _useCurrentLocation,
                    );
                  }
                  final direction = snapshot.data!;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _CompassCard(direction: direction),
                      const SizedBox(height: 14),
                      _DirectionInfo(direction: direction),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _useCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('استخدام موقعي الحالي'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassCard extends StatelessWidget {
  const _CompassCard({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            StreamBuilder<CompassEvent>(
              stream: FlutterCompass.events,
              builder: (context, snapshot) {
                final heading = snapshot.data?.heading;
                final relativeBearing = heading == null
                    ? direction.bearing
                    : (direction.bearing - heading + 360) % 360;
                return Column(
                  children: [
                    SizedBox.square(
                      dimension: 230,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.primary.withValues(alpha: 0.22),
                                width: 2,
                              ),
                            ),
                          ),
                          Transform.rotate(
                            angle: -(heading ?? 0) * math.pi / 180,
                            child: const PositionedCompassLabels(),
                          ),
                          Transform.rotate(
                            angle: relativeBearing * math.pi / 180,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.navigation,
                                  size: 98,
                                  color: color.primary,
                                ),
                                const SizedBox(height: 14),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: color.secondary,
                            child: Icon(Icons.mosque, color: color.onSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      heading == null
                          ? 'حرك الهاتف لمعايرة البوصلة'
                          : 'اتجاه الهاتف ${heading.round()}\u00b0',
                      style: TextStyle(color: color.onSurfaceVariant),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              direction.bearingLabel,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              'من اتجاه الشمال',
              style: TextStyle(color: color.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class PositionedCompassLabels extends StatelessWidget {
  const PositionedCompassLabels({super.key});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w800,
    );
    return SizedBox.square(
      dimension: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: Text('N', style: style)),
          Positioned(bottom: 0, child: Text('S', style: style)),
          Positioned(left: 0, child: Text('W', style: style)),
          Positioned(right: 0, child: Text('E', style: style)),
        ],
      ),
    );
  }
}

class _DirectionInfo extends StatelessWidget {
  const _DirectionInfo({required this.direction});

  final QiblaDirection direction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.place_outlined),
            title: const Text('الموقع'),
            subtitle: Text(direction.city),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('المسافة إلى مكة'),
            subtitle: Text(direction.distanceLabel),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: const Text('الإحداثيات المستخدمة'),
            subtitle: Text(
              '${direction.latitude.toStringAsFixed(4)}, '
              '${direction.longitude.toStringAsFixed(4)}',
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaError extends StatelessWidget {
  const _QiblaError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ErrorStateView(message: message),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

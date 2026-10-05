import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models.dart';

/// Interactive delivery map following actual street paths with on-map zoom controls
/// and a clean, road-aligned highlighted polyline.
class DemoDeliveryMap extends StatefulWidget {
  const DemoDeliveryMap({super.key, required this.order});
  final GroceryOrder order;

  @override
  State<DemoDeliveryMap> createState() => _DemoDeliveryMapState();
}

class _DemoDeliveryMapState extends State<DemoDeliveryMap> {
  late final MapController _mapController;

  static const _storeHub = LatLng(19.05253, 73.07351); // Kharghar Sector 12 Hub
  static const _defaultDestination = LatLng(19.04380, 73.06820); // Sector 14

  LatLng get _destination {
    final location = widget.order.deliveryLocation;
    final latitude = location?['latitude'];
    final longitude = location?['longitude'];
    if (latitude is num && longitude is num) {
      return LatLng(latitude.toDouble(), longitude.toDouble());
    }
    return _defaultDestination;
  }

  /// Actual street road route following Central Park Road -> Raghunath Road -> Apeejay Road.
  List<LatLng> get _roadRoute {
    final dest = _destination;
    return [
      _storeHub,
      const LatLng(19.05250, 73.07220), // West along Central Park Road
      const LatLng(19.05245, 73.07080), // Junction Central Park Rd & Central Park Metro Rd
      const LatLng(19.05050, 73.07050), // South along Central Park Metro Road
      const LatLng(19.04850, 73.07000), // Along Raghunath Road
      const LatLng(19.04700, 73.06970), // Roundabout / Apeejay intersection
      const LatLng(19.04610, 73.06900), // Turn into Apeejay Road
      const LatLng(19.04500, 73.06850), // Along Sector 14 access street
      dest,                              // Customer destination doorstep
    ];
  }

  LatLng get _riderLocation {
    final status = widget.order.status;
    final route = _roadRoute;
    if (status == 'delivered') return _destination;
    if (status == 'out_for_delivery') {
      // Place the rider directly on the street path midway along Apeejay Road
      final midIndex = (route.length * 0.6).round().clamp(0, route.length - 1);
      return route[midIndex];
    }
    return _storeHub;
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  void _fitRoute() {
    final bounds = LatLngBounds.fromPoints(_roadRoute);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final route = _roadRoute;
    final dest = _destination;
    final rider = _riderLocation;
    final bounds = LatLngBounds.fromPoints(route);
    final isOut = widget.order.status == 'out_for_delivery';
    final isDelivered = widget.order.status == 'delivered';
    final riderName = widget.order.delivery?['riderName'] as String? ?? 'Qwik Pilot';

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surfaceContainerLow,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDelivered
                        ? Icons.check_circle
                        : isOut
                            ? Icons.delivery_dining
                            : Icons.storefront,
                    color: AppColors.emeraldPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDelivered
                            ? 'Delivered to your doorstep'
                            : isOut
                                ? '$riderName is on the way'
                                : 'Order packing at Qwik Hub',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDelivered
                            ? 'Arrival completed'
                            : 'Live road route · ~10 mins ETA',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isDelivered
                        ? 'ARRIVED'
                        : isOut
                            ? 'LIVE ROUTE'
                            : 'PREPARING',
                    style: const TextStyle(
                      color: AppColors.emeraldPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCameraFit: CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 48,
                      ),
                    ),
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.qwikgrocery.app',
                      maxNativeZoom: 19,
                    ),
                    // Road Route Polyline - Clean, simple, non-distracting highlight
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route,
                          color: AppColors.emeraldPrimary,
                          strokeWidth: 3.5,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // 1. Store Hub Marker
                        Marker(
                          point: _storeHub,
                          width: 42,
                          height: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.emeraldPrimary,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.storefront,
                              color: AppColors.emeraldPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        // 2. Customer Destination Marker
                        Marker(
                          point: dest,
                          width: 42,
                          height: 42,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.warmYellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                        // 3. Live Rider Pin (if active)
                        if (isOut || isDelivered)
                          Marker(
                            point: rider,
                            width: 48,
                            height: 48,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.emeraldPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delivery_dining,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                // Floating On-Map Navigation Controls (Zoom In, Zoom Out, Fit Route)
                Positioned(
                  right: 12,
                  bottom: 14,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MapActionButton(
                        icon: Icons.add,
                        tooltip: 'Zoom In',
                        onTap: _zoomIn,
                      ),
                      const SizedBox(height: 6),
                      _MapActionButton(
                        icon: Icons.remove,
                        tooltip: 'Zoom Out',
                        onTap: _zoomOut,
                      ),
                      const SizedBox(height: 6),
                      _MapActionButton(
                        icon: Icons.crop_free,
                        tooltip: 'Fit Route',
                        onTap: _fitRoute,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 3,
    color: AppColors.surface,
    shape: const CircleBorder(),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    ),
  );
}

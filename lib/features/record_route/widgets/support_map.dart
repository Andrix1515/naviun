import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants.dart';
import '../../../core/strings.dart';
import '../../../data/models/waypoint_model.dart';

/// Mapa de apoyo visual con OpenStreetMap y `flutter_map`.
///
/// Si no hay conexión, muestra un aviso accesible y permite que el registro continúe sin interrupciones.
class SupportMap extends StatefulWidget {
  final List<WaypointModel> waypoints;
  final LatLng? userLocation;
  final double? userAccuracy;
  final Function(int index, LatLng newPosition)? onWaypointMoved;
  final Function(LatLng tappedPosition)? onMapTapped;

  const SupportMap({
    super.key,
    required this.waypoints,
    this.userLocation,
    this.userAccuracy,
    this.onWaypointMoved,
    this.onMapTapped,
  });

  @override
  State<SupportMap> createState() => _SupportMapState();
}

class _SupportMapState extends State<SupportMap> {
  final MapController _mapController = MapController();
  bool _hasTileError = false;

  // Centro por defecto: Campus UNCP Huancayo
  static const LatLng _uncpCampusDefault = LatLng(-12.056388, -75.218888);

  LatLng get _initialCenter {
    if (widget.userLocation != null) return widget.userLocation!;
    for (final wp in widget.waypoints) {
      if (wp.hasCoordinates) {
        return LatLng(wp.latitud!, wp.longitud!);
      }
    }
    return _uncpCampusDefault;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Extraer puntos con coordenadas válidas para la polilínea y marcadores
    final pointsWithCoords = <MapEntry<int, WaypointModel>>[];
    for (int i = 0; i < widget.waypoints.length; i++) {
      if (widget.waypoints[i].hasCoordinates) {
        pointsWithCoords.add(MapEntry(i, widget.waypoints[i]));
      }
    }

    final polylinePoints = pointsWithCoords
        .map((e) => LatLng(e.value.latitud!, e.value.longitud!))
        .toList();

    return Semantics(
      label:
          'Mapa de apoyo visual del campus con ${pointsWithCoords.length} puntos de control marcados. '
          'El mapa es un apoyo visual opcional y no limita el uso de la aplicación.',
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 17.0,
              onTap: (tapPos, point) {
                if (widget.onMapTapped != null) {
                  widget.onMapTapped!(point);
                }
              },
            ),
            children: [
              // Capa de teselas de OpenStreetMap con userAgentPackageName
              TileLayer(
                urlTemplate: AppConstants.osmTileUrl,
                userAgentPackageName: AppConstants.osmUserAgent,
                errorTileCallback: (tile, error, stackTrace) {
                  if (!_hasTileError && mounted) {
                    setState(() => _hasTileError = true);
                  }
                },
              ),

              // Círculo de precisión de la ubicación actual
              if (widget.userLocation != null && widget.userAccuracy != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: widget.userLocation!,
                      radius: widget.userAccuracy!.clamp(5.0, 100.0),
                      useRadiusInMeter: true,
                      color: AppConstants.primaryGreenLight.withValues(alpha: 0.18),
                      borderColor: AppConstants.primaryGreenLight,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // Polilínea que une los puntos en orden
              if (polylinePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      strokeWidth: 4.5,
                      color: isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight,
                    ),
                  ],
                ),

              // Marcadores de los puntos guardados
              MarkerLayer(
                markers: [
                  // Marcador de ubicación actual del usuario
                  if (widget.userLocation != null)
                    Marker(
                      point: widget.userLocation!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppConstants.accentGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2.5),
                        ),
                      ),
                    ),

                  // Marcadores de puntos de control de la ruta
                  ...pointsWithCoords.map((entry) {
                    final index = entry.key;
                    final wp = entry.value;
                    final pos = LatLng(wp.latitud!, wp.longitud!);

                    return Marker(
                      point: pos,
                      width: 44,
                      height: 44,
                      child: GestureDetector(
                        onLongPress: () {
                          // Notificar sugerencia de ajuste
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Punto "${wp.nombre}": Puedes tocar el mapa para reposicionar.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppConstants.primaryGreenDark : AppConstants.primaryGreenLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: wp.posicionAjustadaManual ? AppConstants.accentGold : Colors.white,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Aviso si las teselas fallan (sin conexión)
          if (_hasTileError)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF332000) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppConstants.accentGold, width: 1.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Color(0xFFD97706), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.mapOfflineNotice,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Atribución de OpenStreetMap obligatoria
          Positioned(
            bottom: 4,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: Colors.black.withValues(alpha: 0.6),
              child: const Text(
                AppConstants.osmAttribution,
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),

          // Botón de centrado
          Positioned(
            bottom: 12,
            left: 12,
            child: FloatingActionButton.small(
              heroTag: 'center_map_btn',
              backgroundColor: isDark ? AppConstants.surfaceDark : Colors.white,
              foregroundColor: isDark ? Colors.white : AppConstants.primaryGreenLight,
              tooltip: AppStrings.mapCenterOnUser,
              onPressed: () {
                if (widget.userLocation != null) {
                  _mapController.move(widget.userLocation!, 18.0);
                } else {
                  _mapController.move(_initialCenter, 17.0);
                }
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/contract_service.dart';
import '../constants/colors.dart';

class ReportsHeatMap extends StatelessWidget {
  final List<ReportData> reports;

  const ReportsHeatMap({
    super.key,
    required this.reports,
  });

  @override
  Widget build(BuildContext context) {
    final points = reports.map((report) {
      final locationParts = report.location.split(',');
      final latitude = double.tryParse(locationParts[0]) ?? 0.0;
      final longitude = double.tryParse(locationParts[1]) ?? 0.0;
      return LatLng(latitude, longitude);
    }).toList();

    // Calculate center point
    final centerLat = points.isEmpty
        ? 0.0
        : points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final centerLng = points.isEmpty
        ? 0.0
        : points.map((p) => p.longitude).reduce((a, b) => a + b) /
            points.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        options: MapOptions(
          center: LatLng(centerLat, centerLng),
          zoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: points
                .map((point) => Marker(
                      point: point,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.orange.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.orange.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

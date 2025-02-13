import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../services/contract_service.dart';

class ReportDetailsDialog extends StatelessWidget {
  final ReportData report;

  const ReportDetailsDialog({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    // Parse location string to get latitude and longitude
    final locationParts = report.location.split(',');
    final latitude = double.tryParse(locationParts[0]) ?? 0.0;
    final longitude = double.tryParse(locationParts[1]) ?? 0.0;
    final location = LatLng(latitude, longitude);

    return Dialog(
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: FlutterMap(
                  options: MapOptions(
                    center: location,
                    zoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: location,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.orange,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text('Description: ${report.description}'),
                  const SizedBox(height: 8),
                  Text(
                    'Location: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                  ),
                  const SizedBox(height: 16),
                  const Text('Evidence:'),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: 'https://ipfs.io/ipfs/${report.evidenceLink}',
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error),
                      ),
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Status: ${report.verified ? "Verified" : "Pending"}'),
                  if (report.verified) ...[
                    const SizedBox(height: 8),
                    Text('Reward: ${report.reward} ETH'),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Date: ${DateTime.fromMillisecondsSinceEpoch(report.timestamp * 1000).toString()}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/colors.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _descriptionController = TextEditingController();
  File? _mediaFile;
  Position? _currentPosition;
  bool _isLoading = false;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await Permission.camera.request();
    await Permission.location.request();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error getting location')),
      );
    }
  }

  Future<void> _captureMedia(ImageSource source, bool isVideo) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? media = isVideo
          ? await picker.pickVideo(source: source)
          : await picker.pickImage(source: source);

      if (media?.path != null) {
        setState(() {
          _mediaFile = File(media!.path);
          _isVideo = isVideo;
        });
        await _getCurrentLocation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error capturing media')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Traffic Issue'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_mediaFile == null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMediaButton(
                              icon: Icons.camera_alt,
                              label: 'Take Photo',
                              onTap: () =>
                                  _captureMedia(ImageSource.camera, false),
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildMediaButton(
                              icon: Icons.videocam,
                              label: 'Record Video',
                              onTap: () =>
                                  _captureMedia(ImageSource.camera, true),
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    if (_isVideo)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: const Icon(
                          Icons.video_file,
                          size: 48,
                          color: Colors.white,
                        ),
                      )
                    else
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.file(
                          _mediaFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    TextButton.icon(
                      onPressed: () => setState(() => _mediaFile = null),
                      icon: const Icon(Icons.refresh, color: AppColors.orange),
                      label: Text(
                        'Retake ${_isVideo ? 'Video' : 'Photo'}',
                        style: const TextStyle(color: AppColors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Describe the Issue',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            if (_currentPosition != null) ...[
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLong: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading || _mediaFile == null
                  ? null
                  : () {
                      // TODO: Implement submission
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text(
                      'Submit Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

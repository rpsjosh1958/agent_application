import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../models/prospect.dart';

class SelfieStep extends StatefulWidget {
  final Prospect prospect;
  final Function(Prospect) onProspectUpdated;
  final Function(String, String) onShowAlert;

  const SelfieStep({
    super.key,
    required this.prospect,
    required this.onProspectUpdated,
    required this.onShowAlert,
  });

  @override
  State<SelfieStep> createState() => _SelfieStepState();
}

class _SelfieStepState extends State<SelfieStep> {
  String? _selfiePath;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _selfiePath = widget.prospect.selfiePath;
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use front camera for selfie
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      widget.onShowAlert('Error', 'Failed to initialize camera: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(
        directory.path,
        'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final XFile image = await _cameraController!.takePicture();
      await image.saveTo(imagePath);

      setState(() {
        _selfiePath = imagePath;
        _isCapturing = false;
      });

      // Update the prospect with the new image path
      final updatedProspect = widget.prospect.copyWith(
        selfiePath: _selfiePath,
      );
      widget.onProspectUpdated(updatedProspect);
    } catch (e) {
      setState(() {
        _isCapturing = false;
      });
      widget.onShowAlert('Error', 'Failed to capture image: $e');
    }
  }

  void _retakeSelfie() {
    setState(() {
      _selfiePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Take a Selfie',
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'MontserratRegular',
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 59, 69, 119),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Place the customer\'s face inside the circle and capture their face',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'MontserratLight',
              color: Color.fromARGB(255, 124, 124, 128),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 59, 69, 119),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 59, 69, 119),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _selfiePath != null
                    ? Image.file(
                        File(_selfiePath!),
                        fit: BoxFit.cover,
                        width: 250,
                        height: 250,
                      )
                    : _isCameraInitialized
                        ? CameraPreview(_cameraController!)
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          if (_selfiePath == null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCapturing ? null : _captureImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 59, 69, 119),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isCapturing)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _isCapturing ? 'Capturing...' : 'Capture Selfie',
                      style: const TextStyle(
                        fontFamily: 'MontserratLight',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _retakeSelfie,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 59, 69, 119),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Retake Selfie',
                      style: TextStyle(
                        fontFamily: 'MontserratLight',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

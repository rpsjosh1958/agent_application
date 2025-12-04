import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/prospect.dart';

class IdCardStep extends StatefulWidget {
  final Prospect prospect;
  final Function(Prospect) onProspectUpdated;
  final Function(String, String) onShowAlert;

  const IdCardStep({
    super.key,
    required this.prospect,
    required this.onProspectUpdated,
    required this.onShowAlert,
  });

  @override
  State<IdCardStep> createState() => _IdCardStepState();
}

class _IdCardStepState extends State<IdCardStep> {
  String? _idCardFrontPath;
  String? _idCardBackPath;

  @override
  void initState() {
    super.initState();
    _idCardFrontPath = widget.prospect.idCardFrontPath;
    _idCardBackPath = widget.prospect.idCardBackPath;
  }

  // pick image
  Future<void> _pickImage(bool isFront) async {
    _showImageSourceModal(isFront);
  }

  // show image source modal
  void _showImageSourceModal(bool isFront) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      builder: (context) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add a photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'MontserratRegular',
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 59, 69, 119),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Color.fromARGB(255, 145, 146, 148),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // camera option
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _handleImagePick(ImageSource.camera, isFront);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFA726),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Text(
                                'Capture from camera',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'MontserratLight',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // gallery option
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _handleImagePick(ImageSource.gallery, isFront);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    25,
                                    158,
                                    247,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.photo_library,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              const Text(
                                'Upload from gallery',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'MontserratLight',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // handle image pick
  Future<void> _handleImagePick(ImageSource source, bool isFront) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (isFront) {
            _idCardFrontPath = pickedFile.path;
          } else {
            _idCardBackPath = pickedFile.path;
          }
        });

        // update prospect with new image path
        final updatedProspect = widget.prospect.copyWith(
          idCardFrontPath: _idCardFrontPath,
          idCardBackPath: _idCardBackPath,
        );
        widget.onProspectUpdated(updatedProspect);
      }
    } catch (e) {
      widget.onShowAlert('Error', 'Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload ID Card',
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'MontserratRegular',
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 59, 69, 119),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Take a picture of the front and back sides of the ID',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'MontserratLight',
              color: Color.fromARGB(255, 124, 124, 128),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Upload front of ID',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildImageUploadBox(true), // true for front
          const SizedBox(height: 50),
          const Text(
            'Upload back of ID',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildImageUploadBox(false), // false for back
        ],
      ),
    );
  }

  // build image upload box
  Widget _buildImageUploadBox(bool isFront) {
    final imagePath = isFront ? _idCardFrontPath : _idCardBackPath;

    return GestureDetector(
      onTap: () => _pickImage(isFront),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(
          painter: DashedBorderPainter(),
          child: Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color.fromARGB(255, 231, 231, 231),
            ),
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(imagePath), fit: BoxFit.cover),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 24,
                        color: Color.fromARGB(255, 59, 69, 119),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add a photo',
                        style: TextStyle(
                          color: Color.fromARGB(255, 59, 69, 119),
                          fontFamily: 'MontserratRegular',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  // dashed rectangle box
  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final nextDistance = distance + dashWidth;
        final segment = pathMetric.extractPath(
          distance,
          nextDistance > pathMetric.length ? pathMetric.length : nextDistance,
        );
        canvas.drawPath(segment, paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

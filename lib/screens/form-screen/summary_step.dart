import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/prospect.dart';

class SummaryStep extends StatefulWidget {
  final Prospect prospect;
  final Function(int) onNavigateToStep;

  const SummaryStep({
    super.key,
    required this.prospect,
    required this.onNavigateToStep,
  });

  @override
  State<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends State<SummaryStep> {
  bool _isPersonalDetailsExpanded = false;
  bool _isContactDetailsExpanded = false;
  bool _isUploadIdCardExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Full Summary Details',
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'MontserratRegular',
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 59, 69, 119),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kindly go through the details and make sure all the details are correct.',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'MontserratLight',
              color: Color.fromARGB(255, 124, 124, 128),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          if (widget.prospect.selfiePath != null)
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.file(
                        File(widget.prospect.selfiePath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 59, 69, 119),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => widget.onNavigateToStep(1),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 50),

          // Personal Details Section
          _buildCollapsibleSection(
            title: 'Personal Details',
            isExpanded: _isPersonalDetailsExpanded,
            onToggle: () => setState(
              () => _isPersonalDetailsExpanded = !_isPersonalDetailsExpanded,
            ),
            onEdit: () => widget.onNavigateToStep(0),
            children: [
              _buildSummaryItem('First Name', widget.prospect.firstName),
              _buildSummaryItem('Last Name', widget.prospect.lastName),
              if (widget.prospect.otherNames != null &&
                  widget.prospect.otherNames!.isNotEmpty)
                _buildSummaryItem('Other Name(s)', widget.prospect.otherNames!),
              if (widget.prospect.dateOfBirth != null)
                _buildSummaryItem(
                  'Date of Birth',
                  '${widget.prospect.dateOfBirth!.day}/${widget.prospect.dateOfBirth!.month}/${widget.prospect.dateOfBirth!.year}',
                ),
              if (widget.prospect.nationality != null &&
                  widget.prospect.nationality!.isNotEmpty)
                _buildSummaryItem('Nationality', widget.prospect.nationality!),
            ],
          ),
          const SizedBox(height: 25),

          // Contact Details Section
          _buildCollapsibleSection(
            title: 'Contact Details',
            isExpanded: _isContactDetailsExpanded,
            onToggle: () => setState(
              () => _isContactDetailsExpanded = !_isContactDetailsExpanded,
            ),
            onEdit: () => widget.onNavigateToStep(0),
            children: [
              if (widget.prospect.primaryPhone != null &&
                  widget.prospect.primaryPhone!.isNotEmpty)
                _buildSummaryItem(
                  'Phone Number',
                  '${widget.prospect.primaryPhoneCountryCode ?? '+233'} ${widget.prospect.primaryPhone!}',
                ),
              if (widget.prospect.secondaryPhone != null &&
                  widget.prospect.secondaryPhone!.isNotEmpty)
                _buildSummaryItem(
                  'Secondary Phone',
                  '${widget.prospect.secondaryPhoneCountryCode ?? '+233'} ${widget.prospect.secondaryPhone!}',
                ),
              if (widget.prospect.ghanaPostGPS != null &&
                  widget.prospect.ghanaPostGPS!.isNotEmpty)
                _buildSummaryItem(
                  'Ghana Post GPS',
                  widget.prospect.ghanaPostGPS!,
                ),
              if (widget.prospect.residentialAddress != null &&
                  widget.prospect.residentialAddress!.isNotEmpty)
                _buildSummaryItem(
                  'Residential Address',
                  widget.prospect.residentialAddress!,
                ),
            ],
          ),
          const SizedBox(height: 25),

          // Upload ID Card Section
          _buildCollapsibleSection(
            title: 'Upload ID Card',
            isExpanded: _isUploadIdCardExpanded,
            onToggle: () => setState(
              () => _isUploadIdCardExpanded = !_isUploadIdCardExpanded,
            ),
            onEdit: () => widget.onNavigateToStep(2),
            children: [
              if (widget.prospect.idCardFrontPath != null)
                _buildImageSummaryItem('ID Card Front', widget.prospect.idCardFrontPath!),
              if (widget.prospect.idCardBackPath != null)
                _buildImageSummaryItem('ID Card Back', widget.prospect.idCardBackPath!),
              if (widget.prospect.idCardFrontPath == null && widget.prospect.idCardBackPath == null)
                _buildSummaryItem('Status', 'No files uploaded'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        // Header
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'MontserratLight',
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 59, 69, 119),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: const Color.fromARGB(255, 59, 69, 119),
                ),
              ],
            ),
          ),
        ),

        // Content
        if (isExpanded) ...[
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.isEmpty
                  ? children
                  : [
                      // First item with edit button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: children[0]),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: onEdit,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Color.fromARGB(255, 59, 69, 119),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Rest of the items
                      ...children.skip(1),
                    ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSummaryItem(String label, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(imagePath), fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}

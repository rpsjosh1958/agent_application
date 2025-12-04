import 'package:flutter/material.dart';
import 'dart:io';
import '../models/prospect.dart';

class ProspectDetailScreen extends StatefulWidget {
  final Prospect prospect;

  const ProspectDetailScreen({super.key, required this.prospect});

  @override
  State<ProspectDetailScreen> createState() => _ProspectDetailScreenState();
}

class _ProspectDetailScreenState extends State<ProspectDetailScreen> {
  bool _isPersonalDetailsExpanded = false;
  bool _isContactDetailsExpanded = false;
  bool _isUploadIdCardExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: Column(
              children: [
                // custom header
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 24,
                              color: Color.fromRGBO(64, 64, 64, 1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 1),
                      const Text(
                        'Customer Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'MontserratLight',
                          color: Color.fromRGBO(64, 64, 64, 1),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
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
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.file(
                                  File(widget.prospect.selfiePath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 50),

                        // personal details section
                        _buildCollapsibleSection(
                          title: 'Personal Details',
                          isExpanded: _isPersonalDetailsExpanded,
                          onToggle: () => setState(
                            () => _isPersonalDetailsExpanded =
                                !_isPersonalDetailsExpanded,
                          ),
                          children: [
                            _buildSummaryItem(
                              'First Name',
                              widget.prospect.firstName,
                            ),
                            _buildSummaryItem(
                              'Last Name',
                              widget.prospect.lastName,
                            ),
                            if (widget.prospect.otherNames?.isNotEmpty == true)
                              _buildSummaryItem(
                                'Other Name(s)',
                                widget.prospect.otherNames!,
                              ),
                            if (widget.prospect.dateOfBirth != null)
                              _buildSummaryItem(
                                'Date of Birth',
                                '${widget.prospect.dateOfBirth!.day}/${widget.prospect.dateOfBirth!.month}/${widget.prospect.dateOfBirth!.year}',
                              ),
                            if (widget.prospect.nationality?.isNotEmpty == true)
                              _buildSummaryItem(
                                'Nationality',
                                widget.prospect.nationality!,
                              ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // contact details section
                        _buildCollapsibleSection(
                          title: 'Contact Details',
                          isExpanded: _isContactDetailsExpanded,
                          onToggle: () => setState(
                            () => _isContactDetailsExpanded =
                                !_isContactDetailsExpanded,
                          ),
                          children: [
                            if (widget.prospect.primaryPhone?.isNotEmpty ==
                                true)
                              _buildSummaryItem(
                                'Phone Number',
                                '${widget.prospect.primaryPhoneCountryCode ?? ''} ${widget.prospect.primaryPhone}',
                              ),
                            if (widget.prospect.secondaryPhone?.isNotEmpty ==
                                true)
                              _buildSummaryItem(
                                'Secondary Phone',
                                '${widget.prospect.secondaryPhoneCountryCode ?? ''} ${widget.prospect.secondaryPhone}',
                              ),
                            if (widget.prospect.ghanaPostGPS?.isNotEmpty ==
                                true)
                              _buildSummaryItem(
                                'Ghana Post GPS',
                                widget.prospect.ghanaPostGPS!,
                              ),
                            if (widget
                                    .prospect
                                    .residentialAddress
                                    ?.isNotEmpty ==
                                true)
                              _buildSummaryItem(
                                'Residential Address',
                                widget.prospect.residentialAddress!,
                              ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // upload id card section
                        _buildCollapsibleSection(
                          title: 'Upload ID Card',
                          isExpanded: _isUploadIdCardExpanded,
                          onToggle: () => setState(
                            () => _isUploadIdCardExpanded =
                                !_isUploadIdCardExpanded,
                          ),
                          children: [
                            if (widget.prospect.idCardFrontPath != null) ...[
                              _buildImageSummaryItem(
                                'ID Card Front',
                                widget.prospect.idCardFrontPath!,
                              ),
                            ],
                            if (widget.prospect.idCardBackPath != null) ...[
                              _buildImageSummaryItem(
                                'ID Card Back',
                                widget.prospect.idCardBackPath!,
                              ),
                            ],
                            if (widget.prospect.idCardFrontPath == null &&
                                widget.prospect.idCardBackPath == null)
                              _buildSummaryItem('Status', 'No files uploaded'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // build collapsible section
  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        // header
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

        // content
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
              children: children,
            ),
          ),
        ],
      ],
    );
  }

  // build summary item
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

  // build image summary item
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

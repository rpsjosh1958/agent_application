import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/prospect.dart';
import '../services/storage_service.dart';

class FormScreen extends StatefulWidget {
  final Prospect? prospect;

  const FormScreen({super.key, this.prospect});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  int _currentStep = 0;
  late Prospect _prospect;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _otherNamesController = TextEditingController();
  final _primaryPhoneController = TextEditingController();
  final _secondaryPhoneController = TextEditingController();
  final _ghanaPostGPSController = TextEditingController();
  final _residentialAddressController = TextEditingController();

  // Validation state tracking
  final Set<String> _touchedFields = {};

  String _primaryCountryCode = '+233';
  String _secondaryCountryCode = '+233';
  DateTime? _dateOfBirth;
  String? _nationality;
  String? _selfiePath;
  String? _idCardPath;
  String? _idCardFrontPath;
  String? _idCardBackPath;

  bool _isPersonalDetailsExpanded = false;
  bool _isContactDetailsExpanded = false;
  bool _isUploadIdCardExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.prospect != null) {
      _initializeFromProspect(widget.prospect!);
    } else {
      _prospect = Prospect(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: '',
        lastName: '',
        onboardedDate: DateTime.now(),
      );
    }
  }

  void _initializeFromProspect(Prospect prospect) {
    _prospect = prospect;
    _currentStep = prospect.currentStep;
    _firstNameController.text = prospect.firstName;
    _lastNameController.text = prospect.lastName;
    _otherNamesController.text = prospect.otherNames ?? '';
    _dateOfBirth = prospect.dateOfBirth;
    _nationality = prospect.nationality;
    _primaryPhoneController.text = prospect.primaryPhone ?? '';
    _primaryCountryCode = prospect.primaryPhoneCountryCode ?? '+233';
    _secondaryPhoneController.text = prospect.secondaryPhone ?? '';
    _secondaryCountryCode = prospect.secondaryPhoneCountryCode ?? '+233';
    _ghanaPostGPSController.text = prospect.ghanaPostGPS ?? '';
    _residentialAddressController.text = prospect.residentialAddress ?? '';
    _selfiePath = prospect.selfiePath;
    _idCardPath = prospect.idCardPath;
    _idCardFrontPath = prospect.idCardPath;
    _idCardBackPath = prospect.idCardPath;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _otherNamesController.dispose();
    _primaryPhoneController.dispose();
    _secondaryPhoneController.dispose();
    _ghanaPostGPSController.dispose();
    _residentialAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    // Validate current step before proceeding
    if (_currentStep == 0) {
      // Mark all required fields as touched to show errors
      setState(() {
        _touchedFields.addAll([
          'first_name',
          'last_name',
          'date_of_birth',
          'nationality',
          'phone_number',
        ]);
      });

      // Check if step is valid
      if (!_isStepValid()) {
        return; // Don't proceed if validation fails
      }
    }

    _updateProspectFromForm();

    if (_currentStep < 3) {
      // Changed from 2 to 3
      await StorageService.saveCurrentForm(_prospect);
      setState(() {
        _currentStep++;
        _prospect = _prospect.copyWith(currentStep: _currentStep);
      });
    } else {
      await _finishForm();
    }
  }

  Future<void> _saveAndExit() async {
    _updateProspectFromForm();

    // Save to both current form AND main prospects list
    await StorageService.saveProspect(_prospect);
    await StorageService.saveCurrentForm(_prospect);

    if (mounted) {
      _showAlertAndNavigateHome(
        'Saved',
        'Form saved successfully. You can resume later.',
      );
    }
  }

  void _showAlertAndNavigateHome(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the alert
              Navigator.of(context).pop(); // Navigate back to home
            },
          ),
        ],
      ),
    );
  }

  Future<void> _finishForm() async {
    _updateProspectFromForm();

    // Force complete status when finishing the form
    final updatedProspect = _prospect.copyWith(
      isComplete: true, // Always mark as complete when finishing
    );

    try {
      await StorageService.saveProspect(updatedProspect);
      await StorageService.clearCurrentForm();
      if (mounted) {
        _showAlertAndNavigateHome(
          'Success',
          'Customer onboarded successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        _showAlert('Error', 'Failed to save prospect: $e');
      }
    }
  }

  void _updateProspectFromForm() {
    _prospect = _prospect.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      otherNames: _otherNamesController.text.isEmpty
          ? null
          : _otherNamesController.text,
      dateOfBirth: _dateOfBirth,
      nationality: _nationality,
      primaryPhone: _primaryPhoneController.text.isEmpty
          ? null
          : _primaryPhoneController.text,
      primaryPhoneCountryCode: _primaryCountryCode,
      secondaryPhone: _secondaryPhoneController.text.isEmpty
          ? null
          : _secondaryPhoneController.text,
      secondaryPhoneCountryCode: _secondaryCountryCode,
      ghanaPostGPS: _ghanaPostGPSController.text.isEmpty
          ? null
          : _ghanaPostGPSController.text,
      residentialAddress: _residentialAddressController.text.isEmpty
          ? null
          : _residentialAddressController.text,
      selfiePath: _selfiePath,
      idCardPath: _idCardFrontPath,
      currentStep: _currentStep,
    );
  }

  Future<void> _pickImage(bool isSelfie, [bool isFront = true]) async {
    if (isSelfie) {
      // For selfie, directly use camera (no modal)
      await _handleImagePick(ImageSource.camera, isSelfie, isFront);
    } else {
      // For ID card, show modal with options
      _showImageSourceModal(isSelfie, isFront);
    }
  }

  void _showImageSourceModal(bool isSelfie, bool isFront) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 220, // Reduced height since we removed the cancel button
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add a photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'MontserratLight',
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 59, 69, 119),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(), minimumSize: Size(0, 0),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 24,
                      color: Color.fromARGB(255, 59, 69, 119),
                    ),
                  ),
                ],
              ),
            ),

            // Options
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera option
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CupertinoButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _handleImagePick(
                          ImageSource.camera,
                          isSelfie,
                          isFront,
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.camera,
                            size: 24,
                            color: const Color.fromARGB(255, 59, 69, 119),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Capture from Camera',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'MontserratLight',
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 59, 69, 119),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Gallery option
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CupertinoButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _handleImagePick(
                          ImageSource.gallery,
                          isSelfie,
                          isFront,
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.photo,
                            size: 24,
                            color: const Color.fromARGB(255, 59, 69, 119),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Upload from Gallery',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'MontserratLight',
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 59, 69, 119),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImagePick(
    ImageSource source,
    bool isSelfie,
    bool isFront,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (isSelfie) {
            _selfiePath = pickedFile.path;
          } else {
            if (isFront) {
              _idCardFrontPath = pickedFile.path;
            } else {
              _idCardBackPath = pickedFile.path;
            }
          }
        });

        // Update the prospect with the new image path
        _updateProspectFromForm();

        // Save to both current form AND main prospects list
        await StorageService.saveProspect(_prospect);
        await StorageService.saveCurrentForm(_prospect);
      }
    } catch (e) {
      _showAlert('Error', 'Failed to pick image: $e');
    }
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  bool _isStepValid() {
    switch (_currentStep) {
      case 0: // Personal and Contact Details combined
        return _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty &&
            _dateOfBirth != null &&
            _nationality != null &&
            _nationality!.isNotEmpty &&
            _primaryPhoneController.text.isNotEmpty;
      case 1: // Selfie
        return _selfiePath != null;
      case 2: // ID Card Upload - make this optional for now
        return true; // You can change this to require ID card if needed
      case 3: // Summary
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.back,
                          size: 24,
                          color: Color.fromRGBO(64, 64, 64, 1),
                        ),
                        onPressed: () {
                          if (_currentStep > 0) {
                            // Go to previous step in the form
                            setState(() {
                              _currentStep--;
                              _prospect = _prospect.copyWith(
                                currentStep: _currentStep,
                              );
                            });
                          } else {
                            // If on first step, go back to home with confirmation if there are unsaved changes
                            _confirmExit();
                          }
                        },
                      ),
                      const SizedBox(width: 1),
                      const Text(
                        'Registration',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  child: Stack(
                    children: [
                      // Background track
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            59,
                            69,
                            119,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Progress fill
                      Container(
                        height: 4,
                        width:
                            (MediaQuery.of(context).size.width - 20) *
                            ((_currentStep + 1) / 4), // Changed from 3 to 4
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 59, 69, 119),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildCurrentStep()),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmExit() {
    // Check if there are any unsaved changes
    final hasUnsavedChanges =
        _firstNameController.text.isNotEmpty ||
        _lastNameController.text.isNotEmpty ||
        _primaryPhoneController.text.isNotEmpty ||
        _selfiePath != null ||
        _idCardPath != null;

    if (!hasUnsavedChanges) {
      // No unsaved changes, just go back
      Navigator.of(context).pop();
      return;
    }

    // Show confirmation dialog for unsaved changes
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Do you want to save before exiting?',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Discard'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Navigate home
            },
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save & Exit'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await _saveAndExit(); // This will now properly navigate home
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalAndContactDetailsStep();
      case 1:
        return _buildIdentificationStep();
      case 2:
        return _buildIdCardStep();
      case 3:
        return _buildSummaryStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalAndContactDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'MontserratRegular',
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 59, 69, 119),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fill in your customer\'s personal information in this section',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'MontserratLight',
              color: Color.fromARGB(255, 124, 124, 128),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            placeholder: 'First name',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            placeholder: 'Last name',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _otherNamesController,
            label: 'Other Name(s)',
            placeholder: 'Other name(s)',
          ),
          const SizedBox(height: 16),
          _buildDateOfBirthField(),
          const SizedBox(height: 16),
          _buildNationalityField(),
          const SizedBox(height: 32),
          const Text(
            'Contact Details',
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'MontserratRegular',
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 59, 69, 119),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fill in your customer\'s contact information in this section',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'MontserratLight',
              color: Color.fromARGB(255, 124, 124, 128),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          _buildPhoneField(
            controller: _primaryPhoneController,
            label: 'Phone Number',
            countryCode: _primaryCountryCode,
            onCountryChanged: (code) =>
                setState(() => _primaryCountryCode = code),
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildPhoneField(
            controller: _secondaryPhoneController,
            label: 'Secondary Phone Number',
            countryCode: _secondaryCountryCode,
            onCountryChanged: (code) =>
                setState(() => _secondaryCountryCode = code),
            isOptional: true,
          ),
          const SizedBox(height: 16),
          _buildGhanaPostField(
            controller: _ghanaPostGPSController,
            label: 'Ghana Post Address',
            placeholder: 'Search address to select',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _residentialAddressController,
            label: 'Residential Address',
            placeholder: '',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildIdentificationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Always show selfie step when on step 1, regardless of whether selfie is taken
          _buildSelfieStep(),
        ],
      ),
    );
  }

  Widget _buildSelfieStep() {
    return Column(
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
              color: _selfiePath != null
                  ? Colors.transparent
                  : const Color.fromARGB(255, 59, 69, 119),
              shape: BoxShape.circle,
              
                  
            ),
            child: _selfiePath != null
                ? ClipOval(
                    child: Image.file(
                      File(_selfiePath!),
                      fit: BoxFit.cover,
                      width: 250,
                      height: 250,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            color: const Color.fromARGB(255, 59, 69, 119),
            borderRadius: BorderRadius.circular(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selfiePath != null
                      ? CupertinoIcons.refresh
                      : CupertinoIcons.camera,
                  color: CupertinoColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _selfiePath != null ? 'Retake Selfie' : 'Take Selfie',
                  style: const TextStyle(
                    fontFamily: 'MontserratLight',
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
            onPressed: () => _pickImage(true),
          ),
        ),
      ],
    );
  }

  Widget _buildIdCardStep() {
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

  Widget _buildImageUploadBox(bool isFront) {
    final imagePath = isFront ? _idCardFrontPath : _idCardBackPath;

    return GestureDetector(
      onTap: () => _pickImage(false, isFront),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
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
                    children: const [
                      Icon(
                        CupertinoIcons.camera,
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

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Full Summary Details',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kindly go through the details and make sure all the details are correct.',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'MontserratLight',
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),

          if (_selfiePath != null)
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.file(File(_selfiePath!), fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 59, 69, 119),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CupertinoColors.white,
                        width: 2,
                      ),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _navigateToStep(1),
                      child: const Icon(
                        CupertinoIcons.camera,
                        size: 18,
                        color: CupertinoColors.white,
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
            onEdit: () => _navigateToStep(0),
            children: [
              _buildSummaryItem('First Name', _firstNameController.text),
              _buildSummaryItem('Last Name', _lastNameController.text),
              if (_otherNamesController.text.isNotEmpty)
                _buildSummaryItem('Other Name(s)', _otherNamesController.text),
              if (_dateOfBirth != null)
                _buildSummaryItem(
                  'Date of Birth',
                  '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}',
                ),
              if (_nationality != null && _nationality!.isNotEmpty)
                _buildSummaryItem('Nationality', _nationality!),
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
            onEdit: () => _navigateToStep(0),
            children: [
              if (_primaryPhoneController.text.isNotEmpty)
                _buildSummaryItem(
                  'Phone Number',
                  '$_primaryCountryCode ${_primaryPhoneController.text}',
                ),
              if (_secondaryPhoneController.text.isNotEmpty)
                _buildSummaryItem(
                  'Secondary Phone',
                  '$_secondaryCountryCode ${_secondaryPhoneController.text}',
                ),
              if (_ghanaPostGPSController.text.isNotEmpty)
                _buildSummaryItem(
                  'Ghana Post GPS',
                  _ghanaPostGPSController.text,
                ),
              if (_residentialAddressController.text.isNotEmpty)
                _buildSummaryItem(
                  'Residential Address',
                  _residentialAddressController.text,
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
            onEdit: () => _navigateToStep(2),
            children: [
              if (_idCardFrontPath != null)
                _buildImageSummaryItem('ID Card Front', _idCardFrontPath!),
              if (_idCardBackPath != null)
                _buildImageSummaryItem('ID Card Back', _idCardBackPath!),
              if (_idCardFrontPath == null && _idCardBackPath == null)
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
              border: Border.all(
                color: CupertinoColors.systemGrey4,
                width: 1,
              ),
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
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
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
              color: CupertinoColors.systemGrey6,
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
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: onEdit,
                            minimumSize: Size.zero,
                            child: const Icon(
                              CupertinoIcons.pencil,
                              size: 16,
                              color: Color.fromARGB(255, 59, 69, 119),
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
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
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
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CupertinoColors.systemGrey4, width: 1),
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

  void _navigateToStep(int step) {
    setState(() {
      _currentStep = step;
      _prospect = _prospect.copyWith(currentStep: _currentStep);
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool isRequired = false,
    int maxLines = 1,
  }) {
    final fieldKey = label.toLowerCase().replaceAll(' ', '_');
    final hasError =
        isRequired &&
        controller.text.isEmpty &&
        _touchedFields.contains(fieldKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'MontserratLight',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              setState(() {
                _touchedFields.add(fieldKey);
              });
            }
          },
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            maxLines: maxLines,
            style: const TextStyle(
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w400,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey4,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          ),
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'This field is required',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneField({
    required TextEditingController controller,
    required String label,
    required String countryCode,
    required Function(String) onCountryChanged,
    bool isRequired = false,
    bool isOptional = false,
  }) {
    final fieldKey = label.toLowerCase().replaceAll(' ', '_');
    final hasError =
        isRequired &&
        controller.text.isEmpty &&
        _touchedFields.contains(fieldKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
            if (isOptional)
              const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'MontserratRegular',
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.systemGrey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              setState(() {
                _touchedFields.add(fieldKey);
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey4,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // ... rest of your phone field code remains the same ...
                GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => Container(
                        height: 300,
                        color: CupertinoColors.white,
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CupertinoButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  const Text(
                                    'Select Country',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'MontserratLight',
                                    ),
                                  ),
                                  CupertinoButton(
                                    child: const Text('Done'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: CupertinoScrollbar(
                                child: ListView(
                                  children: [
                                    _buildCountryOption(
                                      '🇬🇭',
                                      '+233',
                                      'Ghana',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇳🇬',
                                      '+234',
                                      'Nigeria',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇺🇸',
                                      '+1',
                                      'United States',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇬🇧',
                                      '+44',
                                      'United Kingdom',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇰🇪',
                                      '+254',
                                      'Kenya',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇿🇦',
                                      '+27',
                                      'South Africa',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇨🇮',
                                      '+225',
                                      'Ivory Coast',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇸🇳',
                                      '+221',
                                      'Senegal',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇨🇦',
                                      '+1',
                                      'Canada',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                    _buildCountryOption(
                                      '🇫🇷',
                                      '+33',
                                      'France',
                                      countryCode,
                                      onCountryChanged,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          countryCode == '+233'
                              ? '🇬🇭'
                              : countryCode == '+234'
                              ? '🇳🇬'
                              : countryCode == '+1'
                              ? '🇺🇸'
                              : countryCode == '+44'
                              ? '🇬🇧'
                              : countryCode == '+254'
                              ? '🇰🇪'
                              : countryCode == '+27'
                              ? '🇿🇦'
                              : countryCode == '+225'
                              ? '🇨🇮'
                              : countryCode == '+221'
                              ? '🇸🇳'
                              : countryCode == '+33'
                              ? '🇫🇷'
                              : '🇬🇭',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          countryCode,
                          style: const TextStyle(
                            fontFamily: 'MontserratLight',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.chevron_down,
                          size: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: CupertinoColors.systemGrey4,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CupertinoTextField(
                    controller: controller,
                    placeholder: 'Phone number',
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontFamily: 'MontserratLight',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const BoxDecoration(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'This field is required',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGhanaPostField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool isRequired = false,
  }) {
    final fieldKey = label.toLowerCase().replaceAll(' ', '_');
    final hasError =
        isRequired &&
        controller.text.isEmpty &&
        _touchedFields.contains(fieldKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'MontserratLight',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              setState(() {
                _touchedFields.add(fieldKey);
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey4,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: controller,
                    placeholder: placeholder,
                    style: const TextStyle(
                      fontFamily: 'MontserratLight',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const BoxDecoration(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    CupertinoIcons.search,
                    color: Color.fromRGBO(119, 119, 119, 1),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'This field is required',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    final hasError = _dateOfBirth == null && _touchedFields.contains('date_of_birth');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'MontserratLight',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus && _dateOfBirth == null) {
              setState(() {
                _touchedFields.add('date_of_birth');
              });
            }
          },
          child: GestureDetector(
            onTap: () async {
              final DateTime? picked = await showCupertinoModalPopup<DateTime>(
              context: context,
              builder: (BuildContext context) {
                DateTime tempPickedDate = _dateOfBirth ?? DateTime.now();
                return Container(
                  height: 300,
                  color: CupertinoColors.white,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Text(
                              'Select Date of Birth',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'MontserratLight',
                              ),
                            ),
                            CupertinoButton(
                              child: const Text('Done'),
                              onPressed: () => Navigator.of(context).pop(tempPickedDate),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          initialDateTime: tempPickedDate,
                          maximumDate: DateTime.now(),
                          minimumDate: DateTime(1900),
                          onDateTimeChanged: (DateTime newDate) {
                            tempPickedDate = newDate;
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
            
              if (picked != null) {
                setState(() {
                  _dateOfBirth = picked;
                });
              } else {
                // User cancelled without selecting, mark as touched
                setState(() {
                  _touchedFields.add('date_of_birth');
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasError
                      ? CupertinoColors.systemRed
                      : CupertinoColors.systemGrey4,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Select date of birth',
                    style: TextStyle(
                      fontFamily: 'MontserratLight',
                      fontWeight: FontWeight.w400,
                      color: _dateOfBirth != null
                          ? CupertinoColors.black
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.calendar,
                    color: Color.fromRGBO(119, 119, 119, 1),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'This field is required',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNationalityField() {
    final hasError = (_nationality == null || _nationality!.isEmpty) && 
                      _touchedFields.contains('nationality');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nationality',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'MontserratLight',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus && (_nationality == null || _nationality!.isEmpty)) {
              setState(() {
                _touchedFields.add('nationality');
              });
            }
          },
          child: GestureDetector(
            onTap: () {
              final nationalities = [
                'Ghanaian', 'Nigerian', 'American', 'British', 'Kenyan',
                'South African', 'Ivorian', 'Senegalese', 'Canadian', 'French',
                'German', 'Indian', 'Chinese', 'Brazilian', 'Mexican', 'Japanese',
                'South Korean', 'Australian', 'New Zealander', 'Italian', 'Spanish',
                'Portuguese', 'Dutch', 'Belgian', 'Swiss', 'Swedish', 'Norwegian',
                'Danish', 'Finnish', 'Polish', 'Czech', 'Austrian', 'Hungarian',
              ];
              
              showCupertinoModalPopup(
                context: context,
                builder: (context) => Container(
                  height: 400,
                  color: CupertinoColors.white,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const Text(
                              'Select Nationality',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'MontserratLight',
                              ),
                            ),
                            CupertinoButton(
                              child: const Text('Done'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: CupertinoScrollbar(
                          child: ListView.builder(
                            itemCount: nationalities.length,
                            itemBuilder: (context, index) {
                              final nationality = nationalities[index];
                              final isSelected = _nationality == nationality;
                              
                              return CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _nationality = nationality;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        nationality,
                                        style: const TextStyle(
                                          fontFamily: 'MontserratLight',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(
                                        CupertinoIcons.check_mark,
                                        color: Color.fromARGB(255, 59, 69, 119),
                                        size: 20,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError
                    ? CupertinoColors.systemRed
                    : CupertinoColors.systemGrey4,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _nationality ?? 'Select nationality',
                  style: TextStyle(
                    fontFamily: 'MontserratLight',
                    fontWeight: FontWeight.w400,
                    color: _nationality != null
                        ? CupertinoColors.black
                        : CupertinoColors.systemGrey2,
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  color: Color.fromRGBO(119, 119, 119, 1),
                  size: 20,
                ),
              ],
            ),
          ),
          ),
        ),
        if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'This field is required',
              style: TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: const Color.fromARGB(255, 59, 69, 119),
              borderRadius: BorderRadius.circular(30),
              onPressed: _saveAndContinue,
              child: Text(
                _currentStep == 3 ? 'Finish' : 'Save and Continue',
                style: const TextStyle(
                  fontFamily: 'MontserratLight',
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
          // Only show Save and Exit button if NOT on summary step
          if (_currentStep != 3) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 59, 69, 119),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: CupertinoButton(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(30),
                  onPressed: _saveAndExit,
                  child: const Text(
                    'Save and Exit',
                    style: TextStyle(
                      color: Color.fromARGB(255, 59, 69, 119),
                      fontFamily: 'MontserratLight',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountryOption(
    String flag,
    String code,
    String name,
    String currentCode,
    Function(String) onChanged,
  ) {
    final isSelected = currentCode == code;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            code,
            style: const TextStyle(
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (isSelected)
            const Icon(
              CupertinoIcons.check_mark,
              color: Color.fromARGB(255, 59, 69, 119),
            ),
        ],
      ),
      onPressed: () {
        onChanged(code);
        Navigator.of(context).pop();
      },
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 59, 69, 119)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;

    final path = Path();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    path.addRRect(rect);

    _drawDashedPath(canvas, path, paint, dashWidth, dashSpace);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance.clamp(0.0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance = nextDistance + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

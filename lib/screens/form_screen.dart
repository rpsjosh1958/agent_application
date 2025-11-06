import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/prospect.dart';
import '../services/storage_service.dart';
import 'form-screen/personal_contact_step.dart';
import 'form-screen/selfie_step.dart';
import 'form-screen/id_card_step.dart';
import 'form-screen/summary_step.dart';

class FormScreen extends StatefulWidget {
  final Prospect? prospect;

  const FormScreen({super.key, this.prospect});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  int _currentStep = 0;
  late Prospect _prospect;

  // Validation state tracking
  final Set<String> _touchedFields = {};

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
  }

  void _onProspectUpdated(Prospect updatedProspect) {
    setState(() {
      _prospect = updatedProspect;
    });
  }

  void _onFieldTouched(String fieldKey) {
    setState(() {
      _touchedFields.add(fieldKey);
    });
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

    if (_currentStep < 3) {
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
        return _prospect.firstName.isNotEmpty &&
            _prospect.lastName.isNotEmpty &&
            _prospect.dateOfBirth != null &&
            _prospect.nationality != null &&
            _prospect.nationality!.isNotEmpty &&
            _prospect.primaryPhone != null &&
            _prospect.primaryPhone!.isNotEmpty;
      case 1: // Selfie
        return _prospect.selfiePath != null;
      case 2: // ID Card Upload - make this optional for now
        return true; // You can change this to require ID card if needed
      case 3: // Summary
        return true;
      default:
        return false;
    }
  }

  void _navigateToStep(int step) {
    setState(() {
      _currentStep = step;
      _prospect = _prospect.copyWith(currentStep: _currentStep);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 20,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios,
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
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Progress fill
                      Container(
                        height: 4,
                        width: (MediaQuery.of(context).size.width - 20) *
                            ((_currentStep + 1) / 4),
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
    final hasUnsavedChanges = _prospect.firstName.isNotEmpty ||
        _prospect.lastName.isNotEmpty ||
        _prospect.primaryPhone != null ||
        _prospect.selfiePath != null ||
        _prospect.idCardFrontPath != null ||
        _prospect.idCardBackPath != null;

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
        return PersonalContactStep(
          prospect: _prospect,
          onProspectUpdated: _onProspectUpdated,
          touchedFields: _touchedFields,
          onFieldTouched: _onFieldTouched,
        );
      case 1:
        return SelfieStep(
          prospect: _prospect,
          onProspectUpdated: _onProspectUpdated,
          onShowAlert: _showAlert,
        );
      case 2:
        return IdCardStep(
          prospect: _prospect,
          onProspectUpdated: _onProspectUpdated,
          onShowAlert: _showAlert,
        );
      case 3:
        return SummaryStep(
          prospect: _prospect,
          onNavigateToStep: _navigateToStep,
        );
      default:
        return Container();
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 59, 69, 119),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentStep == 3 ? 'Finish' : 'Save and Continue',
                style: const TextStyle(
                  fontFamily: 'MontserratLight',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // Only show Save and Exit button if NOT on summary step
          if (_currentStep != 3) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _saveAndExit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 59, 69, 119),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 59, 69, 119),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save and Exit',
                  style: TextStyle(
                    fontFamily: 'MontserratLight',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

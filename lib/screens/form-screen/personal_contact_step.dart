import 'package:flutter/material.dart';
import '../../models/prospect.dart';

class PersonalContactStep extends StatefulWidget {
  final Prospect prospect;
  final Function(Prospect) onProspectUpdated;
  final Set<String> touchedFields;
  final Function(String) onFieldTouched;

  const PersonalContactStep({
    super.key,
    required this.prospect,
    required this.onProspectUpdated,
    required this.touchedFields,
    required this.onFieldTouched,
  });

  @override
  State<PersonalContactStep> createState() => _PersonalContactStepState();
}

class _PersonalContactStepState extends State<PersonalContactStep> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _otherNamesController;
  late TextEditingController _primaryPhoneController;
  late TextEditingController _secondaryPhoneController;
  late TextEditingController _ghanaPostGPSController;
  late TextEditingController _residentialAddressController;

  late String _primaryCountryCode;
  late String _secondaryCountryCode;
  DateTime? _dateOfBirth;
  String? _nationality;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(
      text: widget.prospect.firstName,
    );
    _lastNameController = TextEditingController(text: widget.prospect.lastName);
    _otherNamesController = TextEditingController(
      text: widget.prospect.otherNames ?? '',
    );
    _primaryPhoneController = TextEditingController(
      text: widget.prospect.primaryPhone ?? '',
    );
    _secondaryPhoneController = TextEditingController(
      text: widget.prospect.secondaryPhone ?? '',
    );
    _ghanaPostGPSController = TextEditingController(
      text: widget.prospect.ghanaPostGPS ?? '',
    );
    _residentialAddressController = TextEditingController(
      text: widget.prospect.residentialAddress ?? '',
    );

    _primaryCountryCode = widget.prospect.primaryPhoneCountryCode ?? '+233';
    _secondaryCountryCode = widget.prospect.secondaryPhoneCountryCode ?? '+233';
    _dateOfBirth = widget.prospect.dateOfBirth;
    _nationality = widget.prospect.nationality;

    // add listeners to update prospect
    _firstNameController.addListener(_updateProspect);
    _lastNameController.addListener(_updateProspect);
    _otherNamesController.addListener(_updateProspect);
    _primaryPhoneController.addListener(_updateProspect);
    _secondaryPhoneController.addListener(_updateProspect);
    _ghanaPostGPSController.addListener(_updateProspect);
    _residentialAddressController.addListener(_updateProspect);
  }

  // update prospect
  void _updateProspect() {
    final updatedProspect = widget.prospect.copyWith(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      otherNames: _otherNamesController.text.isEmpty
          ? null
          : _otherNamesController.text,
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
      dateOfBirth: _dateOfBirth,
      nationality: _nationality,
    );
    widget.onProspectUpdated(updatedProspect);
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

  @override
  Widget build(BuildContext context) {
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
            onCountryChanged: (code) {
              setState(() => _primaryCountryCode = code);
              _updateProspect();
            },
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildPhoneField(
            controller: _secondaryPhoneController,
            label: 'Secondary Phone Number',
            countryCode: _secondaryCountryCode,
            onCountryChanged: (code) {
              setState(() => _secondaryCountryCode = code);
              _updateProspect();
            },
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

  // build text field
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
        widget.touchedFields.contains(fieldKey);

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
              widget.onFieldTouched(fieldKey);
            }
          },
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 59, 69, 119),
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
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
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  // build phone field
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
        widget.touchedFields.contains(fieldKey);

    final countryCodes = [
      {'code': '+233', 'flag': '🇬🇭', 'name': 'Ghana'},
      {'code': '+234', 'flag': '🇳🇬', 'name': 'Nigeria'},
      {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
      {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
      {'code': '+254', 'flag': '🇰🇪', 'name': 'Kenya'},
      {'code': '+27', 'flag': '🇿🇦', 'name': 'South Africa'},
      {'code': '+225', 'flag': '🇨🇮', 'name': 'Ivory Coast'},
      {'code': '+221', 'flag': '🇸🇳', 'name': 'Senegal'},
      {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
    ];

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
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              widget.onFieldTouched(fieldKey);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: countryCode,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Colors.grey,
                      ),
                      items: countryCodes.map((country) {
                        return DropdownMenuItem<String>(
                          value: country['code'],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                country['flag']!,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                country['code']!,
                                style: const TextStyle(
                                  fontFamily: 'MontserratLight',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          onCountryChanged(value);
                        }
                      },
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: const Color(0xFFE5E7EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Phone number',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 20,
                      ),
                      hintStyle: TextStyle(
                        fontFamily: 'MontserratLight',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontFamily: 'MontserratLight',
                      fontWeight: FontWeight.w400,
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
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  // build ghana post field
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
        widget.touchedFields.contains(fieldKey);

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
              widget.onFieldTouched(fieldKey);
            }
          },
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'MontserratLight',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
              suffixIcon: const Icon(
                Icons.search,
                color: Color.fromRGBO(119, 119, 119, 1),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 59, 69, 119),
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
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
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  // build date of birth field
  Widget _buildDateOfBirthField() {
    final hasError =
        _dateOfBirth == null && widget.touchedFields.contains('date_of_birth');

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
              widget.onFieldTouched('date_of_birth');
            }
          },
          child: GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate:
                    _dateOfBirth ??
                    DateTime.now().subtract(const Duration(days: 6570)),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: const Color.fromARGB(255, 59, 69, 119),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (picked != null) {
                setState(() {
                  _dateOfBirth = picked;
                });
                _updateProspect();
              } else {
                widget.onFieldTouched('date_of_birth');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasError ? Colors.red : const Color(0xFFE5E7EB),
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
                      fontSize: 16,
                      color: _dateOfBirth != null
                          ? Colors.black
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
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
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  // build nationality field
  Widget _buildNationalityField() {
    final hasError =
        (_nationality == null || _nationality!.isEmpty) &&
        widget.touchedFields.contains('nationality');

    final nationalities = [
      'Ghanaian',
      'Nigerian',
      'American',
      'British',
      'Kenyan',
      'South African',
      'Ivorian',
      'Senegalese',
      'Canadian',
      'French',
      'German',
      'Indian',
      'Chinese',
      'Brazilian',
      'Mexican',
      'Japanese',
      'South Korean',
      'Australian',
      'New Zealander',
      'Italian',
      'Spanish',
      'Portuguese',
      'Dutch',
      'Belgian',
      'Swiss',
      'Swedish',
      'Norwegian',
      'Danish',
      'Finnish',
      'Polish',
      'Czech',
      'Austrian',
      'Hungarian',
    ];

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
              widget.onFieldTouched('nationality');
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError ? Colors.red : const Color(0xFFE5E7EB),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _nationality,
                hint: const Text(
                  'Select nationality',
                  style: TextStyle(
                    fontFamily: 'MontserratLight',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color.fromRGBO(119, 119, 119, 1),
                  size: 20,
                ),
                style: const TextStyle(
                  fontFamily: 'MontserratLight',
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 16,
                ),
                dropdownColor: Colors.white,
                items: nationalities.map((String nationality) {
                  return DropdownMenuItem<String>(
                    value: nationality,
                    child: Text(
                      nationality,
                      style: const TextStyle(
                        fontFamily: 'MontserratLight',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _nationality = value;
                  });
                  _updateProspect();
                },
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
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'MontserratLight',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}

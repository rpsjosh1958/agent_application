import 'dart:convert';

class Prospect {
  final String id;
  final String firstName;
  final String lastName;
  final String? otherNames;
  final DateTime? dateOfBirth;
  final String? nationality;
  final String? primaryPhone;
  final String? primaryPhoneCountryCode;
  final String? secondaryPhone;
  final String? secondaryPhoneCountryCode;
  final String? ghanaPostGPS;
  final String? residentialAddress;
  final String? selfiePath;
  final String? idCardFrontPath;
  final String? idCardBackPath;
  final DateTime onboardedDate;
  final bool isComplete;
  final int currentStep;

  Prospect({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.otherNames,
    this.dateOfBirth,
    this.nationality,
    this.primaryPhone,
    this.primaryPhoneCountryCode,
    this.secondaryPhone,
    this.secondaryPhoneCountryCode,
    this.ghanaPostGPS,
    this.residentialAddress,
    this.selfiePath,
    this.idCardFrontPath,
    this.idCardBackPath,
    required this.onboardedDate,
    this.isComplete = false,
    this.currentStep = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'otherNames': otherNames,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'nationality': nationality,
      'primaryPhone': primaryPhone,
      'primaryPhoneCountryCode': primaryPhoneCountryCode,
      'secondaryPhone': secondaryPhone,
      'secondaryPhoneCountryCode': secondaryPhoneCountryCode,
      'ghanaPostGPS': ghanaPostGPS,
      'residentialAddress': residentialAddress,
      'selfiePath': selfiePath,
      'idCardFrontPath': idCardFrontPath,
      'idCardBackPath': idCardBackPath,
      'onboardedDate': onboardedDate.millisecondsSinceEpoch,
      'isComplete': isComplete,
      'currentStep': currentStep,
    };
  }

  factory Prospect.fromMap(Map<String, dynamic> map) {
    return Prospect(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      otherNames: map['otherNames'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'])
          : null,
      nationality: map['nationality'],
      primaryPhone: map['primaryPhone'],
      primaryPhoneCountryCode: map['primaryPhoneCountryCode'],
      secondaryPhone: map['secondaryPhone'],
      secondaryPhoneCountryCode: map['secondaryPhoneCountryCode'],
      ghanaPostGPS: map['ghanaPostGPS'],
      residentialAddress: map['residentialAddress'],
      selfiePath: map['selfiePath'],
      idCardFrontPath: map['idCardFrontPath'],
      idCardBackPath: map['idCardBackPath'],
      onboardedDate: DateTime.fromMillisecondsSinceEpoch(map['onboardedDate']),
      isComplete: map['isComplete'] ?? false,
      currentStep: map['currentStep'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Prospect.fromJson(String source) => Prospect.fromMap(json.decode(source));

  Prospect copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? otherNames,
    DateTime? dateOfBirth,
    String? nationality,
    String? primaryPhone,
    String? primaryPhoneCountryCode,
    String? secondaryPhone,
    String? secondaryPhoneCountryCode,
    String? ghanaPostGPS,
    String? residentialAddress,
    String? selfiePath,
    String? idCardFrontPath,
    String? idCardBackPath,
    DateTime? onboardedDate,
    bool? isComplete,
    int? currentStep,
  }) {
    return Prospect(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      otherNames: otherNames ?? this.otherNames,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      primaryPhone: primaryPhone ?? this.primaryPhone,
      primaryPhoneCountryCode: primaryPhoneCountryCode ?? this.primaryPhoneCountryCode,
      secondaryPhone: secondaryPhone ?? this.secondaryPhone,
      secondaryPhoneCountryCode: secondaryPhoneCountryCode ?? this.secondaryPhoneCountryCode,
      ghanaPostGPS: ghanaPostGPS ?? this.ghanaPostGPS,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      selfiePath: selfiePath ?? this.selfiePath,
      idCardFrontPath: idCardFrontPath ?? this.idCardFrontPath,
      idCardBackPath: idCardBackPath ?? this.idCardBackPath,
      onboardedDate: onboardedDate ?? this.onboardedDate,
      isComplete: isComplete ?? this.isComplete,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  String get fullName {
    String name = '$firstName $lastName';
    if (otherNames != null && otherNames!.isNotEmpty) {
      name = '$firstName $otherNames $lastName';
    }
    return name;
  }

  bool get hasRequiredFields {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        dateOfBirth != null &&
        nationality != null &&
        nationality!.isNotEmpty &&
        primaryPhone != null &&
        primaryPhone!.isNotEmpty &&
        selfiePath != null &&
        selfiePath!.isNotEmpty &&
        idCardFrontPath != null &&
        idCardFrontPath!.isNotEmpty;
  }
}

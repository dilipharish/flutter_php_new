enum OrganName {
  leftKidney,
  rightKidney,
  eyes,
  heart,
  liver,
  blood,
}

extension OrganNameExtension on OrganName {
  static String getValue(OrganName organ) {
    switch (organ) {
      case OrganName.leftKidney:
        return 'Left_Kidney';
      case OrganName.rightKidney:
        return 'Right_Kidney';
      case OrganName.eyes:
        return 'Eyes';
      case OrganName.heart:
        return 'Heart';
      case OrganName.liver:
        return 'Liver';
      case OrganName.blood:
        return 'Blood';
      default:
        return '';
    }
  }

  static OrganName? getOrganNameFromString(String value) {
    switch (value) {
      case 'Left_Kidney':
        return OrganName.leftKidney;
      case 'Right_Kidney':
        return OrganName.rightKidney;
      case 'Eyes':
        return OrganName.eyes;
      case 'Heart':
        return OrganName.heart;
      case 'Liver':
        return OrganName.liver;
      case 'Blood':
        return OrganName.blood;
      default:
        return null;
    }
  }
}

enum BloodGroup {
  APositive,
  ANegative,
  BPositive,
  BNegative,
  OPositive,
  ONegative,
  ABPositive,
  ABNegative,
}

extension BloodGroupExtension on BloodGroup {
  String get value {
    switch (this) {
      case BloodGroup.APositive:
        return 'A+';
      case BloodGroup.ANegative:
        return 'A-';
      case BloodGroup.BPositive:
        return 'B+';
      case BloodGroup.BNegative:
        return 'B-';
      case BloodGroup.OPositive:
        return 'O+';
      case BloodGroup.ONegative:
        return 'O-';
      case BloodGroup.ABPositive:
        return 'AB+';
      case BloodGroup.ABNegative:
        return 'AB-';
      default:
        return '';
    }
  }

  static BloodGroup? getBloodGroupFromString(String value) {
    switch (value) {
      case 'A+':
        return BloodGroup.APositive;
      case 'A-':
        return BloodGroup.ANegative;
      case 'B+':
        return BloodGroup.BPositive;
      case 'B-':
        return BloodGroup.BNegative;
      case 'O+':
        return BloodGroup.OPositive;
      case 'O-':
        return BloodGroup.ONegative;
      case 'AB+':
        return BloodGroup.ABPositive;
      case 'AB-':
        return BloodGroup.ABNegative;
      default:
        return null;
    }
  }
}

enum AntibodyScreening { low, medium, high }

enum HIVStatus { negative, positive }

enum HepatitisBStatus { negative, positive }

enum HepatitisCStatus { negative, positive }

enum DonorStatus {
  live_donor,
  cardiac_death,
  brain_death,
}

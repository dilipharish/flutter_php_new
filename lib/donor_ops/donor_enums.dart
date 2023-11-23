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

  static OrganName? fromString(String organName) {
    switch (organName) {
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

  static BloodGroup? fromString(String organBloodGroup) {
    switch (organBloodGroup) {
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

  static BloodGroup getValue(String bloodGroupString) {
    switch (bloodGroupString) {
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
        throw Exception('Invalid blood group string: $bloodGroupString');
    }
  }
}

enum AntibodyScreening { low, medium, high }

extension AntibodyScreeningExtension on AntibodyScreening {
  static AntibodyScreening? fromString(String value) {
    switch (value) {
      case 'low':
        return AntibodyScreening.low;
      case 'medium':
        return AntibodyScreening.medium;
      case 'high':
        return AntibodyScreening.high;
      default:
        return null;
    }
  }
}

enum HIVStatus { negative, positive }

extension HIVStatusExtension on HIVStatus {
  static HIVStatus? fromString(String value) {
    switch (value) {
      case 'negative':
        return HIVStatus.negative;
      case 'positive':
        return HIVStatus.positive;
      default:
        return null;
    }
  }
}

enum HepatitisBStatus { negative, positive }

extension HepatitisBStatusExtension on HepatitisBStatus {
  static HepatitisBStatus? fromString(String value) {
    switch (value) {
      case 'negative':
        return HepatitisBStatus.negative;
      case 'positive':
        return HepatitisBStatus.positive;
      default:
        return null;
    }
  }
}

enum HepatitisCStatus { negative, positive }

extension HepatitisCStatusExtension on HepatitisCStatus {
  static HepatitisCStatus? fromString(String value) {
    switch (value) {
      case 'negative':
        return HepatitisCStatus.negative;
      case 'positive':
        return HepatitisCStatus.positive;
      default:
        return null;
    }
  }
}

enum DonorStatus { live_donor, cardiac_death, brain_death }

extension DonorStatusExtension on DonorStatus {
  static DonorStatus? fromString(String value) {
    switch (value) {
      case 'live_donor':
        return DonorStatus.live_donor;
      case 'cardiac_death':
        return DonorStatus.cardiac_death;
      case 'brain_death':
        return DonorStatus.brain_death;
      default:
        return null;
    }
  }
}

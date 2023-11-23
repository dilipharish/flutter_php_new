class Donore {
  final int donorId;
  final int duid;
  final int doid;
  final DateTime dateOfDonation;
  final String organDetails;
  final String organName;
  final int organAge;
  final String organBloodGroup;
  final bool organAvailability;
  final String ohla;
  final String donorStatus;
  final int branchId;
  final String branchName;

  Donore({
    required this.donorId,
    required this.duid,
    required this.doid,
    required this.dateOfDonation,
    required this.organDetails,
    required this.organName,
    required this.organAge,
    required this.organBloodGroup,
    required this.organAvailability,
    required this.ohla,
    required this.donorStatus,
    required this.branchId,
    required this.branchName,
  });
}

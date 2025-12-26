class UserModel {
  final String uid;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profession;
  final String? role;
  final double rating;
  final int completedJobs;
  final double monthlyEarnings;
  final int activeJobs;

  UserModel({
    required this.uid,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profession,
    this.role,
    this.rating = 4.8,
    this.completedJobs = 0,
    this.monthlyEarnings = 0,
    this.activeJobs = 0,
  });

  String get fullName => '$firstName $lastName';
}

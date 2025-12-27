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
  final double walletBalance;
  final List<String> skills;
  final String experience;
  final String whatsappNumber;
  final String? avatarUrl;
  final String? address;
  final double hourlyRate;

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
    this.walletBalance = 0.0,
    this.skills = const [],
    this.experience = '',
    this.whatsappNumber = '',
    this.avatarUrl,
    this.address,
    this.hourlyRate = 1200,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      password: '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profession: map['profession'] ?? '',
      role: map['role'],
      rating: (map['rating'] ?? 4.8).toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      monthlyEarnings: (map['monthlyEarnings'] ?? 0).toDouble(),
      activeJobs: map['activeJobs'] ?? 0,
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      skills: List<String>.from(map['skills'] ?? []),
      experience: map['experience'] ?? '',
      whatsappNumber: map['whatsappNumber'] ?? '',
      avatarUrl: map['avatarUrl'],
      address: map['address'],
      hourlyRate: (map['hourlyRate'] ?? 1200).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profession': profession,
      'role': role,
      'rating': rating,
      'completedJobs': completedJobs,
      'monthlyEarnings': monthlyEarnings,
      'activeJobs': activeJobs,
      'walletBalance': walletBalance,
      'skills': skills,
      'experience': experience,
      'whatsappNumber': whatsappNumber,
      'avatarUrl': avatarUrl,
      'address': address,
      'hourlyRate': hourlyRate,
    };
  }
}

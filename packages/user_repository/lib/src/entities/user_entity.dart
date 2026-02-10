class UserEntity {
  String userId;
  String name;
  String email;
  double currentAllowance;
  DateTime? lastAllowanceDate;
  int goalsAchieved;

  UserEntity(
      {required this.userId,
      required this.name,
      required this.email,
      this.currentAllowance = 0.0,
      this.lastAllowanceDate,
      required this.goalsAchieved});

  Map<String, Object?> toJSON() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'currentAllowance': currentAllowance,
      'lastAllowanceDate': lastAllowanceDate,
      'goalsAchieved': goalsAchieved
    };
  }

  static UserEntity fromJSON(Map<String, dynamic> doc) {
    return UserEntity(
        userId: doc['userId'],
        name: doc['name'],
        email: doc['email'],
        currentAllowance: doc['currentAllowance'],
        lastAllowanceDate: doc['lastAllowanceDate'],
        goalsAchieved: doc['goalsAchieved']);
  }
}

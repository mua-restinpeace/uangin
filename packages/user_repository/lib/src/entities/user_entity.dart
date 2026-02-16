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
      'lastAllowanceDate': lastAllowanceDate?.millisecondsSinceEpoch,
      'goalsAchieved': goalsAchieved
    };
  }

  static UserEntity fromJSON(Map<String, dynamic> doc) {
    return UserEntity(
        userId: (doc['userId'] as String),
        name: (doc['name'] as String),
        email: (doc['email'] as String),
        currentAllowance: (doc['currentAllowance'] as num?)?.toDouble() ?? 0.0,
        lastAllowanceDate: doc['latestAllowanceDate'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                doc['lastAllowanceDate'] as int)
            : null,
        goalsAchieved: (doc['goalsAchieved'] as num?)?.toInt() ?? 0);
  }
}

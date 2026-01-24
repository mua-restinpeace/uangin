class UserEntity {
  String userId;
  String name;
  String email;
  int goalsAchieved;

  UserEntity(
      {required this.userId,
      required this.name,
      required this.email,
      required this.goalsAchieved});

  Map<String, Object?> toJSON() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'goalsAchieved': goalsAchieved
    };
  }

  static UserEntity fromJSON(Map<String, dynamic> doc) {
    return UserEntity(
        userId: doc['userId'],
        name: doc['name'],
        email: doc['email'],
        goalsAchieved: doc['goalsAchieved']);
  }
}

import 'package:equatable/equatable.dart';
import 'package:user_repository/src/entities/user_entity.dart';

class MyUser extends Equatable {
  String userId;
  String name;
  String email;
  int goalsAchieved;

  MyUser(
      {required this.userId,
      required this.email,
      required this.name,
      required this.goalsAchieved});

  static final empty =
      MyUser(userId: '', email: '', name: '', goalsAchieved: 0);

  bool get isEmpty => this == MyUser.empty;
  bool get isNotEmpty => !isEmpty;

  UserEntity toEnity() {
    return UserEntity(
        userId: userId, email: email, name: name, goalsAchieved: goalsAchieved);
  }

  static MyUser fromEntity(UserEntity entity) {
    return MyUser(
        userId: entity.userId,
        email: entity.email,
        name: entity.name,
        goalsAchieved: entity.goalsAchieved);
  }

  @override
  String toString() {
    return 'User: $userId, $name, $email, $goalsAchieved';
  }

  @override
  List<Object?> get props => [userId, name, email, goalsAchieved];
}

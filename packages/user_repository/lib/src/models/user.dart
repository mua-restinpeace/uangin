import 'package:equatable/equatable.dart';
import 'package:user_repository/src/entities/user_entity.dart';

class MyUser extends Equatable {
  String userId;
  String name;
  String email;
  double currentAllowance;
  double totalSaving;
  DateTime? lastAllowanceDate;
  int goalsAchieved;

  MyUser(
      {required this.userId,
      required this.email,
      required this.name,
      this.currentAllowance = 0.0,
      this.totalSaving = 0.0,
      this.lastAllowanceDate,
      required this.goalsAchieved});

  static final empty =
      MyUser(userId: '', email: '', name: '', currentAllowance: 0.0, totalSaving: 0.0, lastAllowanceDate: null, goalsAchieved: 0);

  bool get isEmpty => this == MyUser.empty;
  bool get isNotEmpty => !isEmpty;

  UserEntity toEnity() {
    return UserEntity(
        userId: userId, email: email, name: name, currentAllowance: currentAllowance, totalSaving: totalSaving, lastAllowanceDate: lastAllowanceDate, goalsAchieved: goalsAchieved);
  }

  static MyUser fromEntity(UserEntity entity) {
    return MyUser(
        userId: entity.userId,
        email: entity.email,
        name: entity.name,
        currentAllowance: entity.currentAllowance,
        totalSaving: entity.totalSaving,
        lastAllowanceDate: entity.lastAllowanceDate,
        goalsAchieved: entity.goalsAchieved);
  }

  @override
  String toString() {
    return 'User: $userId, $name, $email, $currentAllowance, $totalSaving, $lastAllowanceDate, $goalsAchieved';
  }

  @override
  List<Object?> get props => [userId, name, email, currentAllowance, totalSaving, lastAllowanceDate, goalsAchieved];
}

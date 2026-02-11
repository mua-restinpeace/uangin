import 'package:allowance_repository/src/entities/saving_goal_entity.dart';
import 'package:equatable/equatable.dart';

class SavingGoals extends Equatable {
  String goalId;
  String userId;
  String name;
  String? description;
  String icon;
  double targetAmount;
  double currentAmount;
  DateTime? createdDate;
  DateTime? targetDate;
  bool isComplete;
  DateTime? completedDate;

  SavingGoals({
    required this.goalId,
    required this.userId,
    required this.name,
    this.description,
    required this.icon,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdDate,
    this.targetDate,
    this.isComplete = false,
    this.completedDate,
  });

  static final empty = SavingGoals(
      goalId: '',
      userId: '',
      name: '',
      icon: '',
      targetAmount: 0,
      createdDate: null,
      description: '',
      currentAmount: 0,
      targetDate: null,
      isComplete: false,
      completedDate: null);

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;
  double get remainingAmount => targetAmount - currentAmount;
  double get percentageComplete =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0.0;

  SavingGoalEntity toEntity() {
    return SavingGoalEntity(
        goalId: goalId,
        userId: userId,
        name: name,
        icon: icon,
        targetAmount: targetAmount,
        createdDate: createdDate,
        description: description,
        currentAmount: currentAmount,
        targetDate: targetDate,
        isComplete: isComplete,
        completedDate: completedDate);
  }

  static SavingGoals fromEntity(SavingGoalEntity entity) {
    return SavingGoals(
        goalId: entity.goalId,
        userId: entity.userId,
        name: entity.name,
        icon: entity.icon,
        targetAmount: entity.targetAmount,
        createdDate: entity.createdDate,
        description: entity.description,
        currentAmount: entity.currentAmount,
        targetDate: entity.targetDate,
        isComplete: entity.isComplete,
        completedDate: entity.completedDate);
  }

  SavingGoals copyWith(
      String? goalId,
      String? userId,
      String? name,
      String? icon,
      double? targetAmount,
      double? currentAmount,
      String? description,
      DateTime? createdDate,
      DateTime? targetDate,
      DateTime? completedDate,
      bool? isComplete) {
    return SavingGoals(
        goalId: goalId ?? this.goalId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        createdDate: createdDate ?? this.createdDate,
        targetDate: targetDate ?? this.targetDate,
        completedDate: completedDate ?? this.completedDate,
        isComplete: isComplete ?? this.isComplete);
  }

  @override
  String toString() {
    return 'SavingGoal: $goalId, $userId, $name, $description, $icon, $targetAmount, $currentAmount, $createdDate, $targetDate, $isComplete, $completedDate';
  }

  @override
  List<Object?> get props => [
        goalId,
        userId,
        name,
        description,
        icon,
        targetAmount,
        currentAmount,
        createdDate,
        targetDate,
        isComplete,
        completedDate
      ];
}

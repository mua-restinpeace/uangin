

import 'package:allowance_repository/src/entities/budget_entity.dart';
import 'package:equatable/equatable.dart';

class Budgets extends Equatable {
  String budgetId;
  String userId;
  String name;
  String icon;
  String color;
  double allocatedAmount;
  double spentAmount;
  DateTime? periodStart;
  DateTime? periodEnd;
  bool isActive;

  Budgets(
      {required this.budgetId,
      required this.userId,
      required this.name,
      required this.icon,
      required this.color,
      required this.allocatedAmount,
      this.spentAmount = 0.0,
      required this.periodStart,
      required this.periodEnd,
      this.isActive = true});

  static final empty = Budgets(
      budgetId: '',
      userId: '',
      name: '',
      icon: '',
      color: '',
      allocatedAmount: 0,
      periodStart: null,
      periodEnd: null,
      isActive: false);

  bool get isEmpty => this == empty;
  bool get isNotEmpty => !isEmpty;

  double get remainingAmount => allocatedAmount - spentAmount;
  double get percentageUsed =>
      allocatedAmount > 0 ? (spentAmount / allocatedAmount) * 100 : 0.0;

  BudgetEntity toEnity() {
    return BudgetEntity(
        budgetId: budgetId,
        userId: userId,
        name: name,
        icon: icon,
        color: color,
        allocatedAmount: allocatedAmount,
        spentAmount: spentAmount,
        isActive: isActive,
        periodStart: periodStart!,
        periodEnd: periodEnd!);
  }

  static Budgets fromEntity(BudgetEntity entity) {
    return Budgets(
        budgetId: entity.budgetId,
        userId: entity.userId,
        name: entity.name,
        icon: entity.icon,
        color: entity.color,
        allocatedAmount: entity.allocatedAmount,
        spentAmount: entity.spentAmount,
        periodStart: entity.periodStart,
        periodEnd: entity.periodEnd,
        isActive: entity.isActive);
  }

  Budgets copyWith({
      String? budgetId,
      String? userId,
      String? name,
      String? icon,
      String? color,
      double? allocatedAmount,
      double? spentAmount,
      DateTime? periodStart,
      DateTime? periodEnd,
      bool? isActive}) {
    return Budgets(
        budgetId: budgetId ?? this.budgetId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        allocatedAmount: allocatedAmount ?? this.allocatedAmount,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd);
  }

  @override
  String toString() {
    return 'Budget: $budgetId, $userId, $name, $icon, $color, $allocatedAmount, $spentAmount, $periodStart, $periodEnd, $isActive';
  }

  @override
  List<Object?> get props => [
        budgetId,
        userId,
        name,
        icon,
        color,
        allocatedAmount,
        spentAmount,
        periodStart,
        periodEnd,
        isActive
      ];
}

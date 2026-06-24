import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetEntity {
  String budgetId;
  String userId;
  String name;
  String icon;
  String color;
  double allocatedAmount;
  double spentAmount;
  bool isActive;
  DateTime periodStart;
  DateTime periodEnd;

  BudgetEntity(
      {required this.budgetId,
      required this.userId,
      required this.name,
      required this.icon,
      required this.color,
      required this.allocatedAmount,
      this.spentAmount = 0.0,
      this.isActive = true,
      required this.periodStart,
      required this.periodEnd});

  Map<String, Object?> toJSON() {
    return {
      'budgetId': budgetId,
      'userId': userId,
      'name': name,
      'icon': icon,
      'color': color,
      'allocatedAmount': allocatedAmount,
      'spentAmount': spentAmount,
      'isActive': isActive,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
    };
  }

  static BudgetEntity fromJSON(Map<String, dynamic> doc) {
    return BudgetEntity(
        budgetId: doc['budgetId'] as String,
        userId: doc['userId'] as String,
        name: doc['name'] as String,
        icon: doc['icon'] as String,
        color: doc['color'] as String,
        allocatedAmount: (doc['allocatedAmount'] as num).toDouble(),
        spentAmount: (doc['spentAmount'] as num).toDouble(),
        periodStart: (doc['periodStart'] as Timestamp).toDate(),
        periodEnd: (doc['periodEnd'] as Timestamp).toDate(),
        isActive: doc['isActive'] as bool? ?? true);
  }
}

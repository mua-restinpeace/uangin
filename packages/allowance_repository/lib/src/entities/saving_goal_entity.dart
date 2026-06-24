import 'package:cloud_firestore/cloud_firestore.dart';

class SavingGoalEntity {
  String goalId;
  String userId;
  String name;
  String? description;
  String? icon;
  double targetAmount;
  double currentAmount;
  DateTime? createdDate;
  DateTime? targetDate;
  bool isComplete;
  DateTime? completedDate;

  SavingGoalEntity({
    required this.goalId,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdDate,
    this.targetDate,
    this.isComplete = false,
    this.completedDate,
  });

  Map<String, Object?> toJSON() {
    return {
      'goalId': goalId,
      'userId': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdDate':
          createdDate != null ? Timestamp.fromDate(createdDate!) : null,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'isComplete': isComplete,
      'completedDate':
          completedDate != null ? Timestamp.fromDate(completedDate!) : null,
    };
  }

  static SavingGoalEntity fromJSON(Map<String, dynamic> doc) {
    return SavingGoalEntity(
        goalId: doc['goalId'] as String,
        userId: doc['userId'] as String,
        name: doc['name'] as String,
        description: doc['description'] as String?,
        icon: doc['icon'] as String?,
        targetAmount: (doc['targetAmount'] as num).toDouble(),
        createdDate: _dateFromFirebase(doc['createdDate']),
        currentAmount: (doc['currentAmount'] as num?)?.toDouble() ?? 0.0,
        targetDate: _dateFromFirebase(doc['targetDate']),
        isComplete: doc['isComplete'] as bool? ?? false,
        completedDate: _dateFromFirebase(doc['completedDate']));
  }

  static DateTime? _dateFromFirebase(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

    throw FormatException('Invalid date value: $value');
  }
}

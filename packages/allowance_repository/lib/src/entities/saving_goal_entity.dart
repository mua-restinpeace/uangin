class SavingGoalEntity {
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

  SavingGoalEntity({
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

  Map<String, Object?> toJSON() {
    return {
      'goalId': goalId,
      'userId': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdDate': createdDate,
      'targetDate': targetDate,
      'isComplete': isComplete,
      'completedDate': completedDate,
    };
  }

  static SavingGoalEntity fromJSON(Map<String, dynamic> doc) {
    return SavingGoalEntity(
        goalId: doc['goalId'] as String,
        userId: doc['userId'] as String,
        name: doc['name'] as String,
        description: doc['description'] as String?,
        icon: doc['icon'] as String,
        targetAmount: (doc['targetAmount'] as num).toDouble(),
        createdDate: DateTime.fromMillisecondsSinceEpoch(doc['createdDate'] as int),
        currentAmount: (doc['currentAmount'] as num?)?.toDouble() ?? 0.0,
        targetDate: doc['targetDate'] ? DateTime.fromMillisecondsSinceEpoch(doc['targetDate'] as int) : null,
        isComplete: doc['isComplete'] as bool? ?? false,
        completedDate: doc['completedDate'] ? DateTime.fromMillisecondsSinceEpoch(doc['completedDate'] as int) : null);
  }
}

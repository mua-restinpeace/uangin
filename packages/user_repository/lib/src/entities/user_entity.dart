import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  String userId;
  String name;
  String email;
  String photoUrl;
  double currentAllowance;
  double totalSaving;
  DateTime? lastAllowanceDate;
  int goalsAchieved;

  UserEntity(
      {required this.userId,
      required this.name,
      required this.email,
      this.photoUrl = '',
      this.currentAllowance = 0.0,
      this.totalSaving = 0.0,
      this.lastAllowanceDate,
      required this.goalsAchieved});

  Map<String, Object?> toJSON() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'currentAllowance': currentAllowance,
      'totalSaving': totalSaving,
      'lastAllowanceDate': lastAllowanceDate != null
          ? Timestamp.fromDate(lastAllowanceDate!)
          : null,
      'goalsAchieved': goalsAchieved
    };
  }

  static UserEntity fromJSON(Map<String, dynamic> doc) {
    return UserEntity(
        userId: (doc['userId'] as String),
        name: (doc['name'] as String),
        email: (doc['email'] as String),
        photoUrl: (doc['photoUrl'] as String) ?? "",
        currentAllowance: (doc['currentAllowance'] as num?)?.toDouble() ?? 0.0,
        totalSaving: (doc['totalSaving'] as num?)?.toDouble() ?? 0.0,
        lastAllowanceDate: _dateFromFirebase(doc['lastAllowanceDate']),
        goalsAchieved: (doc['goalsAchieved'] as num?)?.toInt() ?? 0);
  }

  static DateTime? _dateFromFirebase(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

    throw FormatException('Invalid date value: $value');
  }
}

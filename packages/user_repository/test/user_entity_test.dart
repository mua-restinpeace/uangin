import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  group('UserEntity', () {
    test('toJSON converts UserEntity to Firestore-safe map', () {
      final date = DateTime(2026, 6, 25);

      final entity = UserEntity(
        userId: 'user-1',
        name: 'Muarif',
        email: 'muarif@mail.com',
        photoUrl: 'https://example.com/photo.png',
        currentAllowance: 150000,
        totalSaving: 50000,
        lastAllowanceDate: date,
        goalsAchieved: 3,
      );

      final json = entity.toJSON();

      expect(json['userId'], 'user-1');
      expect(json['name'], 'Muarif');
      expect(json['email'], 'muarif@mail.com');
      expect(json['photoUrl'], 'https://example.com/photo.png');
      expect(json['currentAllowance'], 150000);
      expect(json['totalSaving'], 50000);
      expect(json['goalsAchieved'], 3);

      expect(json['lastAllowanceDate'], isA<Timestamp>());

      final savedDate = json['lastAllowanceDate'] as Timestamp;
      expect(
        savedDate.toDate().millisecondsSinceEpoch,
        date.millisecondsSinceEpoch,
      );
    });

    test('toJSON stores null lastAllowanceDate when date is null', () {
      final entity = UserEntity(
        userId: 'user-1',
        name: 'Muarif',
        email: 'muarif@mail.com',
        photoUrl: '',
        currentAllowance: 0,
        totalSaving: 0,
        lastAllowanceDate: null,
        goalsAchieved: 0,
      );

      final json = entity.toJSON();

      expect(json['lastAllowanceDate'], isNull);
    });

    test('fromJSON converts Firestore Timestamp to UserEntity DateTime', () {
      final date = DateTime(2026, 6, 25);

      final entity = UserEntity.fromJSON({
        'userId': 'user-1',
        'name': 'Muarif',
        'email': 'muarif@mail.com',
        'photoUrl': 'https://example.com/photo.png',
        'currentAllowance': 150000,
        'totalSaving': 50000,
        'lastAllowanceDate': Timestamp.fromDate(date),
        'goalsAchieved': 3,
      });

      expect(entity.userId, 'user-1');
      expect(entity.name, 'Muarif');
      expect(entity.email, 'muarif@mail.com');
      expect(entity.photoUrl, 'https://example.com/photo.png');
      expect(entity.currentAllowance, 150000);
      expect(entity.totalSaving, 50000);
      expect(entity.goalsAchieved, 3);

      expect(entity.lastAllowanceDate, isNotNull);
      expect(
        entity.lastAllowanceDate!.millisecondsSinceEpoch,
        date.millisecondsSinceEpoch,
      );
    });

    test('fromJSON accepts DateTime fallback for lastAllowanceDate', () {
      final date = DateTime(2026, 6, 25);

      final entity = UserEntity.fromJSON({
        'userId': 'user-1',
        'name': 'Muarif',
        'email': 'muarif@mail.com',
        'photoUrl': '',
        'currentAllowance': 150000,
        'totalSaving': 50000,
        'lastAllowanceDate': date,
        'goalsAchieved': 3,
      });

      expect(entity.lastAllowanceDate, date);
    });

    test('fromJSON accepts int milliseconds fallback for lastAllowanceDate',
        () {
      final date = DateTime(2026, 6, 25);

      final entity = UserEntity.fromJSON({
        'userId': 'user-1',
        'name': 'Muarif',
        'email': 'muarif@mail.com',
        'photoUrl': '',
        'currentAllowance': 150000,
        'totalSaving': 50000,
        'lastAllowanceDate': date.millisecondsSinceEpoch,
        'goalsAchieved': 3,
      });

      expect(
        entity.lastAllowanceDate!.millisecondsSinceEpoch,
        date.millisecondsSinceEpoch,
      );
    });

    test('fromJSON uses safe defaults for optional finance fields', () {
      final entity = UserEntity.fromJSON({
        'userId': 'user-1',
        'name': 'Muarif',
        'email': 'muarif@mail.com',
        'photoUrl': '',
      });

      expect(entity.currentAllowance, 0.0);
      expect(entity.totalSaving, 0.0);
      expect(entity.lastAllowanceDate, isNull);
      expect(entity.goalsAchieved, 0);
    });

    test('fromJSON throws FormatException for invalid lastAllowanceDate type',
        () {
      expect(
        () => UserEntity.fromJSON({
          'userId': 'user-1',
          'name': 'Muarif',
          'email': 'muarif@mail.com',
          'photoUrl': '',
          'lastAllowanceDate': 'invalid-date',
          'goalsAchieved': 0,
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('MyUser', () {
    test('toEntity converts MyUser to UserEntity', () {
      final date = DateTime(2026, 6, 25);

      final user = MyUser(
        userId: 'user-1',
        name: 'Muarif',
        email: 'muarif@mail.com',
        photoUrl: 'https://example.com/photo.png',
        currentAllowance: 200000,
        totalSaving: 75000,
        lastAllowanceDate: date,
        goalsAchieved: 2,
      );

      final entity = user.toEnity();

      expect(entity.userId, user.userId);
      expect(entity.name, user.name);
      expect(entity.email, user.email);
      expect(entity.photoUrl, user.photoUrl);
      expect(entity.currentAllowance, user.currentAllowance);
      expect(entity.totalSaving, user.totalSaving);
      expect(entity.lastAllowanceDate, user.lastAllowanceDate);
      expect(entity.goalsAchieved, user.goalsAchieved);
    });

    test('fromEntity converts UserEntity to MyUser', () {
      final date = DateTime(2026, 6, 25);

      final entity = UserEntity(
        userId: 'user-1',
        name: 'Muarif',
        email: 'muarif@mail.com',
        photoUrl: 'https://example.com/photo.png',
        currentAllowance: 200000,
        totalSaving: 75000,
        lastAllowanceDate: date,
        goalsAchieved: 2,
      );

      final user = MyUser.fromEntity(entity);

      expect(user.userId, entity.userId);
      expect(user.name, entity.name);
      expect(user.email, entity.email);
      expect(user.photoUrl, entity.photoUrl);
      expect(user.currentAllowance, entity.currentAllowance);
      expect(user.totalSaving, entity.totalSaving);
      expect(user.lastAllowanceDate, entity.lastAllowanceDate);
      expect(user.goalsAchieved, entity.goalsAchieved);
    });

    test('empty user is empty', () {
      expect(MyUser.empty.isEmpty, true);
      expect(MyUser.empty.isNotEmpty, false);
    });
  });
}

import 'package:allowance_repository/allowance_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAllowanceRepo - saving goals', () {
    late FakeFirebaseFirestore firestore;
    late FirebaseAllowanceRepo repo;

    const userId = 'test-user-id';

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repo = FirebaseAllowanceRepo(firestore: firestore);
    });

    test('createdSavingGoal stores saving goal with isComplete field',
        () async {
      await repo.createdSavingGoal(
        userId: userId,
        name: 'Buy laptop',
        description: 'For college and coding',
        icon: 'laptop',
        targetAmount: 5000000,
      );

      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('savingGoals')
          .get();

      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();

      expect(data['name'], 'Buy laptop');
      expect(data['targetAmount'], 5000000);
      expect(data['currentAmount'], 0.0);

      // This confirms the field your create method actually writes.
      expect(data['isComplete'], false);

      // This confirms the field your stream currently queries does not exist.
      expect(data.containsKey('isCompleted'), false);
    });

    test(
      'getActiveSavingGoals should return newly created incomplete saving goal',
      () async {
        await repo.createdSavingGoal(
          userId: userId,
          name: 'Emergency fund',
          description: 'Backup money',
          icon: 'wallet',
          targetAmount: 1000000,
        );

        final goals = await repo.getActiveSavingGoals(userId).first;

        expect(goals.length, 1);
        expect(goals.first.name, 'Emergency fund');
        expect(goals.first.isComplete, false);
      },
    );
  });
}

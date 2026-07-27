import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirebaseUserRepo', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late FirebaseUserRepo repo;

    setUp(() {
      firestore = FakeFirebaseFirestore();

      auth = MockFirebaseAuth();

      repo = FirebaseUserRepo(
        firebaseAuth: auth,
        firestore: firestore,
      );

      SharedPreferences.setMockInitialValues({});
    });

    group('onboarding', () {
      test('hasOnBoardingComplete returns false by default', () async {
        final result = await repo.hasOnBoardingComplete();

        expect(result, false);
      });

      test('setOnBoardingComplete stores onboarding flag as true', () async {
        await repo.setOnBoardingComplete();

        final result = await repo.hasOnBoardingComplete();

        expect(result, true);
      });
    });

    group('auth', () {
      test('signUp creates Firebase user and returns MyUser with generated uid',
          () async {
        final inputUser = MyUser(
          userId: '',
          name: 'Muarif',
          email: 'muarif@mail.com',
          goalsAchieved: 0,
        );

        final signedUpUser = await repo.signUp(
          inputUser,
          'Password123!',
        );

        expect(signedUpUser.userId, isNotEmpty);
        expect(signedUpUser.name, 'Muarif');
        expect(signedUpUser.email, 'muarif@mail.com');
        expect(signedUpUser.goalsAchieved, 0);
      });

      test('setUserData saves user profile to Firestore', () async {
        final user = MyUser(
          userId: 'user-1',
          name: 'Muarif',
          email: 'muarif@mail.com',
          currentAllowance: 100000,
          goalsAchieved: 2,
        );

        await repo.setUserData(user);

        final doc = await firestore.collection('users').doc('user-1').get();

        expect(doc.exists, true);

        final data = doc.data()!;

        expect(data['userId'], 'user-1');
        expect(data['name'], 'Muarif');
        expect(data['email'], 'muarif@mail.com');
        expect(data['currentAllowance'], 100000);
        expect(data['goalsAchieved'], 2);
      });

      test('user stream emits null when not authenticated', () async {
        final result = await repo.user.first;

        expect(result, isNull);
      });

      test(
          'user stream emits MyUser when authenticated and Firestore data exists',
          () async {
        final userFuture = repo.user
            .whereType<MyUser>()
            .first
            .timeout(const Duration(seconds: 3));

        final inputUser = MyUser(
          userId: '',
          name: 'Muarif',
          email: 'muarif@mail.com',
          photoUrl: '',
          currentAllowance: 0,
          totalSaving: 0,
          goalsAchieved: 0,
        );

        final signedUpUser = await repo.signUp(
          inputUser,
          'Password123!',
        );

        final result = await userFuture;

        expect(result.userId, signedUpUser.userId);
        expect(result.name, 'Muarif');
        expect(result.email, 'muarif@mail.com');
      });

      test('signIn signs in existing user', () async {
        final inputUser = MyUser(
          userId: '',
          name: 'Muarif',
          email: 'muarif@mail.com',
          goalsAchieved: 0,
        );

        final signedUpUser = await repo.signUp(
          inputUser,
          'Password123!',
        );

        await repo.setUserData(signedUpUser);

        await repo.logout();

        expect(auth.currentUser, isNull);

        await repo.signIn('muarif@mail.com', 'Password123!');

        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.email, 'muarif@mail.com');
      });

      test('logout signs out current user', () async {
        final inputUser = MyUser(
          userId: '',
          name: 'Muarif',
          email: 'muarif@mail.com',
          goalsAchieved: 0,
        );

        await repo.signUp(inputUser, 'Password123!');

        expect(auth.currentUser, isNotNull);

        await repo.logout();

        expect(auth.currentUser, isNull);
      });
    });

    group('account information', () {
      test('updateAccountInformation updates name and photoUrl', () async {
        final user = MyUser(
          userId: 'user-1',
          name: 'Old Name',
          email: 'old@mail.com',
          goalsAchieved: 0,
        );

        await repo.setUserData(user);

        await repo.updateAccountInformation(
          userId: 'user-1',
          name: 'New Name',
          photoUrl: 'https://example.com/photo.png',
        );

        final doc = await firestore.collection('users').doc('user-1').get();
        final data = doc.data()!;

        expect(data['name'], 'New Name');
        expect(data['photoUrl'], 'https://example.com/photo.png');
      });

      test('updateAccountInformation does not overwrite photoUrl when null',
          () async {
        await firestore.collection('users').doc('user-1').set({
          'userId': 'user-1',
          'name': 'Old Name',
          'email': 'old@mail.com',
          'photoUrl': 'https://example.com/old.png',
          'currentAllowance': 0.0,
          'goalsAchieved': 0,
        });

        await repo.updateAccountInformation(
          userId: 'user-1',
          name: 'New Name',
        );

        final doc = await firestore.collection('users').doc('user-1').get();
        final data = doc.data()!;

        expect(data['name'], 'New Name');
        expect(data['photoUrl'], 'https://example.com/old.png');
      });
    });
  });
}

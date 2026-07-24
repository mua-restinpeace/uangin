import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_repository/src/entities/entities.dart';
import 'package:user_repository/src/models/user.dart';
import 'package:user_repository/src/user_repo.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final userCollection;

  FirebaseUserRepo({FirebaseAuth? firebaseAuth, FirebaseFirestore? fireStore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = fireStore ?? FirebaseFirestore.instance,
        userCollection =
            (fireStore ?? FirebaseFirestore.instance).collection('users');

  @override
  Stream<MyUser?> get user {
    return _firebaseAuth.authStateChanges().switchMap((firebaseUser) {
      if (firebaseUser == null) {
        log('Firebase user was null');
        return Stream.value(null);
      }

      return userCollection
          .doc(firebaseUser.uid)
          .snapshots()
          .map<MyUser?>((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          log('User document does not exist for: ${firebaseUser.uid}');
          return null;
        }

        log('User data updated: ${snapshot.data()}');
        return MyUser.fromEntity(UserEntity.fromJSON(snapshot.data()!));
      });
    });
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: myUser.email, password: password);

      myUser.userId = userCredential.user!.uid;

      WriteBatch batch = _firestore.batch();

      final userRef = userCollection.doc(myUser.userId);
      batch.set(userRef, myUser.toEnity().toJSON());

      final defaultBudgets = _getDefaultBudgets(myUser.userId);
      for (var budget in defaultBudgets) {
        final budgetRef =
            userCollection.doc(myUser.userId).collection('budgets').doc();

        final budgetsWithId = budget.copyWith(budgetId: budgetRef.id);
        batch.set(budgetRef, budgetsWithId.toEnity().toJSON());
      }

      await batch.commit();

      // await userCredential.user!.reload();

      // await Future.delayed(const Duration(milliseconds: 100));

      log('User created: $myUser');
      return myUser;
    } catch (e) {
      log('Error in signup user: $e');

      try {
        await _firebaseAuth.currentUser?.delete();
      } catch (deleteError) {
        log('Error in delete user after failed signup: $deleteError');
      }
      rethrow;
    }
  }

  List<Budgets> _getDefaultBudgets(String userId) {
    final now = DateTime.now();
    final periodStart = now.subtract(Duration(days: now.weekday - 1));
    final periodEnd = periodStart.add(const Duration(days: 6));
    return [
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Food & Drinks',
          icon: 'lib/assets/icons/knife_fork.svg',
          color: '#FE724E',
          allocatedAmount: 150000,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Groceries',
          icon: 'lib/assets/icons/cart.svg',
          color: '#426FF6',
          allocatedAmount: 30000,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Gyms',
          icon: 'lib/assets/icons/dumbell.svg',
          color: '#C93FFF',
          allocatedAmount: 35000,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Transportations',
          icon: 'lib/assets/icons/car.svg',
          color: '#45C296',
          allocatedAmount: 25000,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Snacks',
          icon: 'lib/assets/icons/smile_face.svg',
          color: '#F69E09',
          allocatedAmount: 30000,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Subscriptions',
          icon: 'lib/assets/icons/refresh-dollar.svg',
          color: '#FE5D5F',
          allocatedAmount: 25000,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Others',
          icon: 'lib/assets/icons/other.svg',
          color: '#888989',
          allocatedAmount: 0,
          periodStart: periodStart,
          periodEnd: periodEnd),
    ];
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await userCollection.doc(myUser.userId).set(myUser.toEnity().toJSON());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> hasOnBoardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  @override
  Future<void> setOnBoardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }

  @override
  Future<void> updateAccountInformation({
    required String userId,
    required String name,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{'name': name.trim()};

      // update photo url if a new one was provided to avoid overwriting the existing one
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }

      await userCollection.doc(userId).update(updates);
      log('account info updated for: $userId');
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(
      {required String currentPassword, required String newPassword}) async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) throw Exception('No user signed in');
      if (currentUser.email == null) throw Exception('User has no email');

      // reauthenticate to refresh sessions
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);

      await currentUser.updatePassword(newPassword);
      log('Password updated for: ${currentUser.uid}');
    } on FirebaseAuthException catch (e) {
      log('Firebase auth error updating password: ${e.code}');
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Current password is incorrect');
        case 'weak-password':
          throw Exception('New password is too weak. Use at least 8 character');
        case 'requires-recent-login':
          throw Exception('Session expired. Please log out and sign in again');
        case 'too-many-request':
          throw Exception(
              'Too many attempts. Please wait a moment and try again');
        default:
          throw Exception('Something went wrong. Please try again');
      }
    } catch (e) {
      log('error updating password: $e');
      rethrow;
    }
  }
}

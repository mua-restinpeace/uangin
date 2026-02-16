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

      return userCollection.doc(firebaseUser.uid).snapshots().map<MyUser?>((snapshot) {
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
          color: '#FCECD1',
          allocatedAmount: 150000,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Groceries',
          icon: 'lib/assets/icons/cart.svg',
          color: '#C8DDF7',
          allocatedAmount: 50000,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Gyms',
          icon: 'lib/assets/icons/dumbell.svg',
          color: '#E0CDEC',
          allocatedAmount: 0,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Transportations',
          icon: 'lib/assets/icons/car.svg',
          color: '#CBE7D5',
          allocatedAmount: 0,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Snacks',
          icon: 'lib/assets/icons/smile_face.svg',
          color: '#FFE7BA',
          allocatedAmount: 0,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Subscriptions',
          icon: 'lib/assets/icons/tag.svg',
          color: '#FFE5EE',
          allocatedAmount: 0,
          periodStart: periodStart,
          periodEnd: periodEnd),
      Budgets(
          budgetId: '',
          userId: userId,
          name: 'Others',
          icon: 'lib/assets/icons/other.svg',
          color: '#E0E0E0',
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
}

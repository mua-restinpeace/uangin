import 'package:user_repository/src/models/models.dart';

abstract class UserRepository{
  Stream<MyUser?> get user;

  Future<MyUser> signUp(MyUser user, String password);

  Future<void> setUserData(MyUser user);

  Future<void> signIn(String email, String password);

  Future<void> logout();

  Future<void> setOnBoardingComplete();

  Future<bool> hasOnBoardingComplete();

  Future<void> updateAccountInformation({required String userId, required String name, String? photoUrl});

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
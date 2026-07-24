part of 'update_account_info_bloc.dart';

sealed class UpdateAccountInfoEvent extends Equatable {
  const UpdateAccountInfoEvent();

  @override
  List<Object?> get props => [];
}

class UpdateAccountInfo extends UpdateAccountInfoEvent {
  final String userId;
  final String name;
  final String? photoUrl;

  const UpdateAccountInfo(
      {required this.userId, required this.name, this.photoUrl});

  @override
  List<Object?> get props => [userId, name, photoUrl];
}

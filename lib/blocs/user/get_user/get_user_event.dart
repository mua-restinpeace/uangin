part of 'get_user_bloc.dart';

sealed class GetUserEvent extends Equatable {
  const GetUserEvent();

  @override
  List<Object?> get props => [];
  
}
class GetUser extends GetUserEvent {}

class GetUserUpdated extends GetUserEvent{
  final MyUser? user;

  const GetUserUpdated(this.user);

  @override
  List<Object?> get props => [user];
}


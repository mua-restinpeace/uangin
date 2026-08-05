part of 'connectivity_bloc.dart';

sealed class ConnectivityState extends Equatable {
  const ConnectivityState();
  
  @override
  List<Object> get props => [];
}

final class ConnectivityInitial extends ConnectivityState {}
final class ConnectivityOffline extends ConnectivityState {}
final class ConnectivityOnline extends ConnectivityState {}
final class ConnectivityRestored extends ConnectivityState {}

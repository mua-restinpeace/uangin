part of 'allocate_savings_bloc.dart';

sealed class AllocateSavingsState extends Equatable {
  const AllocateSavingsState();
  
  @override
  List<Object> get props => [];
}

final class AllocateSavingsInitial extends AllocateSavingsState {}
final class AllocateSavingsLoading extends AllocateSavingsState {}
final class AllocateSavingsFailure extends AllocateSavingsState {}
final class AllocateSavingsSuccess extends AllocateSavingsState {
  final double excessAmount;

  const AllocateSavingsSuccess(this.excessAmount);

  @override
  List<Object> get props => [excessAmount];
}

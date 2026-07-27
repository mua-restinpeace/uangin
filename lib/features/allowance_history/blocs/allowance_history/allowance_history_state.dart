part of 'allowance_history_bloc.dart';

sealed class AllowanceHistoryState extends Equatable {
  const AllowanceHistoryState();

  @override
  List<Object> get props => [];
}

final class AllowanceHistoryInitial extends AllowanceHistoryState {}

final class AllowanceHistoryLoading extends AllowanceHistoryState {}

final class AllowanceHistorySuccess extends AllowanceHistoryState {
  final Map<String, List<Allowances>> groupedAllowance;
  final AllowanceFilter currentFilter;

  const AllowanceHistorySuccess(this.groupedAllowance, this.currentFilter);

  @override
  List<Object> get props => [groupedAllowance, currentFilter];
}

final class AllowanceHistoryFailure extends AllowanceHistoryState {}

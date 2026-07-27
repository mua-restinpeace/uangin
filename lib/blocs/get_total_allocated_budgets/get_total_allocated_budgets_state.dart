part of 'get_total_allocated_budgets_bloc.dart';

sealed class GetTotalAllocatedBudgetsState extends Equatable {
  const GetTotalAllocatedBudgetsState();

  @override
  List<Object> get props => [];
}

final class GetTotalAllocatedBudgetsInitial
    extends GetTotalAllocatedBudgetsState {}

final class GetTotalAllocatedBudgetsLoading
    extends GetTotalAllocatedBudgetsState {}

final class GetTotalAllocatedBudgetsFailure
    extends GetTotalAllocatedBudgetsState {}

final class GetTotalAllocatedBudgetsSuccess
    extends GetTotalAllocatedBudgetsState {
  final double totalAllocated;

  const GetTotalAllocatedBudgetsSuccess(this.totalAllocated);

  @override
  List<Object> get props => [totalAllocated];
}

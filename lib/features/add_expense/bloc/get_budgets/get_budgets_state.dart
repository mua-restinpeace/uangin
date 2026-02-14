part of 'get_budgets_bloc.dart';

sealed class GetBudgetsState extends Equatable {
  const GetBudgetsState();
  
  @override
  List<Object> get props => [];
}

final class GetBudgetsInitial extends GetBudgetsState {}

final class GetBudgetsLoading extends GetBudgetsState {}
final class GetBudgetsFailure extends GetBudgetsState {}
final class GetBudgetsSuccess extends GetBudgetsState {
  final List<Budgets> budgetList;

  const GetBudgetsSuccess(this.budgetList);

  @override
  List<Object> get props => [budgetList];
}

part of 'add_budgets_bloc.dart';

sealed class AddBudgetsState extends Equatable {
  const AddBudgetsState();
  
  @override
  List<Object> get props => [];
}

final class AddBudgetsInitial extends AddBudgetsState {}
final class AddBudgetsLoading extends AddBudgetsState {}
final class AddBudgetsFailure extends AddBudgetsState {}
final class AddBudgetsSuccess extends AddBudgetsState {}

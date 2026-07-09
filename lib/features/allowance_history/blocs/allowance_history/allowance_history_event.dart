part of 'allowance_history_bloc.dart';

sealed class AllowanceHistoryEvent extends Equatable {
  const AllowanceHistoryEvent();

  @override
  List<Object> get props => [];
}

class GetFilteredAllowance extends AllowanceHistoryEvent{
  final String userId;
  final AllowanceFilter filter;

  const GetFilteredAllowance(this.userId, this.filter);

  @override
  List<Object> get props => [userId, filter];
}

class FilteredAllowanceUpdate extends AllowanceHistoryEvent{
  final Map<String, List<Allowances>> groupedAllowance;
  final AllowanceFilter currentFilter;

  const FilteredAllowanceUpdate(this.groupedAllowance, this.currentFilter);

  @override
  List<Object> get props => [groupedAllowance, currentFilter];
}

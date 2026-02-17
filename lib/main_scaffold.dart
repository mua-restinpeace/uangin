import 'package:allowance_repository/allowance_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uangin/blocs/user/get_user/get_user_bloc.dart';
import 'package:uangin/core/widgets/bottom_navigation/custom_bottom_navigator.dart';
import 'package:uangin/features/add_expense/views/add_expense_screen.dart';
import 'package:uangin/features/home/blocs/get_recent_transactions/get_recent_transactions_bloc.dart';
import 'package:uangin/features/home/views/home_screen.dart';
import 'package:uangin/features/profile/views/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetRecentTransactionsBloc(context.read<AllowanceRepository>()),
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: const [HomeScreen(), ProfileScreen()],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: BlocBuilder<GetUserBloc, GetUserState>(
                builder: (context, state) {
                  return CustomBottomNavigator(
                    selectedIndex: _selectedIndex,
                    onIndexChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    onAddTap: () {
                      if (state is GetUserSuccess) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpenseScreen(
                                userId: state.user.userId,
                              ),
                            ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please wait, loading user data...')));
                      }
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

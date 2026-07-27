import 'dart:developer';

import 'package:allowance_repository/allowance_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uangin/app.dart';
import 'package:user_repository/user_repository.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask(
    (taskName, inputData) async {
      log('Background task started: $taskName');

      try {
        await Firebase.initializeApp();

        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');

        if (userId != null) {
          final repo = FirebaseAllowanceRepo();
          await repo.renewExpiredBudgets(userId);
          log('Renewed budgets successfully');
        }

        return Future.value(true);
      } catch (e) {
        log('Background task failed: $e');
        return Future.value(false);
      }
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  await Workmanager().registerPeriodicTask(
      'budget-renewal-task', 'budgetRenewal',
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(hours: 1),
      constraints: Constraints(
          networkType: NetworkType.connected,
          requiresCharging: false,
          requiresBatteryNotLow: false));

  runApp(MyApp(FirebaseUserRepo(), FirebaseAllowanceRepo()));
}

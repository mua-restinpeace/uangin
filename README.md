<div align="center">
  <img src="lib/assets/icons/logo_with_background.png" alt="Uangin Logo" width="120" />
  <h1>Uangin</h1>
  <p>A personal allowance and expense tracker built with Flutter & Firebase</p>

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
  ![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
  ![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Auth-FFCA28?logo=firebase)
  ![BLoC](https://img.shields.io/badge/State-BLoC-4A90D9)
</div>

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [State Management](#state-management)
- [Firebase Setup](#firebase-setup)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)

---

## Overview

**Uangin** is a mobile finance app designed to help students and young adults manage their allowance, track spending, set budgets per category, and work toward saving goals — all backed by a real-time Firebase backend.

The app is built as a personal project with the goal of being a fully functional, self-hostable finance tool.

---

## Features

### 💰 Allowance Management
- Add new allowance top-ups with optional notes
- Save leftover balance to a general savings pool when receiving new allowance
- Correct balance with an audit-safe **balance correction** entry (logs the delta, not a silent overwrite)
- View full allowance history with type indicators (Top Up vs Correction)

### 📊 Budget Tracking
- Create spending budgets per category (Food, Transport, Entertainment, etc.)
- Each budget has an allocated amount, a period (start/end date), and tracks spent amount in real time
- Visual progress bars showing how much of each budget has been used
- Spending Analysis screen with weekly summary and budget breakdown charts

### 🧾 Expense Recording
- Record expenses against a specific budget
- Edit or delete existing transactions with full audit support (adjusts budget `spentAmount` and `currentAllowance` atomically via Firestore batch writes)
- Recent transactions on the home screen; full transaction history with filtering

### 🎯 Saving Goals
- Create saving goals with a target amount and optional target date
- Allocate money from the general savings pool toward specific goals
- Automatic goal completion detection — marks complete and increments `goalsAchieved` counter
- Cancel goals to return allocated money to the savings pool

### 👤 Profile & Settings
- **Account Information** — edit display name and profile photo (stored as Base64 in Firestore)
- **Password & Security** — change password with reauthentication and live password strength indicator
- **Allowance History** — scrollable log of all allowance entries
- **Help Center** — accordion FAQ covering all app features
- **About** — app version, developer info, tech stack

---

## Architecture

Uangin follows a clean **three-layer architecture**:

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│         Screens · Widgets · UI State         │
└───────────────────┬─────────────────────────┘
                    │  events / states
┌───────────────────▼─────────────────────────┐
│                 BLoC Layer                   │
│     Business logic · State management        │
└───────────────────┬─────────────────────────┘
                    │  method calls
┌───────────────────▼─────────────────────────┐
│              Repository Layer                │
│    Firebase Auth · Firestore · Prefs         │
└─────────────────────────────────────────────┘
```

The repository layer is extracted into two independent local packages under `/packages`, keeping Firebase concerns completely isolated from the rest of the app.

---

## Project Structure

```
uangin/
├── lib/
│   ├── main.dart                  # Entry point, DI setup
│   ├── app.dart                   # BlocProviders
│   ├── app_view.dart              # MaterialApp + routing
│   ├── main_scaffold.dart         # Bottom nav scaffold
│   ├── simple_bloc_observer.dart  # Debug observer
│   │
│   ├── blocs/                     # App-wide blocs
│   │   ├── authenticaton_bloc/    # Auth stream listener
│   │   ├── delete_transaction/
│   │   ├── expense_summary/
│   │   ├── get_budgets/
│   │   ├── get_total_allocated_budgets/
│   │   ├── update_transaction/
│   │   └── user/get_user/
│   │
│   ├── core/
│   │   ├── theme/                 # ThemeData, color palette
│   │   └── widgets/               # Shared reusable widgets
│   │       ├── my_text_field.dart
│   │       ├── my_button.dart
│   │       ├── custom_linear_progress_bar.dart
│   │       ├── profile_avatar.dart
│   │       ├── password_strength_indicator.dart
│   │       └── transaction/       # TransactionItem, EditBottomSheet
│   │
│   └── features/                  # Feature modules
│       ├── auth/                  # Sign in / Sign up
│       ├── home/                  # Home screen + blocs
│       ├── wallet/                # Wallet screen
│       ├── add_allowance/         # Add allowance flow
│       ├── edit_allowance/        # Balance correction flow
│       ├── allowance_history/     # Allowance log screen
│       ├── add_expense/           # Record expense
│       ├── add_budgets/           # Create budget
│       ├── expense_summary/       # Spending analysis + charts
│       ├── transaction_records/   # Full transaction history
│       ├── add_saving_goals/      # Create saving goal
│       ├── allocate_savings/      # Allocate savings to goal
│       ├── profile/               # Profile screen
│       ├── account_information/   # Edit name + photo
│       ├── password_and_security/ # Change password
│       ├── help_center/           # FAQ accordion
│       ├── about_us/              # App info
│       ├── theme/                 # Theme toggle (WIP)
│       └── onBoarding/            # Splash + onboarding
│
└── packages/
    ├── user_repository/           # Auth + user Firestore ops
    │   └── lib/src/
    │       ├── models/user.dart
    │       ├── entities/user_entity.dart
    │       ├── user_repo.dart         # Abstract interface
    │       └── user_firebase_repo.dart
    │
    └── allowance_repository/      # All financial data ops
        └── lib/src/
            ├── models/            # Allowances, Budgets, Transactions, SavingGoals
            ├── entities/          # Firestore <-> model converters
            ├── allowance_repo.dart
            └── allowance_firebase_repo.dart
```

---

## Data Models

### `MyUser`
Stored at `users/{userId}` in Firestore.

| Field | Type | Description |
|---|---|---|
| `userId` | `String` | Firebase Auth UID |
| `name` | `String` | Display name |
| `email` | `String` | Login email |
| `photoUrl` | `String` | Base64-encoded profile photo |
| `currentAllowance` | `double` | Current spendable balance |
| `totalSaving` | `double` | Unallocated savings pool |
| `lastAllowanceDate` | `DateTime?` | Date of last top-up |
| `goalsAchieved` | `int` | Count of completed saving goals |

---

### `Allowances`
Stored at `users/{userId}/allowances/{allowanceId}`.

| Field | Type | Description |
|---|---|---|
| `allowanceId` | `String` | Document ID |
| `userId` | `String` | Owner |
| `amount` | `double` | Amount added (or delta if correction) |
| `savedAmount` | `double` | Leftover moved to savings on this entry |
| `date` | `DateTime?` | Entry date |
| `notes` | `String?` | Optional note |
| `type` | `AllowanceType` | `topUp` or `correction` |

> For `correction` entries, `amount` stores the **delta** (positive or negative), not the target balance. This keeps the history consistent and summable.

---

### `Budgets`
Stored at `users/{userId}/budgets/{budgetId}`.

| Field | Type | Description |
|---|---|---|
| `budgetId` | `String` | Document ID |
| `userId` | `String` | Owner |
| `name` | `String` | Budget label (e.g. "Food") |
| `icon` | `String` | Icon asset name |
| `color` | `String` | Hex color string |
| `allocatedAmount` | `double` | Spending limit for the period |
| `spentAmount` | `double` | Running total spent |
| `periodStart` | `DateTime?` | Budget period start |
| `periodEnd` | `DateTime?` | Budget period end |
| `isActive` | `bool` | Whether budget is currently active |

Computed getters: `remainingAmount`, `percentageUsed`

---

### `Transactions`
Stored at `users/{userId}/transactions/{transactionId}`.

| Field | Type | Description |
|---|---|---|
| `transactionId` | `String` | Document ID |
| `userId` | `String` | Owner |
| `budgetId` | `String` | Associated budget |
| `budgetName` | `String` | Denormalized budget name |
| `budgetIcon` | `String` | Denormalized budget icon |
| `budgetColor` | `String` | Denormalized budget color |
| `amount` | `double` | Transaction amount |
| `date` | `DateTime?` | Transaction date |
| `description` | `String?` | Optional note |
| `type` | `TransactionType` | `expense`, `income`, or `savingsTransfer` |

> Budget name, icon, and color are denormalized onto the transaction at write time so transaction lists never require a join query.

---

### `SavingGoals`
Stored at `users/{userId}/savingGoals/{goalId}`.

| Field | Type | Description |
|---|---|---|
| `goalId` | `String` | Document ID |
| `userId` | `String` | Owner |
| `name` | `String` | Goal label (e.g. "Trip to Merbabu") |
| `description` | `String?` | Optional description |
| `icon` | `String?` | Icon asset name |
| `targetAmount` | `double` | Amount to reach |
| `currentAmount` | `double` | Amount allocated so far |
| `createdDate` | `DateTime?` | When goal was created |
| `targetDate` | `DateTime?` | Optional deadline |
| `isComplete` | `bool` | Whether goal has been reached |
| `completedDate` | `DateTime?` | When it was completed |

Computed getters: `remainingAmount`, `percentageComplete`

**Savings allocation flow:**
```
Allocate X to goal  →  totalSaving  -= X
                        goal.currentAmount += X

Goal completed      →  goal archived, totalSaving unchanged
Goal cancelled      →  totalSaving += goal.currentAmount
                        goal.currentAmount = 0
```

---

## State Management

Uangin uses the **BLoC pattern** (`flutter_bloc`) throughout. Every BLoC follows the same structure:

```
feature/
  blocs/
    feature_name/
      feature_name_bloc.dart   # Bloc class
      feature_name_event.dart  # Sealed event classes
      feature_name_state.dart  # Sealed state classes
```

**App-wide blocs** provided at the root in `app.dart`:

| BLoC | Responsibility |
|---|---|
| `AuthenticationBloc` | Listens to Firebase Auth stream, drives routing |
| `GetUserBloc` | Streams current user data from Firestore |
| `GetBudgetsBloc` | Streams active budgets |
| `ExpenseSummaryBloc` | Calculates weekly/monthly spend totals |
| `GetTotalAllocatedBudgetsBloc` | Sums all active budget allocations |
| `DeleteTransactionBloc` | Handles atomic transaction deletion |
| `UpdateTransactionBloc` | Handles atomic transaction editing |

**Feature-scoped blocs** are provided locally at the screen level with `BlocProvider` and disposed when the screen is popped.

---

## Firebase Setup

### Firestore Structure

```
users/
  {userId}               ← MyUser document
    allowances/
      {allowanceId}      ← Allowances document
    budgets/
      {budgetId}         ← Budgets document
    transactions/
      {transactionId}    ← Transactions document
    savingGoals/
      {goalId}           ← SavingGoals document
```

### Security Rules Summary

- Users can only access their own subcollections (`request.auth.uid == userId`)
- Transaction `amount` must be `> 0`
- Budget and saving goal amounts must be `>= 0`
- Allowance `amount` allows negative values only for `type == 'correction'` entries

### Required Firebase services
- **Firebase Auth** — email/password sign-in
- **Cloud Firestore** — all data storage

> Profile photos are Base64-encoded and stored as Firestore string fields, so Firebase Storage is not required.

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.5.4`
- A Firebase project with Auth and Firestore enabled

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/mua-restinpeace/uangin.git
cd uangin
```

**2. Connect Firebase**

Download your Firebase config files and place them in:
```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

**3. Install dependencies**
```bash
flutter pub get
```

**4. Run**
```bash
flutter run
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `cloud_firestore` | Firestore database |
| `firebase_auth` | Authentication |
| `flutter_bloc` | BLoC state management |
| `equatable` | Value equality for states & events |
| `flutter_svg` | SVG icon rendering |
| `shared_preferences` | Onboarding flag persistence |
| `money_formatter` | IDR currency formatting |
| `intl` | Date formatting |
| `rxdart` | Reactive stream utilities |
| `flutter_slidable` | Swipe-to-action on list items |
| `currency_text_input_formatter` | Currency input masking |
| `image_picker` | Gallery photo selection |
| `flutter_image_compress` | Image compression before Base64 encoding |
| `package_info_plus` | App version reading |
| `workmanager` | Background task scheduling |

---

<div align="center">
  <p>Built with ❤️ using Flutter & Firebase</p>
</div>

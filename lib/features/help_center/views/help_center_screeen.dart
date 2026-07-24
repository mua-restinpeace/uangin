import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/features/help_center/widgets/faq_section.dart';
import 'package:uangin/features/help_center/widgets/faq_tile.dart';

class HelpCenterScreeen extends StatelessWidget {
  const HelpCenterScreeen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              'lib/assets/icons/arrow_left.svg',
              width: 32,
              height: 32,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Help Center',
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(fontSize: 20),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Frequently Asked Questions',
            style: Theme.of(context)
                .textTheme
                .displayLarge
                ?.copyWith(fontSize: 18),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            'Find answers to common questiions about using Uangin.',
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          const SizedBox(
            height: 24,
          ),
          const FaqSection(
            title: 'Getting Started',
            items: [
              FaqItem(
                question: 'What is Uangin?',
                answer:
                    'Uangin is a personal finance app that helps you manage your allowance, track your expenses, set budgets, and work toward saving goals — all in one place.',
              ),
              FaqItem(
                question: 'How do I get started after signing up?',
                answer:
                    'After signing up, add your current allowance by tapping "Add Allowance" on the home screen. Then set up budgets for your spending categories, and start recording your expenses as you go.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FaqSection(
            title: 'Allowance',
            items: [
              FaqItem(
                question: 'How do I add a new allowance?',
                answer:
                    'Go to the Wallet screen and tap "Add Allowance." Enter the amount you received and choose whether to save your leftover balance or carry it forward.',
              ),
              FaqItem(
                question:
                    'What does "Save leftover" mean when adding allowance?',
                answer:
                    'When you add a new allowance, your current remaining balance becomes leftover. Choosing to save it moves that leftover into your savings pool instead of replacing it with zero.',
              ),
              FaqItem(
                question:
                    'Can I correct my balance if I entered the wrong amount?',
                answer:
                    'Yes. Go to the Wallet screen, tap the menu on your balance card, and select "Edit Current Allowance." Enter the correct amount and the app will calculate and log the difference automatically.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FaqSection(
            title: 'Budgets',
            items: [
              FaqItem(
                question: 'What are budgets?',
                answer:
                    'Budgets are spending limits you set for specific categories — like Food, Transport, or Entertainment. They help you control where your allowance goes each period.',
              ),
              FaqItem(
                question: 'What happens when a budget period ends?',
                answer:
                    'The app automatically renews your budgets at the start of each new period, resetting the spent amount back to zero so you start fresh.',
              ),
              FaqItem(
                question: 'Can I have multiple budgets at the same time?',
                answer:
                    'Yes, you can create as many budgets as you need. Each budget tracks its own category independently.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FaqSection(
            title: 'Expenses',
            items: [
              FaqItem(
                question: 'How do I record an expense?',
                answer:
                    'Tap the + button at the bottom of the screen, fill in the amount, description, and select which budget this expense belongs to, then tap Add.',
              ),
              FaqItem(
                question: 'Can I edit or delete a transaction?',
                answer:
                    'Yes. In the Recent Transactions list or Transaction Records screen, swipe or tap on a transaction to reveal the edit and delete options.',
              ),
              FaqItem(
                question: 'What is the Spending Analysis?',
                answer:
                    'Spending Analysis shows a summary of how much you have spent relative to your total allocated budget. Tap it on the home screen to see a more detailed breakdown by category.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FaqSection(
            title: 'Saving Goals',
            items: [
              FaqItem(
                question: 'How do saving goals work?',
                answer:
                    'Saving goals let you set a target amount for something you want to save toward — like a trip or a gadget. You allocate money from your savings pool toward a goal, and the app tracks your progress.',
              ),
              FaqItem(
                question: 'What happens when I reach my saving goal?',
                answer:
                    'The goal is marked as completed and your Goals Achieved count goes up. The allocated money stays with the completed goal and is not returned to your savings pool.',
              ),
              FaqItem(
                question: 'What if I cancel a saving goal?',
                answer:
                    'If you cancel a goal, the money you had allocated toward it is returned to your general savings pool so you can use it elsewhere.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const FaqSection(
            title: 'Account & Security',
            items: [
              FaqItem(
                question: 'How do I change my password?',
                answer:
                    'Go to Profile → Password & Security. You will need to enter your current password before setting a new one.',
              ),
              FaqItem(
                question: 'How do I update my name or profile picture?',
                answer:
                    'Go to Profile → Account Information to update your display name and profile photo.',
              ),
              FaqItem(
                question: 'How do I log out?',
                answer:
                    'Scroll to the bottom of the Profile screen and tap "Logout."',
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MyColors.fillColor,
              border: Border.all(color: MyColors.lightGrey),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still need help?',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 16),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'If you couldn\'t finid the answer you were looking for, feel free to reach out.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 14),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'lib/assets/icons/mail.svg',
                      height: 20,
                      width: 20,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'disinilohaku@gmail.com',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

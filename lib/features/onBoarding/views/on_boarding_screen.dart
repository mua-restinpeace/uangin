import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uangin/blocs/authenticaton_bloc/authentication_bloc.dart';
import 'package:uangin/core/widgets/long_button.dart';
import 'package:uangin/features/onBoarding/models/on_boarding_item.dart';
import 'package:uangin/core/widgets/my_button.dart';
import 'package:uangin/features/onBoarding/widgets/on_boarding_indicator.dart';
import 'package:uangin/features/onBoarding/widgets/on_boarding_page.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < onBoardingItems.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  bool get isLastPage => _currentIndex == 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onBoardingItems.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  if (index < 3) {
                    return OnBoardingPage(item: onBoardingItems[index]);
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Top Element
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              onBoardingItems[index].title,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 36),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            SvgPicture.asset(onBoardingItems[index].image),
                          ],
                        )),
                      ],
                    );
                  }
                },
              ),
            ),

            // Bottom Section
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: isLastPage
                      ? LongButton(
                          text: 'Get Started',
                          onPressed: () {
                            context.read<AuthenticationBloc>().add(AuthenticationOnBoardingCompleted());
                          },
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(3,
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    curve: Curves.easeInOut);
                              },
                              child: Text(
                                'Skip',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 20),
                              ),
                            ),
                            OnBoardingIndicator(currentIndex: _currentIndex),
                            MyButton(
                              onTap: _nextPage,
                              content: SvgPicture.asset('lib/assets/icons/arrow-right.svg'),
                            ),
                          ],
                        ),
                )),
            const SizedBox(
              height: 24,
            )
          ],
        ),
      ),
    );
  }
}

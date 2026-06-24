import 'package:flutter/material.dart';

class AnimatedCircle extends StatefulWidget {
  const AnimatedCircle({super.key});

  @override
  State<AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _innerAnimation;
  late Animation<double> _middleAnimation;
  late Animation<double> _outterAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _innerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );

    _middleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    );

    _outterAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 1.6,
            width: MediaQuery.of(context).size.width * 1.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // outter circle
                Transform.scale(
                  scale: 0.8 + (_outterAnimation.value * 0.2),
                  child: Opacity(
                    opacity: _outterAnimation.value,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1.6,
                      width: MediaQuery.of(context).size.width * 1.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.4),
                            blurRadius: 80,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // middle circle
                Transform.scale(
                  scale: 0.8 + (_middleAnimation.value * 0.2),
                  child: Opacity(
                    opacity: _middleAnimation.value,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 1.3,
                      width: MediaQuery.of(context).size.width * 1.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            blurRadius: 50,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // inner circle
                Transform.scale(
                  scale: 0.5 + (_innerAnimation.value * 0.5),
                  child: Opacity(
                    opacity: _innerAnimation.value,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

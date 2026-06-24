import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uangin/core/theme/colors.dart';

class CustomLinearProgressBar extends StatefulWidget {
  final double percentage;
  final Color? backgroundColor;
  final Color progressColor;
  final double width;

  const CustomLinearProgressBar(
      {required this.percentage,
      this.width = 200,
      this.backgroundColor = MyColors.fillColor,
      required this.progressColor,
      super.key});

  @override
  State<CustomLinearProgressBar> createState() =>
      _CustomLinearProgressBarState();
}

class _CustomLinearProgressBarState extends State<CustomLinearProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curvedAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _curvedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePercentage =
        widget.percentage.isFinite ? widget.percentage.clamp(0.0, 1.0) : 0.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint('ProggressBar Constraints: $constraints');

        return SizedBox(
          height: 20,
          width: widget.width,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: MyColors.lightGrey),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progressWidth =
                      widget.width * safePercentage * _curvedAnimation.value;

                  return SizedBox(
                    width: progressWidth,
                    height: 20,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: progressWidth,
                          decoration: BoxDecoration(
                              color: widget.progressColor,
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Positioned(
                          right: -6,
                          top: -4,
                          child: SvgPicture.asset(
                            'lib/assets/icons/upside_down_triangle.svg',
                            width: 10,
                            height: 10,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

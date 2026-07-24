import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FaqItem {
  final String question;
  final String answer;
  const FaqItem({required this.question, required this.answer});
}

class FaqTile extends StatefulWidget {
  final FaqItem item;
  const FaqTile({required this.item, super.key});
  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandedAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 250,
        ));

    _expandedAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.question,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                RotationTransition(
                  turns: _rotateAnimation,
                  child: SvgPicture.asset(
                    'lib/assets/icons/cevron-down.svg',
                    width: 20,
                    height: 20,
                  ),
                )
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandedAnimation,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Text(
              widget.item.answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.6,
                  ),
            ),
          ),
        )
      ],
    );
  }
}

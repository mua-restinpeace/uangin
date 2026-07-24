import 'package:flutter/material.dart';
import 'package:uangin/core/theme/colors.dart';

class PasswordStrengthIndicator extends StatefulWidget {
  final TextEditingController password;
  const PasswordStrengthIndicator({required this.password, super.key});

  @override
  State<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator> {
  @override
  void initState() {
    super.initState();
    widget.password.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.password.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  int _strength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    final hasMinLength = password.length >= 8;
    final hasGoodLength = password.length >= 12;
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[^A-Za-z0-9]').hasMatch(password);

    if (hasMinLength) score++;
    if (hasGoodLength) score++;
    if (hasLowerCase && hasUpperCase) score++;
    if (hasNumber) score++;
    if (hasSpecialChar) score++;

    if (password.length < 8) {
      return 1;
    }

    if (score <= 2) return 1;
    if (score <= 3) return 2;
    if (score <= 4) return 3;
    return 4;
  }

  Color _color(int strength) {
    switch (strength) {
      case 1:
        return MyColors.red;
      case 2:
        return MyColors.orange;
      case 3:
        return MyColors.yellow;
      case 4:
        return MyColors.green;
      default:
        return MyColors.lightGrey;
    }
  }

  String _label(int strength) {
    switch (strength) {
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final password = widget.password.text;
    if (password.isEmpty) return SizedBox.shrink();

    final strength = _strength(password);
    final color = _color(strength);
    final label = _label(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            4,
            (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index < strength ? color : MyColors.lightGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: color,
              ),
        )
      ],
    );
  }
}

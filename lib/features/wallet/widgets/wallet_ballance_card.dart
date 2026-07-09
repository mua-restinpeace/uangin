import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:uangin/core/theme/colors.dart';
import 'package:uangin/core/widgets/my_button.dart';

enum WalletMenuAction { editCurrentAllowance, allowanceHistory }

class WalletBallanceCard extends StatelessWidget {
  final double currentAllowance;
  final bool showCurrentAllowance;
  final VoidCallback onToggleVisibility;
  final VoidCallback onAddAllowance;
  final ValueChanged<WalletMenuAction> onMenuSelected;

  const WalletBallanceCard({
    required this.currentAllowance,
    required this.showCurrentAllowance,
    required this.onToggleVisibility,
    required this.onAddAllowance,
    required this.onMenuSelected,
    super.key,
  });

  String _formatMoney(double amount) {
    final formatter = MoneyFormatter(amount: amount);
    return formatter.output.nonSymbol;
  }

  String _hideMoney(String value) {
    return value.replaceAll(RegExp(r'[0-9]'), '•');
  }

  @override
  Widget build(BuildContext context) {
    final formattedAllowance = _formatMoney(currentAllowance);
    final displayAllowance = showCurrentAllowance
        ? formattedAllowance
        : _hideMoney(formattedAllowance);
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: 18,
            child: ClipPath(
              clipper: WalletCardClipper(),
              child: Container(
                color: MyColors.primary,
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 0,
            child: PopupMenuButton(
              tooltip: 'Wallet menu',
              color: MyColors.white,
              elevation: 8,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: onMenuSelected,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: WalletMenuAction.editCurrentAllowance,
                    height: 54,
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: MyColors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            'lib/assets/icons/pencil.svg',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Edit Balance',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: WalletMenuAction.allowanceHistory,
                    height: 54,
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: MyColors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SvgPicture.asset(
                            'lib/assets/icons/history.svg',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Allowance History',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              child: Container(
                width: 76,
                height: 34,
                decoration: BoxDecoration(
                  color: MyColors.black,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'lib/assets/icons/three-dot-menu.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 18,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Allowance',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'IDR',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: MyColors.grey, fontSize: 40),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          displayAllowance,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                  fontSize: showCurrentAllowance ? 40 : 32,
                                  color: currentAllowance < 0
                                      ? MyColors.red
                                      : MyColors.onPrimary),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyButton(
                        onTap: onAddAllowance,
                        content: Row(
                          children: [
                            SvgPicture.asset(
                              'lib/assets/icons/plus.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Add Allowance',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontSize: 16,
                                    color: MyColors.white,
                                  ),
                            )
                          ],
                        ),
                      ),
                      MyButton(
                        onTap: onToggleVisibility,
                        content: SvgPicture.asset(
                          showCurrentAllowance
                              ? 'lib/assets/icons/eye_open_white.svg'
                              : 'lib/assets/icons/eye_close_white.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 18.0;

    // The black menu pill area on the top-right.
    const notchWidth = 92.0;
    const notchDepth = 46.0;

    final path = Path();

    // Start from top-left after corner radius
    path.moveTo(radius, 0);

    // Top line before the notch curve
    path.lineTo(size.width - notchWidth - 24, 0);

    // Curve going down into the notch
    path.cubicTo(
      size.width - notchWidth - 6,
      0,
      size.width - notchWidth - 2,
      notchDepth,
      size.width - notchWidth + 22,
      notchDepth,
    );

    // Flat line under the menu pill
    path.lineTo(size.width - radius, notchDepth);

    // Small curve into right edge
    path.quadraticBezierTo(
      size.width,
      notchDepth,
      size.width,
      notchDepth + radius,
    );

    // Right edge
    path.lineTo(size.width, size.height - radius);

    // Bottom-right corner
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );

    // Bottom edge
    path.lineTo(radius, size.height);

    // Bottom-left corner
    path.quadraticBezierTo(
      0,
      size.height,
      0,
      size.height - radius,
    );

    // Left edge
    path.lineTo(0, radius);

    // Top-left corner
    path.quadraticBezierTo(
      0,
      0,
      radius,
      0,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant WalletCardClipper oldClipper) => false;
}

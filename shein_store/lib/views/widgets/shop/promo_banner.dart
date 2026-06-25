import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textColor = context.isDarkMode ? colors.primaryText : colors.surface;
    final softTextColor = context.isDarkMode
        ? colors.secondaryText
        : colors.surface.withValues(alpha: 0.74);
    final accentStroke = colors.surface.withValues(
      alpha: context.isDarkMode ? 0.16 : 0.2,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 166;
        final tight = constraints.maxHeight < 154;
        final veryTight = constraints.maxHeight < 142;
        final horizontalPadding = veryTight ? 12.0 : (tight ? 14.0 : 18.0);
        final verticalPadding = veryTight ? 10.0 : (tight ? 12.0 : 16.0);
        final actionHeight = veryTight ? 28.0 : (tight ? 30.0 : 34.0);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: context.isDarkMode
                    ? [
                        const Color(0xFF151C27),
                        const Color(0xFF233041),
                        const Color(0xFF3A516C),
                      ]
                    : [
                        const Color(0xFF151515),
                        const Color(0xFF613A32),
                        const Color(0xFFAA5B4A),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -8,
                  right: -16,
                  child: Container(
                    width: veryTight ? 82 : (tight ? 96 : 120),
                    height: veryTight ? 82 : (tight ? 96 : 120),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface.withValues(
                        alpha: context.isDarkMode ? 0.05 : 0.08,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -28,
                  right: 24,
                  child: Container(
                    width: veryTight ? 64 : (tight ? 76 : 92),
                    height: veryTight ? 64 : (tight ? 76 : 92),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surface.withValues(
                        alpha: context.isDarkMode ? 0.05 : 0.08,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding,
                    verticalPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: veryTight ? 7 : (tight ? 8 : 10),
                                vertical: veryTight ? 3 : (tight ? 4 : 5),
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface.withValues(
                                  alpha: context.isDarkMode ? 0.08 : 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                context.tr('CURATED EDIT', 'مختارات منسقة'),
                                style: TextStyle(
                                  color: softTextColor,
                                  fontSize: veryTight ? 8 : (tight ? 9 : 10),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            SizedBox(height: veryTight ? 4 : (tight ? 6 : 10)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: textColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: veryTight
                                              ? 18
                                              : (tight
                                                    ? 22
                                                    : (compact ? 26 : null)),
                                          height: 1,
                                        ),
                                  ),
                                  SizedBox(
                                    height: veryTight ? 2 : (tight ? 4 : 6),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        subtitle,
                                        maxLines: veryTight ? 1 : 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: softTextColor,
                                          fontSize: veryTight
                                              ? 11
                                              : (tight ? 12 : 13),
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: actionHeight,
                              child: FilledButton(
                                onPressed: onTap,
                                style: FilledButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: colors.surface,
                                  foregroundColor: colors.primaryText,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: veryTight
                                        ? 10
                                        : (tight ? 12 : 14),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: Text(
                                  context.tr('Shop Now', 'تسوق الآن'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: veryTight
                                        ? 10
                                        : (tight ? 11 : 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: veryTight ? 8 : (tight ? 10 : 12)),
                      _BannerAccentPanel(
                        isDarkMode: context.isDarkMode,
                        textColor: textColor,
                        softTextColor: softTextColor,
                        strokeColor: accentStroke,
                        compact: compact,
                        tight: tight,
                        veryTight: veryTight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BannerAccentPanel extends StatelessWidget {
  const _BannerAccentPanel({
    required this.isDarkMode,
    required this.textColor,
    required this.softTextColor,
    required this.strokeColor,
    required this.compact,
    required this.tight,
    required this.veryTight,
  });

  final bool isDarkMode;
  final Color textColor;
  final Color softTextColor;
  final Color strokeColor;
  final bool compact;
  final bool tight;
  final bool veryTight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: veryTight ? 64 : (tight ? 74 : (compact ? 82 : 92)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              width: veryTight ? 40 : (tight ? 48 : (compact ? 54 : 62)),
              height: veryTight ? 42 : (tight ? 54 : (compact ? 62 : 78)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: strokeColor),
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? const [Color(0xFF9FB5CC), Color(0xFF536A83)]
                      : const [Color(0xFFF5D5BF), Color(0xFFD98C78)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: veryTight ? 7 : (tight ? 8 : 10),
              vertical: veryTight ? 5 : (tight ? 6 : 8),
            ),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: isDarkMode ? 0.08 : 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: strokeColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('UP TO', 'حتى'),
                  style: TextStyle(
                    color: softTextColor,
                    fontSize: veryTight ? 7 : (tight ? 8 : 9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('40% OFF', 'خصم 40%'),
                  maxLines: 1,
                  style: TextStyle(
                    color: textColor,
                    fontSize: veryTight ? 9 : (tight ? 11 : 13),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

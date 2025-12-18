import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class DataWidget extends StatelessWidget implements PreferredSizeWidget {
  const DataWidget({
    super.key,
    required this.previousDay,
    required this.nextDay,
    required this.date,
    this.onTodayPressed,
    this.onCalendarPressed,
  });

  final void Function() previousDay;
  final void Function() nextDay;
  final DateTime date;
  final void Function()? onTodayPressed;
  final void Function()? onCalendarPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now().day;

    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _todayButton(theme: theme, day: today, context: context),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: previousDay, // Corrigido: era nextDay
                    icon: const Icon(Symbols.arrow_left),
                  ),
                  const SizedBox(width: 8),
                  Text(DateFormat('d/MMM', 'pt_BR').format(date)),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: nextDay,
                    icon: const Icon(Symbols.arrow_right),
                  ),
                ],
              ),
              IconButton.filled(
                onPressed: onCalendarPressed ?? () {},
                icon: const Icon(Symbols.calendar_today),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _todayButton({
    required ThemeData theme,
    required int day,
    required BuildContext context,
  }) {
    return IconButton(
      onPressed: onTodayPressed ?? () {},
      icon: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/calendar-light.svg',
            width: MediaQuery.of(context).size.width * 0.1, // 10% da largura
            fit: BoxFit.contain,
          ),
          Positioned(
            top: 9,
            child: Text(
              day.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

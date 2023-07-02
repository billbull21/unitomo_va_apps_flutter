import 'package:flutter/material.dart';

class KeyValueComponent extends StatelessWidget {

  final String keyString;
  final String value;
  final bool noMargin;

  const KeyValueComponent({
    Key? key,
    required this.keyString,
    required this.value,
    this.noMargin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Text(keyString,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        if (!noMargin)
          const SizedBox(
            height: 8,
          ),
      ],
    );
  }
}

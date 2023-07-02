import 'package:flutter/material.dart';

import '../../utils/dropdown_overlay.dart';

class OutlinedDropdownComponent extends StatelessWidget {

  final bool enabled;
  final String label;
  final String? hint;
  final String keyName;
  final Map? selectedData;
  final List<Map> dataList;
  final void Function(Map val) onSelected;
  final VoidCallback? onWidgetTap;
  final String error;

  const OutlinedDropdownComponent({
    Key? key,
    this.enabled = true,
    this.label = "",
    this.hint,
    required this.keyName,
    required this.selectedData,
    required this.dataList,
    required this.onSelected,
    this.onWidgetTap,
    this.error = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
            style: textTheme.titleMedium,
          ),
          const SizedBox(
            height: 4,
          ),
        ],
        DropdownOverlay<Map>(
          value: selectedData,
          dataList: dataList,
          enabled: enabled,
          onWidgetTap: onWidgetTap,
          itemBuilder: (ctxOver, data) {
            return ListTile(
              onTap: () {
                onSelected(data);
                FocusScope.of(ctxOver).unfocus();
              },
              title: Text("${data![keyName] ?? "-"}"),
            );
          },
          builder: (ctx, data, isOpen, hasFocus) {
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              height: 55,
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: Text(selectedData != null ? selectedData![keyName] : hint ?? "pilih salah satu...",
                      style: TextStyle(
                        color: enabled ? selectedData != null ? null : Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: enabled ? Colors.grey.shade600 : Colors.grey.shade300,
                  )
                ],
              ),
            );
          },
        ),
        if (error.isNotEmpty)
          Text("*$error",
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}

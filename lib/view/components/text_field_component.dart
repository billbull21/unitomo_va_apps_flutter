import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/thousand_separator_input_formatter.dart';

class TextFieldComponent extends StatefulWidget {

  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final bool readonly;
  final bool isEnabled;
  final bool isNum;
  final bool isNumWithoutCurrency;
  final String maxPercentage;
  final bool isPercentage;
  final bool isTextArea;
  final bool obscureText;
  final EdgeInsets? margin;
  final Widget? suffixWidget;
  final TextAlign textAlign;
  final List<TextInputFormatter> inputFormatters;

  // final Function onEditingComplete;
  final Function(String val)? onChanged;
  final bool showError;
  final String error;

  const TextFieldComponent({
    Key? key,
    this.focusNode,
    this.controller,
    this.label = "",
    this.hint,
    this.obscureText = false,
    this.readonly = false,
    this.isEnabled = true,
    this.isNum = false,
    this.isNumWithoutCurrency = false,
    this.isPercentage = false,
    this.maxPercentage = "100",
    this.onChanged,
    this.isTextArea = false,
    this.suffixWidget,
    this.margin,
    this.showError = true,
    this.error = "",
    this.textAlign = TextAlign.start,
    this.inputFormatters = const [],
  }) : super(key: key);

  @override
  State<TextFieldComponent> createState() => _TextFieldComponentState();
}

class _TextFieldComponentState extends State<TextFieldComponent> {

  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode?.dispose();
    // widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(widget.label,
            style: textTheme.titleMedium,
          ),
          const SizedBox(
            height: 4,
          ),
        ],
        GestureDetector(
          onTap: !widget.readonly && widget.isEnabled ? () {
            if (!(_focusNode?.hasFocus ?? false)) {
              FocusScope.of(context).requestFocus(_focusNode);
            }
          } : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: widget.isEnabled ? widget.error.isNotEmpty ? Colors.red : Colors.grey.shade600 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            height: widget.isTextArea ? null : 55,
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: widget.controller,
                    decoration: InputDecoration.collapsed(
                      hintText: widget.hint,
                      hintStyle: textTheme.bodyLarge?.copyWith(
                        color: widget.isEnabled ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                      filled: false,
                    ),
                    maxLines: widget.isTextArea ? null : 1,
                    // onEditingComplete: onEditingComplete,
                    onChanged: (val) {
                      if (widget.controller != null) {
                        if (widget.isNum || widget.isPercentage) {
                          if (val.isEmpty) {
                            widget.controller!.text = "0";
                            widget.controller!.selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: widget.controller!.text.length,
                              ),
                            );
                          } else if (val.isNotEmpty && val.length == 2 && val.substring(0, 1) == "0") {
                            widget.controller!.text = val.substring(1);
                            widget.controller!.selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: widget.controller!.text.length,
                              ),
                            );
                          } else if (widget.isPercentage && num.parse(val.replaceAll(",", "")) > num.parse(widget.maxPercentage)) {
                            widget.controller!.text = widget.maxPercentage;
                            widget.controller!.selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: widget.controller!.text.length,
                              ),
                            );
                          } else {
                            if (widget.onChanged != null) widget.onChanged!(val);
                          }
                        } else {
                          if (widget.onChanged != null) widget.onChanged!(val);
                        }
                      } else {
                        if (widget.onChanged != null) widget.onChanged!(val);
                      }
                    },
                    keyboardType: widget.isTextArea
                        ? TextInputType.multiline
                        : widget.isNum || widget.isPercentage
                            ? TextInputType.number
                            : TextInputType.text,
                    inputFormatters: widget.isNum || widget.isPercentage
                        ? widget.isNumWithoutCurrency
                            ? [FilteringTextInputFormatter.allow(RegExp(r"\d")), ...widget.inputFormatters]
                            : [
                                FilteringTextInputFormatter.allow(RegExp(r"[\d.,]")),
                                ThousandsSeparatorInputFormatter(),
                                ...widget.inputFormatters,
                              ]
                        : [...widget.inputFormatters],
                    textCapitalization: TextCapitalization.characters,
                    readOnly: widget.readonly,
                    enabled: widget.isEnabled,
                    obscureText: widget.obscureText,
                    textAlign: widget.textAlign,
                  ),
                ),
                if (widget.suffixWidget != null) ...[
                  const SizedBox(
                    width: 8,
                  ),
                  widget.suffixWidget!,
                ]
              ],
            ),
          ),
        ),
        if (widget.showError && widget.error.isNotEmpty)
          Text("*${widget.error}",
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}

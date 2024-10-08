import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';
import 'package:flutter_jsonschema_builder/src/models/property_schema.dart';

import 'package:flutter_jsonschema_builder/src/utils/date_text_input_json_formatter.dart';

class DateJFormField extends PropertyFieldWidget<DateTime> {
  const DateJFormField({
    super.key,
    required super.property,
    required super.onSaved,
    super.onChanged,
    super.customValidator,
  });

  @override
  _DateJFormFieldState createState() => _DateJFormFieldState();
}

class _DateJFormFieldState
    extends PropertyFieldState<DateTime, DateJFormField> {
  final txtDateCtrl = MaskedTextController(mask: '0000-00-00');
  DateFormat formatter = DateFormat(dateFormatString);

  bool get isDateTime => widget.property.format == PropertyFormat.dateTime;

  @override
  void initState() {
    super.initState();
    if (isDateTime) {
      txtDateCtrl.updateMask('0000-00-00 00:00:00');
      formatter = DateFormat(dateTimeFormatString);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final defaultValue = super.getDefaultValue(parse: false) as String?;
      if (defaultValue != null && DateTime.tryParse(defaultValue) != null)
        txtDateCtrl.updateText(defaultValue);
    });
  }

  DateTime parseDate() {
    return formatter.tryParse(txtDateCtrl.text) ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final uiConfig = WidgetBuilderInherited.of(context).uiConfig;
    final dateIcon = IconButton(
      icon: const Icon(Icons.date_range_outlined),
      onPressed: enabled ? _openCalendar : null,
    );

    return WrapFieldWithLabel(
      property: widget.property,
      child: TextFormField(
        key: Key(widget.property.idKey),
        controller: txtDateCtrl,
        keyboardType: TextInputType.phone,
        autofocus: widget.property.uiSchema.autoFocus,
        enableSuggestions: widget.property.uiSchema.autoComplete,
        validator: (value) {
          if (widget.property.requiredNotNull &&
              (value == null || value.isEmpty)) {
            return uiConfig.localizedTexts.required();
          }
          if (widget.customValidator != null)
            return widget.customValidator!(value);
          if (value != null &&
              value.isNotEmpty &&
              formatter.tryParse(value) == null)
            return uiConfig.localizedTexts.invalidDate();

          return null;
        },
        // inputFormatters: [DateTextInputJsonFormatter()],
        readOnly: readOnly,
        enabled: enabled,
        style: readOnly ? const TextStyle(color: Colors.grey) : uiConfig.label,
        onSaved: (value) {
          if (value != null && value.isNotEmpty)
            widget.onSaved(formatter.parse(value));
        },
        onChanged: enabled
            ? (value) {
                try {
                  if (widget.onChanged != null &&
                      DateTime.tryParse(value) != null)
                    widget.onChanged!(formatter.parse(value));
                } catch (e) {
                  return;
                }
              }
            : null,
        decoration: uiConfig.inputDecoration(widget.property).copyWith(
              hintText: formatter.pattern!.toUpperCase(),
              suffixIcon: isDateTime
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        dateIcon,
                        IconButton(
                          icon: const Icon(Icons.access_time_rounded),
                          onPressed: enabled ? _openTime : null,
                        ),
                      ],
                    )
                  : dateIcon,
            ),
      ),
    );
  }

  void _openCalendar() async {
    DateTime tempDate = parseDate();
    final defaultYearsRange = [1900, 2099];
    List<int> yearsRange =
        widget.property.uiSchema.yearsRange ?? defaultYearsRange;
    if (yearsRange.isEmpty) yearsRange = defaultYearsRange;
    yearsRange.sort();
    final firstDate = DateTime(yearsRange.first);
    final lastDate = DateTime(
      yearsRange.last == yearsRange.first
          ? yearsRange.last + 1
          : yearsRange.last,
    );
    if (lastDate.isBefore(tempDate) || firstDate.isAfter(tempDate)) {
      tempDate = lastDate;
    }

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: tempDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: widget.property.uiSchema.help,
    );
    if (date == null) return;
    date = date.copyWith(
      hour: tempDate.hour,
      minute: tempDate.minute,
      second: tempDate.second,
    );
    txtDateCtrl.text = formatter.format(date);
    widget.onSaved(date);
  }

  void _openTime() async {
    late DateTime date = parseDate();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
      helpText: widget.property.uiSchema.help,
    );
    if (time == null) return;
    // TODO: seconds
    date = date.copyWith(hour: time.hour, minute: time.minute);
    txtDateCtrl.text = formatter.format(date);
    widget.onSaved(date);
  }
}

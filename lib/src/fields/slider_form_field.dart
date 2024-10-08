import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/flutter_jsonschema_builder.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';
import 'package:flutter_jsonschema_builder/src/models/models.dart';

class SliderJFormField extends PropertyFieldWidget<num> {
  const SliderJFormField({
    super.key,
    required super.property,
    required super.onSaved,
    super.onChanged,
    super.customValidator,
  });

  @override
  _SliderJFormFieldState createState() => _SliderJFormFieldState();
}

class _SliderJFormFieldState extends PropertyFieldState<num, SliderJFormField> {
  late List<num> values;

  @override
  void initState() {
    super.initState();
    values = property.enumm?.cast() ?? property.numberProperties.options();
  }

  @override
  Widget build(BuildContext context) {
    final uiConfig = WidgetBuilderInherited.of(context).uiConfig;
    inspect(property);

    return FormField<num>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: super.getDefaultValue(),
      onSaved: (newValue) {
        widget.onSaved(newValue);
      },
      validator: (value) {
        if (widget.customValidator != null)
          return widget.customValidator!(value);

        return null;
      },
      enabled: enabled,
      builder: (field) {
        final value = field.value?.toDouble() ?? values.first.toDouble();
        return WrapFieldWithLabel(
          property: property,
          ignoreFieldLabel: uiConfig.labelPosition != LabelPosition.table,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(value.toString()),
                  Expanded(
                    child: Slider(
                      key: Key(property.idKey),
                      label: value.toString(),
                      value: value,
                      min: values.first.toDouble(),
                      max: values.last.toDouble(),
                      divisions: values.length - 1,
                      onChanged: (double value) {
                        final v = property.type == SchemaType.integer
                            ? value.round()
                            : value;
                        field.didChange(v);
                        widget.onChanged!(v);
                      },
                    ),
                  ),
                ],
              ),
              if (field.hasError) CustomErrorText(text: field.errorText!),
            ],
          ),
        );
      },
    );
  }
}

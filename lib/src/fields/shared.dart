import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/models/json_form_schema_style.dart';
import 'package:flutter_jsonschema_builder/src/models/property_schema.dart';

class CustomErrorText extends StatelessWidget {
  const CustomErrorText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Text(
        text,
        style: WidgetBuilderInherited.of(context).uiConfig.error,
      ),
    );
  }
}

class WrapFieldWithLabel extends StatelessWidget {
  const WrapFieldWithLabel({
    super.key,
    required this.property,
    required this.child,
    this.ignoreFieldLabel = false,
  });

  final SchemaProperty property;
  final Widget child;
  final bool ignoreFieldLabel;

  @override
  Widget build(BuildContext context) {
    final directionality = Directionality.of(context);
    final uiConfig = WidgetBuilderInherited.of(context).uiConfig;

    if (uiConfig.fieldWrapperBuilder != null) {
      final wrapped = uiConfig.fieldWrapperBuilder!(
        FieldWrapperParams(
          property: property,
          input: child,
        ),
      );
      if (wrapped != null) return wrapped;
    }
    // configured in the field itself
    final showLabel = ignoreFieldLabel ||
        uiConfig.labelPosition != LabelPosition.fieldInputDecoration &&
            uiConfig.labelPosition != LabelPosition.table;
    if (!showLabel) return child;

    final labelText = uiConfig.labelText(property);
    final label = Text(
      labelText,
      style: uiConfig.label,
    );
    final mappedChild = uiConfig.labelPosition == LabelPosition.top
        ? child
        : Expanded(child: child);
    final space = uiConfig.labelPosition == LabelPosition.top
        ? null
        : const SizedBox(width: 20);

    return Flex(
      crossAxisAlignment: CrossAxisAlignment.center,
      direction: uiConfig.labelPosition == LabelPosition.top
          ? Axis.vertical
          : Axis.horizontal,
      children: directionality == TextDirection.rtl
          ? [mappedChild, if (space != null) space, label]
          : [label, if (space != null) space, mappedChild],
    );
  }
}

class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final uiConfig = WidgetBuilderInherited.of(context).uiConfig;

    if (uiConfig.formSectionBuilder != null) {
      return uiConfig.formSectionBuilder!(child);
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: (DividerTheme.of(context).color ??
                    Theme.of(context).dividerColor)
                .withOpacity(0.2),
          ),
        ),
      ),
      margin: const EdgeInsets.only(top: 7),
      padding: const EdgeInsets.only(left: 7),
      child: child,
    );
  }
}

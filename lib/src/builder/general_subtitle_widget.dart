import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/models/models.dart';

class GeneralSubtitle extends StatelessWidget {
  const GeneralSubtitle({
    super.key,
    required this.title,
    this.description,
    this.mainSchemaTitle,
    this.mainSchemaDescription,
  });

  final String title;
  final String? description, mainSchemaTitle, mainSchemaDescription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        if (mainSchemaTitle != title && title != kNoTitle) ...[
          Text(
            title,
            style: WidgetBuilderInherited.of(context).uiConfig.subtitle,
          ),
          const Divider(),
        ],
        if (description != null && description != mainSchemaDescription)
          Text(
            description!,
            style: WidgetBuilderInherited.of(context).uiConfig.description,
          ),
      ],
    );
  }
}

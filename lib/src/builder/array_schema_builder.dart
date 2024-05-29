import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/flutter_jsonschema_builder.dart';
import 'package:flutter_jsonschema_builder/src/builder/general_subtitle_widget.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';
import 'package:flutter_jsonschema_builder/src/models/models.dart';

class ArraySchemaBuilder extends StatefulWidget {
  const ArraySchemaBuilder({
    super.key,
    required this.mainSchema,
    required this.schemaArray,
  });
  final Schema mainSchema;
  final SchemaArray schemaArray;

  @override
  State<ArraySchemaBuilder> createState() => _ArraySchemaBuilderState();
}

class _ArraySchemaBuilderState extends State<ArraySchemaBuilder> {
  @override
  Widget build(BuildContext context) {
    final widgetBuilderInherited = WidgetBuilderInherited.of(context);

    final widgetBuilder = FormField(
      validator: (_) {
        if (widget.schemaArray.required && widget.schemaArray.items.isEmpty)
          return widgetBuilderInherited.localizedTexts.required();
        return null;
      },
      onSaved: (_) {
        if (widget.schemaArray.items.isEmpty) {
          widgetBuilderInherited.updateObjectData(
            widgetBuilderInherited.data,
            widget.schemaArray.idKey,
            [],
          );
        }
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: double.infinity),
            GeneralSubtitle(
              title: widget.schemaArray.title,
              description: widget.schemaArray.description,
              mainSchemaTitle: widget.mainSchema.title,
              mainSchemaDescription: widget.mainSchema.description,
            ),
            ...widget.schemaArray.items.map((schemaLoop) {
              final index = widget.schemaArray.items.indexOf(schemaLoop);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (index >= 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: widgetBuilderInherited.uiConfig.removeItemBuilder !=
                            null
                        ? widgetBuilderInherited.uiConfig.removeItemBuilder!(
                            () => _removeItem(index),
                            widget.schemaArray.idKey,
                          )
                        : TextButton.icon(
                            onPressed: () => _removeItem(index),
                            icon: const Icon(Icons.remove),
                            label: Text(
                              widgetBuilderInherited.localizedTexts
                                  .removeItem(),
                            ),
                          ),
                  ),
                  FormFromSchemaBuilder(
                    mainSchema: widget.mainSchema,
                    schema: schemaLoop,
                  ),
                  if (widget.schemaArray.items.length > 1) const Divider(),
                  const SizedBox(height: 10),
                ],
              );
            }),
            if (field.hasError) CustomErrorText(text: field.errorText!),
          ],
        );
      },
    );

    return Column(
      children: [
        widgetBuilder,
        if (!widget.schemaArray.isArrayMultipleFile())
          Align(
            alignment: Alignment.centerRight,
            child: widgetBuilderInherited.uiConfig.addItemBuilder != null
                ? widgetBuilderInherited.uiConfig.addItemBuilder!(
                    _addItem,
                    widget.schemaArray.idKey,
                  )
                : TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: Text(
                      widgetBuilderInherited.localizedTexts.addItem(),
                    ),
                  ),
          ),
      ],
    );
  }

  void _addItem() {
    if (widget.schemaArray.items.isEmpty) {
      _addFirstItem();
    } else {
      _addItemFromFirstSchema();
    }

    setState(() {});
  }

  void _removeItem(int index) {
    setState(() {
      widget.schemaArray.items.removeAt(index);
    });
  }

  void _addFirstItem() {
    final itemsBaseSchema = widget.schemaArray.itemsBaseSchema;
    if (itemsBaseSchema is Map<String, dynamic>) {
      final newSchema = Schema.fromJson(
        itemsBaseSchema,
        id: '0',
        parent: widget.schemaArray,
      );

      widget.schemaArray.items.add(newSchema);
    } else {
      widget.schemaArray.items.addAll(
        (itemsBaseSchema as List).cast<Map<String, dynamic>>().map(
              (e) => Schema.fromJson(
                e,
                id: '0',
                parent: widget.schemaArray,
              ),
            ),
      );
    }
  }

  void _addItemFromFirstSchema() {
    final currentItems = widget.schemaArray.items;
    final newSchemaObject =
        currentItems.first.copyWith(id: currentItems.length.toString());

    currentItems.add(newSchemaObject);
  }
}

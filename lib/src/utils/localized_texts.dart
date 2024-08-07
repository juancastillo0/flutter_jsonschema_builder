import 'package:flutter_jsonschema_builder/src/models/array_schema.dart';
import 'package:flutter_jsonschema_builder/src/models/property_schema.dart';

class LocalizedTexts {
  const LocalizedTexts();

  String required() => 'Required';
  String minLength({required int minLength}) =>
      'Should not be shorter than $minLength characters';
  String select() => 'Select';
  String removeItem() => 'Remove item';
  String addItem() => 'Add item';
  String addFile() => 'Add file';
  String shouldBeUri() => 'Should be a valid URL';
  String submit() => 'Submit';

  String? numberPropertiesError(
    NumberProperties config,
    num value,
  ) {
    final errors = config.errors(value);
    final l = <String>[];
    if (errors.contains(NumberPropertiesError.multipleOf))
      l.add('The value must be a multiple of ${config.multipleOf}');
    if (errors.contains(NumberPropertiesError.minimum))
      l.add('The value must be greater than or equal to ${config.minimum}');
    if (errors.contains(NumberPropertiesError.exclusiveMinimum))
      l.add('The value must be greater than ${config.exclusiveMinimum}');
    if (errors.contains(NumberPropertiesError.maximum))
      l.add('The value must be less than or equal to ${config.maximum}');
    if (errors.contains(NumberPropertiesError.exclusiveMaximum))
      l.add('The value must be less than ${config.exclusiveMaximum}');
    return l.isEmpty ? null : l.join('\n');
  }

  String maxItemsTooltip(int i) => 'You can only add $i items';

  String? arrayPropertiesError(ArrayProperties config, List value) {
    final errors = config.errors(value);
    final l = <String>[];
    if (errors.contains(ArrayPropertiesError.minItems))
      l.add('You must add at least ${config.minItems} items');
    if (errors.contains(ArrayPropertiesError.maxItems))
      l.add('You can only add ${config.maxItems} items');
    if (errors.contains(ArrayPropertiesError.uniqueItems))
      l.add('Items must be unique');
    return l.isEmpty ? null : l.join('\n');
  }

  String invalidDate() => 'Invalid date';
}

import 'dart:convert';
import 'dart:developer';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/flutter_jsonschema_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LabelPosition labelPosition = LabelPosition.table;
  Object data = {};
  bool showUISchema = false;
  bool customUIConfig = false;
  late final textController = TextEditingController(text: json);
  String json = primitivesJsonSchema;
  String uiSchema = primitivesUiSchema;

  Future<List<XFile>?> defaultCustomFileHandler() async {
    await Future.delayed(const Duration(seconds: 3));

    final file1 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');
    final file2 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');
    final file3 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');

    return [file1, file2, file3];
  }

  JsonFormSchemaUiConfig customUiConfig() {
    return JsonFormSchemaUiConfig(
      labelPosition: labelPosition,
      // TODO: fieldWrapperBuilder vs padding and title with labelPosition
      fieldWrapperBuilder: (params) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: params.input,
      ),
      title: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      fieldTitle: const TextStyle(color: Colors.pink, fontSize: 12),
      submitButtonBuilder: (onSubmit) => TextButton.icon(
        onPressed: onSubmit,
        icon: const Icon(Icons.heart_broken),
        label: const Text('Custom Submit'),
      ),
      addItemBuilder: (onPressed, key) => TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.plus_one),
        label: const Text('Add Item'),
      ),
      addFileButtonBuilder: (onPressed, key) {
        if (['file', 'file3'].contains(key)) {
          return OutlinedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              minimumSize:
                  WidgetStateProperty.all(const Size(double.infinity, 40)),
              backgroundColor: WidgetStateProperty.all(
                const Color(0xffcee5ff),
              ),
              side: WidgetStateProperty.all(
                  const BorderSide(color: Color(0xffafd5ff))),
              textStyle: WidgetStateProperty.all(
                  const TextStyle(color: Color(0xff057afb))),
            ),
            child: Text('+ Agregar archivo $key'),
          );
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Material(
          child: JsonForm(
            jsonSchema: json,
            uiSchema: uiSchema,
            onFormDataSaved: (data) {
              inspect(data);
              setState(() {
                this.data = data;
              });
            },
            fileHandler: () => {
              'files': defaultCustomFileHandler,
              'file': () async {
                return [
                  XFile(
                    'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg',
                  )
                ];
              },
              '*': defaultCustomFileHandler
            },
            // customPickerHandler: () => {
            //   '*': (data) async {
            //     return showDialog(
            //       context: context,
            //       builder: (context) {
            //         return Scaffold(
            //           body: Container(
            //             margin: const EdgeInsets.all(20),
            //             child: Column(
            //               children: [
            //                 const Text('My Custom Picker'),
            //                 ListView.builder(
            //                   shrinkWrap: true,
            //                   itemCount: data.keys.length,
            //                   itemBuilder: (context, index) {
            //                     return ListTile(
            //                       title: Text(
            //                           data.values.toList()[index].toString()),
            //                       onTap: () => Navigator.pop(
            //                           context, data.keys.toList()[index]),
            //                     );
            //                   },
            //                 ),
            //               ],
            //             ),
            //           ),
            //         );
            //       },
            //     );
            //   }
            // },
            uiConfig: !customUIConfig
                ? JsonFormSchemaUiConfig(labelPosition: labelPosition)
                : customUiConfig(),
            customValidatorHandler: () => {
              'files': (value) {
                return null;
              }
            },
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    ToggleButtons(
                      constraints: const BoxConstraints.tightForFinite(
                        height: 30,
                        width: 100,
                      ),
                      onPressed: (index) => setState(() {
                        showUISchema = !showUISchema;
                        textController.text = showUISchema ? uiSchema : json;
                      }),
                      isSelected: [!showUISchema, showUISchema],
                      children: const [
                        Text('JsonSchema'),
                        Text('UISchema'),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            const Text('Examples: '),
                            ...FormExample.allExamples.map(
                              (e) => TextButton(
                                onPressed: () {
                                  setState(() {
                                    json = e.jsonSchema;
                                    uiSchema = e.uiSchema;
                                    textController.text =
                                        showUISchema ? uiSchema : json;
                                  });
                                },
                                child: Text(e.name),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TextFormField(
                    maxLines: 1000,
                    controller: textController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      try {
                        jsonDecode(value);
                        return null;
                      } catch (e) {
                        return 'Invalid JSON';
                      }
                    },
                    onChanged: (value) {
                      try {
                        jsonDecode(value);
                        setState(() {
                          if (showUISchema) {
                            uiSchema = value;
                          } else {
                            json = value;
                          }
                        });
                      } catch (_) {}
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Form Output',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(
                  height: 100,
                  child: SingleChildScrollView(
                    child: SelectableText(data.toString()),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 130,
                      child: CheckboxListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        visualDensity: VisualDensity.compact,
                        value: customUIConfig,
                        onChanged: (value) => setState(() {
                          customUIConfig = value == true;
                        }),
                        title: const Text('Custom UI Config'),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<LabelPosition>(
                        value: labelPosition,
                        decoration: const InputDecoration(
                          labelText: 'Label Position',
                        ),
                        items: LabelPosition.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            labelPosition = v!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: formWidget,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FormExample {
  const FormExample(this.name, this.jsonSchema, this.uiSchema);

  final String name;
  final String jsonSchema;
  final String uiSchema;

  static const primitivesExample =
      FormExample('primitives', primitivesJsonSchema, primitivesUiSchema);
  static const arrayExample = FormExample('array', arrayJsonSchema, '{}');
  static const arrayItemsExample =
      FormExample('arrayItems', arrayItemsJsonSchema, arrayItemsUISchema);
  static const nestedObjectExample =
      FormExample('nestedObject', nestedObjectJsonSchema, '{}');
  static const uiSchemaExample =
      FormExample('uiSchema', uiSchemaJsonSchema, uiSchemaUiSchema);
  static const oneOfExample = FormExample('oneOf', oneOfJsonSchema, '{}');

  static const allExamples = [
    primitivesExample,
    arrayExample,
    arrayItemsExample,
    nestedObjectExample,
    uiSchemaExample,
    oneOfExample,
  ];
}

const oneOfJsonSchema = '''
 {
  "title": "Form Title",
  "type": "object",
  "required": ["select"],
  "properties": {
    "files": {
      "title": "Multiple files",
      "type": "array",
      "items": {
        "type": "string",
        "format": "data-url"
      }
    },
    "select": {
      "title" : "Select your Cola",
      "type": "string",
      "description": "This is the select-description",
      "enum": [0,1,2,3,4],
      "enumNames": ["Vale 0","Vale 1","Vale 2","Vale 3","Vale 4"],
      "default": 3
    },
    "num": {
      "title": "Number Title",
      "type": "number",
      "default": 1
    },
    "bool": {
      "type": "boolean",
      "description": "This is a description for the boolean",
      "default": true
    },
    "nestedObjects": {
      "type": "array",
      "items": {
        "title" : "NestedObject",
        "type": "object",
        "required": ["arrayOfString"],
        "properties": {
          "arrayOfString": {
            "title" : "ArrayOfString",
            "type": "array",
            "items": { "type": "string" }
          },
          "nullableInteger": {
            "type": ["integer", "null"]
          }
        }
      }
    },
    "profession" :  {
      "title": "Ocupación o profesión",
      "type": "string",
      "default": "investor",
      "oneOf": [
        {
          "enum": ["trader"],
          "type": "string",
          "title": "Trader"
        },
        {
          "enum": ["investor"],
          "type": "string",
          "title": "Inversionista"
        },      
        {
          "enum": ["manager_officier"],
          "type": "string",
          "title": "Gerente / Director(a)"
        }
      ]
    }
  }
}
''';

const uiSchemaJsonSchema = '''{
  "type": "object",
  "properties": {
    "stringTop": {
      "type": "string"
    },
    "integerRange": {
      "type": "integer",
      "minimum": -3,
      "maximum": 5,
      "multipleOf": 2
    },
    "integerRadio": {
      "type": "integer",
      "minimum": -1,
      "maximum": 3
    },
    "enumValues": {
      "type": "string",
      "enum": ["n1", "n2", "n3"]
    },
    "arrayCheckbox": {
      "type": "array",
      "uniqueItems": true,
      "items": {
        "type": "string",
        "enum": ["n1", "n2", "n3"]
      }
    },
    "arrayString": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "object": {
      "type": "object",
      "properties": {
        "nameEnabled": {
          "type": "string"
        },
        "nameDisabled": {
          "type": "string",
          "default": "disabled default"
        },
        "boolReadOnly": {
          "type": "boolean",
          "default": true
        },
        "nameHidden": {
          "type": "string"
        }
      }
    }
  }
}''';

const uiSchemaUiSchema = '''{
  "ui:order": [
    "integerRadio",
    "stringTop",
    "integerRange",
    "arrayString",
    "enumValues",
    "arrayCheckbox",
    "object"
  ],
  "stringTop": {
    "ui:autoFocus": true,
    "ui:autoComplete": true,
    "ui:placeholder": "My Object Placeholder"
  },
  "integerRange": {
    "ui:widget": "range"
  },
  "integerRadio": {
    "ui:widget": "radio"
  },
  "object": {
    "ui:options": {
      "description": "My Description",
      "order": ["nameDisabled", "nameEnabled", "boolReadOnly"]
    },
    "ui:title": "My Object UI",
    "ui:help": "My Object Help",
    "nameDisabled": {
      "ui:disabled": true
    },
    "boolReadOnly": {
      "ui:readonly": true
    },
    "nameHidden": {
      "ui:emptyValue": "empty",
      "ui:hidden": true
    }
  },
  "arrayCheckbox": {
    "ui:widget": "checkboxes",
    "ui:inline": true,
    "ui:orderable": true,
    "ui:copyable": true
  },
  "arrayString": {
    "ui:orderable": true,
    "ui:copyable": true
  },
  "enumValues": {
    "ui:options": {
      "enumNames": ["n1", "n2", "n3"],
      "enumDisabled": ["n2"]
    }
  }
}''';

const arrayItemsJsonSchema = '''{
  "type": "object",
  "properties": {
    "arrayString": {
      "type": "array",
      "items": {
        "type": "string",
        "ui:options": {
          "help": "helper text"
        }
      }
    },
    "arrayNumber": {
      "type": "array",
      "items": {
        "type": "number"
      }
    },
    "arrayInteger": {
      "type": "array",
      "items": {
        "type": "integer"
      }
    },
    "arrayBoolean": {
      "type": "array",
      "items": {
        "type": "boolean"
      }
    },
    "arrayEnum": {
      "type": "array",
      "items": {
        "type": "string",
        "enum": ["a", "b", "c", "d"]
      }
    },
    "arrayEnumRadio": {
      "type": "array",
      "items": {
        "type": "integer",
        "enum": [2, 4, 6]
      }
    },
    "arrayDate": {
      "type": "array",
      "items": {
        "type": "string",
        "format": "date"
      }
    },
    "arrayDateTime": {
      "type": "array",
      "items": {
        "type": "string",
        "format": "date-time"
      }
    }
  }
}''';

const arrayItemsUISchema = '''{
  "arrayEnumRadio": {
    "items": {
      "ui:widget": "radio"
    }
  }
}''';

const nestedObjectJsonSchema = '''{
  "type": "object",
  "properties": {
    "object1": {
      "type": "object",
      "properties": {
        "objectNested": {
          "type": "object",
          "required": ["value"],
          "properties": {
            "valueNested": {
              "type": "boolean"
            },
            "value": {
              "type": "string",
              "minLength": 1,
              "maxLength": 2,
              "pattern": "^[a-b]+\$"
            }
          }
        }
      }
    },
    "object2": {
      "type": "object",
      "properties": {
        "value": {
          "type": "string",
          "default": "default",
          "minLength": 2
        }
      }
    }
  }
}''';

const arrayJsonSchema = '''{
  "type": "object",
  "properties": {
    "array": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "uniqueItems": true,
      "minItems": 2,
      "maxItems": 3
    },
    "arrayWithObjects": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "value": {
            "type": "boolean"
          },
          "value2": {
            "type": "boolean",
            "default": true
          }
        }
      }
    },
    "integer": {
      "type": "integer"
    }
  }
}''';

const primitivesJsonSchema = '''{
  "type": "object",
  "title": "My Form",
  "properties": {
    "string": {
      "type": "string",
      "title": "stringTitle"
    },
    "number": {
      "type": "number",
      "title": "numberTitle"
    },
    "integer": {
      "type": "integer",
      "title": "integerTitle"
    },
    "boolean": {
      "type": "boolean",
      "title": "booleanTitle"
    },
    "enum": {
      "type": "string",
      "title": "enumTitle",
      "enum": ["a", "b", "c", "d"]
    },
    "enumRadio": {
      "type": "integer",
      "title": "enumRadioTitle",
      "enum": [2, 4, 6]
    },
    "date": {
      "type": "string",
      "format": "date",
      "title": "dateTitle"
    },
    "dateTime": {
      "type": "string",
      "format": "date-time",
      "title": "dateTimeTitle"
    }
  }
}''';

const primitivesUiSchema = '''{
  "enumRadio": {
    "ui:widget": "radio"
  }
}''';

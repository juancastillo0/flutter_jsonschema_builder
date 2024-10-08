class UiSchemaData {
  final Map<String, Object?> _asJson = {};
  String? title;
  String? description;
  UiSchemaData? globalOptions;
  UiSchemaData? parent;
  final Map<String, UiSchemaData> children = {};

  ///
  /// General Options
  ///
  String? help;
  bool readOnly = false;
  bool disabled = false;
  bool hidden = false;
  bool hideError = false;

  ///
  /// String Options
  ///
  String? placeholder;
  String? emptyValue;
  bool autoFocus = false;
  bool autoComplete = false;

  ///
  /// Date Options
  ///
  List<int>? yearsRange; // TODO: negative values

  /// Date format MDY, DMY and YMD (default)
  String format = 'YMD';
  bool hideNowButton = false;
  bool hideClearButton = false;

  /// boolean: radio, select, checkbox (default)
  /// string: textarea, password, color, file
  /// number: updown, range, radio
  String? widget;

  /// With "widget=file" or "format=data-url": accept='.pdf'
  String? accept;

  /// displayed as text if is not empty
  List<String>? enumNames;
  List<String>? enumDisabled;
  List<String>? order;

  ///
  /// Array Options
  ///
  bool inline = false;
  bool addable = true;
  bool removable = true;
  bool orderable = true;
  bool copyable = true;
  UiSchemaData? get items => children['items'];

  Map<String, Object?> toJson() => {
        'ui:options': _asJson,
        for (final e in children.entries) e.key: e.value.toJson(),
      };

  void setUi(
    Map<String, dynamic> uiSchema, {
    required UiSchemaData? parent,
    bool fromOptions = false,
  }) {
    this.parent = parent ?? this.parent;
    // if (fromOptions) {
    //   final options = asJson['ui:options'] as Map<String, Object?>? ?? {};
    //   asJson['ui:options'] = options;
    //   options.addAll(uiSchema);
    // } else {
    //   asJson.addAll(uiSchema);
    // }
    uiSchema.forEach((key, data) {
      final split = key.split(':');
      final String k;
      if (fromOptions) {
        k = key;
      } else if (split.length == 2 && split.first == 'ui') {
        k = split.last;
        // } else if (data is Map<String, dynamic>) {
        //   final nested = nestedProperties[key] ?? UiSchemaData();
        //   nestedProperties[key] = nested;
        //   nested.setUi(data, fromOptions: false, parent: this);
        //   return;
      } else {
        return;
      }
      bool saveInJson = true;
      switch (k) {
        case "disabled":
          disabled = data as bool;
          break;
        // TODO: filePreview, label=false, type:password
        // rows/width
        case "autofocus":
          autoFocus = data as bool;
          break;
        case "autocomplete":
          autoComplete = data as bool;
          break;
        case "hideError":
          hideError = data as bool;
          break;
        case "enumDisabled":
          enumDisabled = (data as List).cast();
          break;
        case "enumNames":
          enumNames = (data as List).cast();
          break;
        case "emptyValue":
          emptyValue = data as String;
          break;
        case "title":
          title = data as String;
          break;
        case "description":
          description = data as String;
          break;
        case "help":
          help = data as String;
          break;
        case "placeholder":
          placeholder = data as String;
          break;
        case "readonly":
          readOnly = data as bool;
          break;
        case "hidden":
          hidden = data as bool;
          break;
        case "widget":
          // TODO: password, textarea, inputType:tel,email?
          widget = data as String;
          break;
        case "yearsRange":
          yearsRange = data as List<int>;
          break;
        case "format":
          format = data as String;
          break;
        case "hideNowButton":
          hideNowButton = data as bool;
          break;
        case "hideClearButton":
          hideClearButton = data as bool;
          break;
        case "order":
          order = List<String>.from(data);
          break;

        ///
        /// Array Properties
        ///
        case "addable":
          addable = data as bool;
          break;
        case "removable":
          removable = data as bool;
          break;
        case "orderable":
          orderable = data as bool;
          break;
        case "copyable":
          copyable = data as bool;
          break;
        case "options":
          setUi(data as Map<String, Object?>, fromOptions: true, parent: null);
          saveInJson = false;
          break;
        case "globalOptions":
          globalOptions ??= UiSchemaData();
          globalOptions!.setUi(data as Map<String, Object?>, parent: this);
          break;
        default:
          saveInJson = false;
      }
      if (saveInJson) {
        _asJson[k] = data;
      }
    });
  }
}

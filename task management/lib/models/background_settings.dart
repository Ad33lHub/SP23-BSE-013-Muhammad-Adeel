class BackgroundSettings {
  final String? imagePath;
  final int? backgroundColor;
  final bool useDefault;

  BackgroundSettings({
    this.imagePath,
    this.backgroundColor,
    this.useDefault = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'backgroundColor': backgroundColor,
      'useDefault': useDefault,
    };
  }

  factory BackgroundSettings.fromJson(Map<String, dynamic> json) {
    return BackgroundSettings(
      imagePath: json['imagePath'],
      backgroundColor: json['backgroundColor'],
      useDefault: json['useDefault'] ?? true,
    );
  }

  BackgroundSettings copyWith({
    String? imagePath,
    int? backgroundColor,
    bool? useDefault,
  }) {
    return BackgroundSettings(
      imagePath: imagePath ?? this.imagePath,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      useDefault: useDefault ?? this.useDefault,
    );
  }
}
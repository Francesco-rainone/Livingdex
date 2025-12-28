import 'package:flutter/material.dart';
import '../ui/components/core_components.dart';
import '../../../shared/core/app_fonts.dart';

/// Data model for entity metadata from AI analysis.
class Metadata {
  String name = '';
  String description = '';
  List<String> suggestedQuestions = [];
  String height = '';
  String weight = '';
  List<String> type = [];

  Metadata({
    required this.name,
    required this.description,
    required this.suggestedQuestions,
    required this.height,
    required this.weight,
    required this.type,
  });

  /// Creates [Metadata] from JSON. Handles both List and String for flexible parsing.
  factory Metadata.fromJson(Map<String, dynamic> jsonMap) {
    List<String> suggestedQuestions = [];
    if (jsonMap['suggestedQuestions'] is List) {
      suggestedQuestions = List<String>.from(jsonMap['suggestedQuestions']);
    } else if (jsonMap['suggestedQuestions'] is String) {
      suggestedQuestions = [jsonMap['suggestedQuestions'] as String];
    }

    List<String> typeList = [];
    if (jsonMap['type'] is List) {
      typeList = List<String>.from(jsonMap['type']);
    } else if (jsonMap['type'] is String) {
      typeList = [jsonMap['type'] as String];
    }

    return Metadata(
      name: jsonMap['name'] ?? '',
      description: jsonMap['description'] ?? '',
      suggestedQuestions: suggestedQuestions,
      height: jsonMap['height'] ?? '',
      weight: jsonMap['weight'] ?? '',
      type: typeList,
    );
  }

  @override
  String toString() =>
      'Metadata(name: $name, description: $description, suggestedQuestions: $suggestedQuestions, height: $height, weight: $weight, type: $type)';

  /// Builds name and description widgets. Shows shimmer when [loading] is true.
  Widget buildNameAndDescription({bool loading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextCapsule(
          title: 'Nome',
          content: name.isNotEmpty ? name : 'Caricamento...',
          loading: loading,
          enableCopy: true,
          textStyle: AppFonts.title(),
        ),
        const SizedBox(height: 16),
        TextCapsule(
          title: 'Descrizione',
          content: description.isNotEmpty ? description : 'Caricamento...',
          loading: loading,
          shimmerHeight: 80,
          textStyle: AppFonts.accent(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

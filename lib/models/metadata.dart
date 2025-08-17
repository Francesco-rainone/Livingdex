import 'package:flutter/material.dart';
import '../ui/components/core_components.dart'; // Assicurati che i componenti siano importati
import '../../../shared/core/app_fonts.dart';

/// A data model class that holds metadata information for a specific entity.
///
/// This class is used to structure data such as name, description, physical
/// attributes, and suggested interaction prompts, typically fetched from an API.
/// It also includes methods for JSON serialization and for building UI components.
class Metadata {
  /// The name of the entity.
  String name = '';

  /// A detailed description of the entity.
  String description = '';

  /// A list of suggested questions that can be asked about the entity.
  /// Useful for populating a Q&A or chatbot interface.
  List<String> suggestedQuestions = [];

  /// The height of the entity, represented as a string (e.g., "1.8m").
  String height = '';

  /// The weight of the entity, represented as a string (e.g., "75kg").
  String weight = '';

  /// A list of types or categories the entity belongs to (e.g., ["Fire", "Flying"]).
  List<String> type = [];

  /// Creates a new instance of [Metadata].
  ///
  /// All parameters are required to ensure a complete metadata object.
  Metadata({
    required this.name,
    required this.description,
    required this.suggestedQuestions,
    required this.height,
    required this.weight,
    required this.type,
  });

  /// A factory constructor to create a [Metadata] instance from a JSON map.
  ///
  /// This method safely handles the deserialization of data from a
  /// `Map<String, dynamic>`, which is the typical format for JSON data in Dart.
  /// It provides default empty values for null fields and gracefully handles
  /// fields like `suggestedQuestions` and `type` that might be a single string
  /// instead of a list in the JSON source.
  factory Metadata.fromJson(Map<String, dynamic> jsonMap) {
    // Safely parse 'suggestedQuestions'. It can be a List or a single String.
    List<String> suggestedQuestions = [];
    if (jsonMap['suggestedQuestions'] is List) {
      suggestedQuestions = List<String>.from(jsonMap['suggestedQuestions']);
    } else if (jsonMap['suggestedQuestions'] is String) {
      // If it's a single string, wrap it in a list.
      suggestedQuestions = [jsonMap['suggestedQuestions'] as String];
    }

    // Safely parse 'type'. It can also be a List or a single String.
    List<String> typeList = [];
    if (jsonMap['type'] is List) {
      typeList = List<String>.from(jsonMap['type']);
    } else if (jsonMap['type'] is String) {
      // If it's a single string, wrap it in a list.
      typeList = [jsonMap['type'] as String];
    }

    // Return a new Metadata instance with the parsed data.
    // Use the null-coalescing operator (??) to provide default empty strings.
    return Metadata(
      name: jsonMap['name'] ?? '',
      description: jsonMap['description'] ?? '',
      suggestedQuestions: suggestedQuestions,
      height: jsonMap['height'] ?? '',
      weight: jsonMap['weight'] ?? '',
      type: typeList,
    );
  }

  /// Provides a developer-friendly string representation of the [Metadata] object.
  ///
  /// This is useful for debugging and logging purposes, allowing for easy inspection
  /// of the object's state.
  @override
  String toString() =>
      'Metadata(name: $name, description: $description, suggestedQuestions: $suggestedQuestions, height: $height, weight: $weight, type: $type)';

  /// Builds a Flutter widget to display the entity's name and description.
  ///
  /// This method encapsulates the UI logic for presenting the core metadata,
  /// using custom `TextCapsule` components for a consistent look and feel.
  ///
  /// The [loading] parameter can be set to `true` to display placeholder content
  /// and shimmer animations, providing a better user experience while data is being fetched.
  Widget buildNameAndDescription({bool loading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Displays the entity's name.
        TextCapsule(
          title: 'Nome',
          // Show placeholder text if loading or if the name is empty.
          content: name.isNotEmpty ? name : 'Caricamento...',
          loading: loading,
          enableCopy: true,
          textStyle: AppFonts.title(),
        ),
        const SizedBox(height: 16),

        // Displays the entity's description.
        TextCapsule(
          title: 'Descrizione',
          // Show placeholder text if loading or if the description is empty.
          content: description.isNotEmpty ? description : 'Caricamento...',
          loading: loading,
          shimmerHeight: 80, // Larger shimmer for a multi-line text block.
          textStyle: AppFonts.accent(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

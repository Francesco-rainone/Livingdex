import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/metadata.dart';
import '../../../shared/core/app_palette.dart';
import '../../../shared/core/app_fonts.dart';

/// A widget that displays a collection of tappable tags, often used for
/// categories or keywords.
class TagCapsule extends StatelessWidget {
  /// Creates a [TagCapsule] widget.
  const TagCapsule({
    required this.tags, // The list of tag strings to display.
    this.title, // An optional title displayed above the tags.
    required this.onTap, // The callback function executed when a tag is tapped.
    super.key,
  });

  /// An optional title displayed in a bold style above the tag collection.
  final String? title;

  /// The list of strings that will be rendered as individual tags.
  final List<String> tags;

  /// A callback function that is invoked when a user taps on a tag.
  /// It passes the string content of the tapped tag.
  final Function(String text) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Conditionally display the title if it's not null.
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        // The Wrap widget arranges its children in multiple horizontal or vertical
        // runs, wrapping to the next line if space is insufficient.
        Wrap(
          spacing: 8, // Horizontal space between tags.
          children: tags.map((tag) {
            return GestureDetector(
              onTap: () => onTap(tag),
              child: Chip(
                label: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: const Color(
                    0xffff3334), // Static background color for the tag.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// A styled container for displaying a block of text, with an optional title.
///
/// This widget can show a loading state with a shimmer effect and provides an
/// optional button to copy its content to the clipboard.
class TextCapsule extends StatelessWidget {
  /// Creates a [TextCapsule] widget.
  const TextCapsule({
    this.title, // An optional title for the content.
    required this.content, // The main text content to display.
    this.enableCopy = false, // Determines if the copy button is shown.
    this.loading = false, // Shows a shimmer effect if true.
    this.shimmerHeight = 60, // The height of the shimmer placeholder.
    this.textStyle, // Custom text style for the content.
    super.key,
  });

  /// An optional title displayed above the main content.
  final String? title;

  /// The primary text content of the capsule.
  final String content;

  /// If `true`, a copy icon button is displayed to copy the `content` to the clipboard.
  final bool enableCopy;

  /// If `true`, the widget displays a shimmer loading animation instead of content.
  final bool loading;

  /// The height of the shimmer effect container when `loading` is `true`.
  final double shimmerHeight;

  /// The custom [TextStyle] to be applied to both the title and content.
  /// If null, default styles are used.
  final TextStyle? textStyle;

  /// Asynchronously copies the `content` string to the system clipboard.
  void copyText() async {
    await Clipboard.setData(
      ClipboardData(text: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // A subtle shadow to give the capsule a floating effect.
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Display a shimmer animation while data is loading.
      child: loading
          ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: shimmerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          // Otherwise, display the content in a ListTile for clean alignment.
          : ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: title != null
                  ? Text(
                      title!,
                      style: textStyle ??
                          const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    )
                  : null,
              subtitle: Text(
                content,
                style: textStyle ??
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
              ),
              trailing: enableCopy
                  ? IconButton(
                      icon: const Icon(FontAwesomeIcons.copy),
                      onPressed: copyText,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
    );
  }
}

/// A card widget that aggregates and displays various pieces of metadata.
///
/// It uses other specialized widgets like [TextCapsule] and [StatisticCapsule]
/// to present information such as name, type, description, height, and weight
/// in a structured and visually appealing format.
class MetadataCard extends StatelessWidget {
  /// Creates a [MetadataCard] widget.
  const MetadataCard({
    required this.metadata, // The metadata object to display.
    required this.loading, // The loading state of the card.
    super.key,
  });

  /// When `true`, the card displays loading placeholders for its content.
  final bool loading;

  /// The [Metadata] object containing the information to be displayed.
  /// Can be null, in which case the card will render empty or loading states.
  final Metadata? metadata;

  @override
  Widget build(BuildContext context) {
    // Create a local reference to metadata for easier access and null checks.
    var localMetadata = metadata;

    return Card(
      color: AppPalette.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppPalette.cardColor),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the type tags if metadata and type list are available.
            if (localMetadata != null && localMetadata.type.isNotEmpty)
              Wrap(
                spacing: 8,
                children: localMetadata.type.map((type) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          Colors.blue, // Background color for the type badge.
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox.square(dimension: 16),
            // Capsule for the name, with copy enabled.
            TextCapsule(
              title: null, // Title is omitted for a cleaner look.
              content: localMetadata?.name ?? '',
              enableCopy: true,
              loading: loading,
              textStyle: AppFonts.title(),
            ),
            const SizedBox.square(dimension: 16),
            // A row containing statistics for height and mass.
            Row(
              children: [
                StatisticCapsule(
                  label: 'Statura', // Italian for 'Height'
                  value: localMetadata?.height ?? '',
                  textStyle: AppFonts.subtitle(),
                ),
                const SizedBox(width: 16),
                StatisticCapsule(
                  label: 'Massa', // Italian for 'Mass'
                  value: localMetadata?.weight ?? '',
                  textStyle: AppFonts.subtitle(),
                ),
              ],
            ),
            const SizedBox.square(dimension: 16),
            // Capsule for the description.
            TextCapsule(
              title: 'Descrizione', // Italian for 'Description'
              content: localMetadata?.description ?? '',
              loading: loading,
              shimmerHeight: 80, // Taller shimmer for a multi-line description.
              textStyle: AppFonts.body(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact widget for displaying a single statistic with a label and a value.
///
/// It's designed to be used within a [Row] and uses [Expanded] to fill
/// available horizontal space evenly with other sibling [StatisticCapsule] widgets.
class StatisticCapsule extends StatelessWidget {
  /// Creates a [StatisticCapsule] widget.
  const StatisticCapsule({
    required this.label, // The label for the statistic (e.g., "Height").
    required this.value, // The value of the statistic (e.g., "1.8m").
    this.textStyle, // Optional custom text style.
    super.key,
  });

  /// The text label describing the statistic.
  final String label;

  /// The string representation of the statistic's value.
  final String value;

  /// An optional [TextStyle] to apply to the label and value. If null,
  /// it falls back to predefined styles from [AppFonts].
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    // Expanded allows this widget to flexibly share space within a Row.
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppPalette.textColor
              .withAlpha(51), // Semi-transparent background.
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textStyle ?? AppFonts.subtitle(),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textStyle ?? AppFonts.body(),
            ),
          ],
        ),
      ),
    );
  }
}

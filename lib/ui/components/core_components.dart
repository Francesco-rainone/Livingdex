import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/metadata.dart';
import '../../../shared/core/app_palette.dart';
import '../../../shared/core/app_fonts.dart';

/// Displays tappable tag chips in a wrapping layout.
class TagCapsule extends StatelessWidget {
  const TagCapsule({
    required this.tags,
    this.title,
    required this.onTap,
    super.key,
  });

  /// Optional title above the tags.
  final String? title;

  /// List of tag strings to display.
  final List<String> tags;

  /// Callback invoked with the tapped tag's text.
  final Function(String text) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Wrap(
          spacing: 8,
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
                backgroundColor: const Color(0xffff3334),
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

/// Styled text container with optional title, copy button, and shimmer loading.
class TextCapsule extends StatelessWidget {
  const TextCapsule({
    this.title,
    required this.content,
    this.enableCopy = false,
    this.loading = false,
    this.shimmerHeight = 60,
    this.textStyle,
    super.key,
  });

  /// Optional title above content.
  final String? title;

  /// Main text content.
  final String content;

  /// Shows copy button if true.
  final bool enableCopy;

  /// Shows shimmer loading if true.
  final bool loading;

  /// Shimmer placeholder height.
  final double shimmerHeight;

  /// Custom text style for title and content.
  final TextStyle? textStyle;

  /// Copies content to clipboard.
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
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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

/// Card displaying metadata: name, type, description, height, weight.
class MetadataCard extends StatelessWidget {
  const MetadataCard({
    required this.metadata,
    required this.loading,
    super.key,
  });

  /// Shows loading placeholders when true.
  final bool loading;

  /// Metadata to display.
  final Metadata? metadata;

  @override
  Widget build(BuildContext context) {
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
            if (localMetadata != null && localMetadata.type.isNotEmpty)
              Wrap(
                spacing: 8,
                children: localMetadata.type.map((type) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
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
            TextCapsule(
              title: null,
              content: localMetadata?.name ?? '',
              enableCopy: true,
              loading: loading,
              textStyle: AppFonts.title(),
            ),
            const SizedBox.square(dimension: 16),
            Row(
              children: [
                StatisticCapsule(
                  label: 'Statura',
                  value: localMetadata?.height ?? '',
                  textStyle: AppFonts.subtitle(),
                ),
                const SizedBox(width: 16),
                StatisticCapsule(
                  label: 'Massa',
                  value: localMetadata?.weight ?? '',
                  textStyle: AppFonts.subtitle(),
                ),
              ],
            ),
            const SizedBox.square(dimension: 16),
            TextCapsule(
              title: 'Descrizione',
              content: localMetadata?.description ?? '',
              loading: loading,
              shimmerHeight: 80,
              textStyle: AppFonts.body(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact widget displaying a labeled statistic value.
class StatisticCapsule extends StatelessWidget {
  const StatisticCapsule({
    required this.label,
    required this.value,
    this.textStyle,
    super.key,
  });

  /// Statistic label (e.g., "Height").
  final String label;

  /// Statistic value (e.g., "1.8m").
  final String value;

  /// Optional custom text style.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppPalette.textColor.withAlpha(51),
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

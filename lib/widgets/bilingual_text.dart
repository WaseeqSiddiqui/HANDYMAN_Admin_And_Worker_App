import 'package:flutter/material.dart';

/// Widget to display bilingual text (English + Arabic)
class BilingualText extends StatelessWidget {
  final String english;
  final String arabic;
  final TextStyle? englishStyle;
  final TextStyle? arabicStyle;
  final TextAlign textAlign;
  final int? maxLines;

  const BilingualText({
    super.key,
    required this.english,
    required this.arabic,
    this.englishStyle,
    this.arabicStyle,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : textAlign == TextAlign.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          english,
          style: englishStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        ),
        Text(
          arabic,
          style: arabicStyle ?? englishStyle?.copyWith(
            fontSize: (englishStyle?.fontSize ?? 14) * 0.85,
            color: (englishStyle?.color ?? Colors.black).withOpacity(0.7),
          ),
          textAlign: textAlign,
          textDirection: TextDirection.rtl,
          maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
        ),
      ],
    );
  }
}

/// Compact bilingual text (one line)
class CompactBilingualText extends StatelessWidget {
  final String english;
  final String arabic;
  final TextStyle? style;

  const CompactBilingualText({
    super.key,
    required this.english,
    required this.arabic,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$english  •  $arabic',
      style: style,
    );
  }
}
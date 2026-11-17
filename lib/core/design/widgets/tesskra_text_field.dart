import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';
import 'package:impostor_tn/core/text/bidi.dart';

/// Text input (DESIGN_SYSTEM §5 "Text input"): label above, field 56 high,
/// radius 16, border 2.5, `bodyL`, helper and counter below, error state
/// with an alert icon. On carbon the border is `borderStrong`.
class TesskraTextField extends StatelessWidget {
  const TesskraTextField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.hint,
    this.helper,
    this.error,
    this.counter,
    this.onSubmitted,
    this.onChanged,
    this.inputFormatters,
    this.autofocus = false,
    this.privateInput = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final String? helper;

  /// Replaces the helper and turns the border red.
  final String? error;

  /// "{n} / 16", shown as an isolated left-to-right run at the end.
  final String? counter;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;

  /// Final guess (PRV-04): no autocorrect, no suggestions, not remembered by
  /// the keyboard.
  final bool privateInput;

  @override
  Widget build(BuildContext context) {
    final tokens = TesskraTokens.of(context);
    final c = tokens.colors;
    final errorColor = c.errorText!;
    final border = error != null
        ? errorColor
        : (tokens.isCarbon ? (c.borderStrong ?? c.border) : c.border);
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(TesskraRadii.md),
      borderSide: BorderSide(color: color, width: width),
    );
    final footer = error ?? helper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TesskraTypography.labelM.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: TesskraSpacing.s2),
        TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textInputAction: TextInputAction.done,
          autocorrect: !privateInput,
          enableSuggestions: !privateInput,
          enableIMEPersonalizedLearning: !privateInput,
          style: TesskraTypography.bodyL.copyWith(color: c.textPrimary),
          cursorColor: c.textPrimary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TesskraTypography.bodyL.copyWith(color: c.textSecondary),
            filled: true,
            fillColor: c.surface,
            isDense: true,
            constraints: const BoxConstraints(
              minHeight: TesskraSizes.inputHeight,
            ),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: TesskraSpacing.s4,
              vertical: TesskraSpacing.s3,
            ),
            enabledBorder: outline(border, TesskraBorders.standard),
            border: outline(border, TesskraBorders.standard),
            // Focus: 3 px ring in focusRing (DESIGN_SYSTEM §5).
            focusedBorder: outline(error != null ? errorColor : c.focusRing, 3),
          ),
        ),
        if (footer != null || counter != null) ...[
          const SizedBox(height: TesskraSpacing.s1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error != null) ...[
                TesskraIcon(
                  TesskraIcons.alert,
                  color: errorColor,
                  size: TesskraSizes.iconSmall,
                ),
                const SizedBox(width: TesskraSpacing.s1),
              ],
              Expanded(
                child: Text(
                  footer ?? '',
                  style: TesskraTypography.caption.copyWith(
                    color: error != null ? errorColor : c.textSecondary,
                  ),
                ),
              ),
              if (counter != null)
                Text(
                  ltrIsolate(counter!),
                  style: TesskraTypography.caption.copyWith(
                    color: c.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

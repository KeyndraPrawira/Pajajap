import 'package:flutter/material.dart';

class PedagangUi {
  static const Color darkGreen = Color(0xFF0B5D38);
  static const Color midGreen = Color(0xFF1E8B4B);
  static const Color lightGreen = Color(0xFF8BCF73);
  static const Color pageBackground = Color(0xFFF3F6F1);
  static const Color cardBackground = Colors.white;
  static const Color inputFill = Color(0xFFE8ECE7);
  static const Color inputBorder = Color(0xFFD0D8CF);
  static const Color textMain = Color(0xFF1D2B1F);
  static const Color textSubtle = Color(0xFF6B7B69);
  static const Color danger = Color(0xFFD94B45);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkGreen, midGreen, lightGreen],
  );

  static BoxDecoration heroDecoration({BorderRadius? borderRadius}) {
    return BoxDecoration(
      gradient: heroGradient,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: darkGreen.withOpacity(0.18),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration({double radius = 22}) {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: midGreen.withOpacity(0.08)),
      boxShadow: [
        BoxShadow(
          color: darkGreen.withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    Widget? prefixIcon,
    String? prefixText,
    String? suffixText,
    bool alignLabelWithHint = false,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: inputBorder),
    );

    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      prefixText: prefixText,
      suffixText: suffixText,
      filled: true,
      fillColor: inputFill,
      alignLabelWithHint: alignLabelWithHint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: textSubtle,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: textSubtle,
        fontWeight: FontWeight.w600,
      ),
      enabledBorder: border,
      border: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: midGreen, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: danger, width: 1.5),
      ),
    );
  }
}

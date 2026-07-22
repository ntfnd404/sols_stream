import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  group('AppTheme.fromVariant', () {
    test('dark variant registers both extensions', () {
      final theme = AppTheme.fromVariant(const DarkThemeVariant());

      expect(theme.brightness, Brightness.dark);
      expect(theme.extension<ColorThemeData>(), isNotNull);
      expect(theme.extension<TypographyTokens>(), isNotNull);
    });

    test('light variant registers both extensions', () {
      final theme = AppTheme.fromVariant(const LightThemeVariant());

      expect(theme.brightness, Brightness.light);
      expect(theme.extension<ColorThemeData>(), isNotNull);
      expect(theme.extension<TypographyTokens>(), isNotNull);
    });

    test('colorScheme reflects variant tokens', () {
      final dark = AppTheme.fromVariant(const DarkThemeVariant());
      final colors = dark.extension<ColorThemeData>()!;

      expect(dark.colorScheme.primary, colors.brand);
      expect(dark.colorScheme.surface, colors.bgCard);
      expect(dark.colorScheme.error, colors.error);
      expect(dark.scaffoldBackgroundColor, colors.bgScaffold);
    });
  });

  group('component theme wiring', () {
    final theme = AppTheme.fromVariant(const DarkThemeVariant());
    final colors = const DarkColorVariant().build();

    test('card theme uses bgCard fill + border', () {
      final card = theme.cardTheme;
      expect(card.color, colors.bgCard);
      expect((card.shape! as RoundedRectangleBorder).side.color, colors.border);
    });

    test('filled button uses brandDim fill + onBrand label', () {
      final style = theme.filledButtonTheme.style!;
      expect(style.backgroundColor?.resolve(<WidgetState>{}), colors.brandDim);
      expect(style.foregroundColor?.resolve(<WidgetState>{}), colors.onBrand);
    });

    test('outlined button uses textPrimary label + border side', () {
      final style = theme.outlinedButtonTheme.style!;
      expect(style.foregroundColor?.resolve(<WidgetState>{}), colors.textPrimary);
      expect(style.side?.resolve(<WidgetState>{})?.color, colors.border);
    });

    test('input focused border uses brand + AppBorderWidth.thick', () {
      final input = theme.inputDecorationTheme;
      expect(input.fillColor, colors.bgInput);

      final focused = input.focusedBorder! as OutlineInputBorder;
      expect(focused.borderSide.color, colors.brand);
      expect(focused.borderSide.width, AppBorderWidth.thick);
    });
  });

  group('ColorTheme.of / maybeOf', () {
    testWidgets('of returns data when wired via AppTheme', (tester) async {
      late ColorThemeData captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.fromVariant(const LightThemeVariant()),
          builder: AppTheme.builder,
          home: Builder(
            builder: (context) {
              captured = ColorTheme.of(context);

              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured.bgCard, const LightColorVariant().build().bgCard);
    });

    testWidgets('maybeOf returns null without a theme', (tester) async {
      ColorThemeData? captured;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              captured = ColorTheme.maybeOf(context);

              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });

    testWidgets('local override shadows global theme', (tester) async {
      late ColorThemeData captured;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.fromVariant(const DarkThemeVariant()),
          builder: AppTheme.builder,
          home: Builder(
            builder: (outer) {
              final overridden = ColorTheme.of(outer).copyWith(bgCard: const Color(0xFF123456));

              return ColorTheme(
                data: overridden,
                child: Builder(
                  builder: (inner) {
                    captured = ColorTheme.of(inner);

                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(captured.bgCard, const Color(0xFF123456));
    });
  });

  group('ColorThemeData.lerp', () {
    test('returns endpoints at t=0 and t=1', () {
      final a = const DarkColorVariant().build();
      final b = const LightColorVariant().build();

      expect(a.lerp(b, 0).bgCard, a.bgCard);
      expect(a.lerp(b, 1).bgCard, b.bgCard);
    });
  });

  group('TypographyTokens.lerp', () {
    test('returns endpoints at t=0 and t=1', () {
      final a = const DefaultTypographyVariant().build();
      final b = a.copyWith(bodyMedium: const TextStyle(fontSize: 99));

      expect(a.lerp(b, 0).bodyMedium.fontSize, a.bodyMedium.fontSize);
      expect(a.lerp(b, 1).bodyMedium.fontSize, 99);
    });
  });
}

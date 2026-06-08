# ui_kit

sols.stream design system — color tokens, typography, theme assembly.

No BLoC, no business logic, no business data. A small set of **product-semantic**
color slots (`live`, `videoBackground`) is intentional — they are themeable colors,
not behavior, kept here so all status/surface colors live in one schema.

---

## Architecture

Clean Figma 3-level token model:

```
Level 1 — Primitive    AppPalette     raw swatches (jade500, neutral850…)
                       AppSpacing     spacing scale
                       AppRadius      border-radius scale
                       AppBorderWidth stroke-width scale (thin, thick)
                       AppTextStyles  type scale (size, weight, height)
                       AppTypography  font family, OpenType features
                       Color/type primitives (AppPalette, AppTextStyles,
                       AppTypography) are used only in variant/theme assembly —
                       never in widgets. Layout primitives (AppSpacing, AppRadius,
                       AppBorderWidth) are used directly in widgets — layout metrics
                       are not themed per mode.

Level 2 — Semantic     ColorThemeData   themeable color slots (bgCard, brand…)
                       TypographyTokens complete text styles
                       Access via ColorTheme.of(context) / Theme.of(context).textTheme.

Level 3 — Component    Widget themes — one stateless builder per widget in
                       theme/component_themes/ (CardThemeBuilder,
                       FilledButtonThemeBuilder…). Each exposes a static
                       build(ColorThemeData) factory; AppTheme.fromVariant wires
                       them. Custom ui_kit component themes (AppButtonThemeData)
                       graduate into the same folder when needed.
```

"Invariant" colors (brand, error) are not a separate layer — they are semantic
tokens whose value happens to be the same in every mode.

**Where to use what:**
- Any color in a widget → `ColorTheme.of(context).bgCard` / `.brand` / `.error`
- Inside a color variant (mapping) → `AppPalette.neutral850`
- Spacing / radius in a widget → `AppSpacing.l` / `AppRadius.m` (not themeable — same in all modes)

Theme switching uses two complementary mechanisms:

| Mechanism | Role |
|-----------|------|
| `ThemeExtension<ColorThemeData>` | Stores tokens in `ThemeData`; participates in `AnimatedTheme` lerp |
| `ColorTheme extends InheritedTheme` | Distributes tokens; survives Navigator pushes via `wrap()`; enables local overrides |

---

## Quick start

```dart
MaterialApp.router(
  theme:     AppTheme.fromVariant(const LightThemeVariant()),
  darkTheme: AppTheme.fromVariant(const DarkThemeVariant()),
  themeMode: ThemeMode.system,
  builder:   AppTheme.builder, // required — wires ColorTheme/TypographyTheme
)
```

```dart
final colors = ColorTheme.of(context);

Container(
  color: colors.bgCard,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
  ),
)
```

Local override:
```dart
ColorTheme(
  data: ColorTheme.of(context).copyWith(bgCard: colors.bgElevated),
  child: SpecialPanel(),
)
```

---

## Semantic color tokens

| Token | Role |
|-------|------|
| `brand` / `brandLight` / `brandDim` | Brand color + hover/pressed shades |
| `onBrand` | Text/icon on a brand fill |
| `error` / `warning` / `live` | Status colors |
| `bgScaffold` | Outermost screen background |
| `bgCard` | Card / panel surface |
| `bgElevated` | Modals, bottom sheets |
| `bgInput` | Input field fill |
| `border` / `borderDim` | Default / subtle border |
| `textPrimary` / `textSecondary` / `textTertiary` / `textDisabled` | Text hierarchy |
| `videoBackground` | Letterbox behind video player |

---

## Accessibility (WCAG AA)

Contrast verified for both themes (normal text ≥ 4.5:1, large ≥ 3:1):

- All `textPrimary` / `textSecondary` pairs pass on their backgrounds.
- `textTertiary` light: uses `neutral550` (4.93:1) — `neutral500` failed at 3.26:1.
- Filled button: `brandDim` fill + white label = 5.40:1 (white on `brand` would be 3.08:1).
- `textDisabled` is below 4.5:1 by design — disabled text is exempt (WCAG 1.4.3).
- Do **not** use `brand` as small body text on light backgrounds (3.08:1) — it is a
  fill/large-accent color. Use it as fill with `onBrand`, or for large text only.

---

## Adding a new theme

Two new files, nothing else changes.

**1.** `theme/variants/color/solar_color_variant.dart` — map every slot from `AppPalette`:

```dart
final class SolarColorVariant implements ColorVariant {
  const SolarColorVariant();

  @override
  ColorThemeData build() => const ColorThemeData(
    brand: AppPalette.jade500, brandLight: AppPalette.jade400,
    brandDim: AppPalette.jade600, onBrand: AppPalette.neutral50,
    error: AppPalette.red500, warning: AppPalette.orange500, live: AppPalette.red600,
    bgScaffold: AppPalette.neutral900, bgCard: AppPalette.neutral850,
    bgElevated: AppPalette.neutral800, bgInput: AppPalette.neutral750,
    border: AppPalette.neutral700, borderDim: AppPalette.neutral710,
    textPrimary: AppPalette.neutral50, textSecondary: AppPalette.whiteAlpha70,
    textTertiary: AppPalette.whiteAlpha54, textDisabled: AppPalette.whiteAlpha38,
    videoBackground: AppPalette.neutral950,
  );
}
```

**2.** `theme/themes/solar_theme_variant.dart`:

```dart
final class SolarThemeVariant extends ThemeVariant {
  const SolarThemeVariant();

  @override Brightness   get brightness => Brightness.dark;
  @override ColorVariant get colors     => const SolarColorVariant();
}
```

**3.** `AppTheme.fromVariant(const SolarThemeVariant())`.

---

## Adding a new color token

1. Add the raw value to `AppPalette` if new.
2. Add the field to `ColorThemeData` (+ `copyWith` + `lerp`).
3. Add the value to `DarkColorVariant.build()` and `LightColorVariant.build()`.

Step 3 is compile-enforced (required params). Step 2's copyWith/lerp are not — do not skip.

---

## Component themes — builders

Widget themes (Card, FilledButton, OutlinedButton, input…) each live in their own
file under `theme/component_themes/` as a stateless builder — an
`abstract final class XxxThemeBuilder` exposing one `static build(ColorThemeData)`
factory. The file name matches the class (`card_theme_builder.dart` →
`CardThemeBuilder`) per the `prefer-match-file-name` rule. `AppTheme.fromVariant`
imports and calls each builder directly (no barrel — the only consumer is
`app_theme.dart`).

To theme another widget: add `<widget>_theme_builder.dart` with a
`XxxThemeBuilder.build(ColorThemeData)`, then import and wire it in
`AppTheme.fromVariant`.

Custom ui_kit component themes (a dedicated `AppButtonThemeData`) graduate into the
same folder only when a ui_kit component needs a **local override independent of
the global theme** — not before.

---

## File structure

```
lib/
  ui_kit.dart

  src/
    tokens/
      app_palette.dart            primitive color palette (+ {@template})
      app_spacing.dart            spacing scale
      app_radius.dart             border-radius scale
      app_border_width.dart       stroke-width scale
      app_typography.dart         font family, OpenType features
      app_text_styles.dart        type scale

    theme/
      app_theme.dart              AppTheme.fromVariant() + builder
      color_theme.dart            ColorThemeData + ColorTheme
      typography_theme.dart       TypographyTokens + TypographyTheme

      extensions/
        widget_state_extension.dart

      component_themes/           widget theme builders
        card_theme_builder.dart            CardThemeBuilder
        filled_button_theme_builder.dart   FilledButtonThemeBuilder
        outlined_button_theme_builder.dart OutlinedButtonThemeBuilder
        input_decoration_theme_builder.dart InputDecorationThemeBuilder

      themes/                     composite theme variants (app-facing)
        theme_variant.dart        ThemeVariant base
        dark_theme_variant.dart   DarkThemeVariant
        light_theme_variant.dart  LightThemeVariant

      variants/                   ingredients
        color/      color_variant + dark/light
        typography/ typography_variant + default

    components/                    [future] — ui_kit widgets
```

---

## Design decisions

**3-level model, no alias layer.** Primitives (`AppPalette`) → semantic
(`ColorThemeData`) → component. Variants map primitives directly. No `AppColors`
convenience layer — it caused primitive/alias mixing.

**`ThemeVariant` is `abstract class`** — new sub-variant getters ship with defaults; existing subclasses compile unchanged (OCP). **`ColorVariant` is `abstract interface class`** — every variant must implement the full mapping.

**`brand` lives in `ColorThemeData`.** The `ColorScheme.fromSeed` seed comes from `colorData.brand` — no separate `seedColor`. All color decisions in one place.

**No `==`/`hashCode` on token data.** Flutter's own theme data classes don't override `==`; reference equality (lifecycle tied to `ThemeData`) is correct.

**No fallback in `AppTheme.builder` (fail-fast).** Correct usage always has the
extensions. Misconfiguration surfaces at the first `ColorTheme.of()` with a clear
assert — no arbitrary fallback that hides the error.

**`AppTheme.builder` is a static method reference** — stable `Function`, no rebuild churn.

**`theme/extensions/` = Dart `extension` keyword files**, not `ThemeExtension<T>`.

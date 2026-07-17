// 配色には https://material-foundation.github.io/material-theme-builder/ を利用

String surfaceColorLight = "#f6fbf4";
String surfaceColorDark = "#0f1511";
String surfaceBrightColorLight = "#f6fbf4";
String surfaceBrightColorDark = "#353b36";
String surfaceContainerColorLight = "#eaefe8";
String surfaceContainerColorDark = "#1b211d";
String surfaceContainerLowColorLight = "#f0f5ee";
String surfaceContainerLowColorDark = "#171d19";
String surfaceContainerHighColorLight = "#e4eae3";
String surfaceContainerHighColorDark = "#262b27";
String primaryColorLight = "#296a48";
String primaryColorDark = "#92d5ab";
String onPrimaryColorLight = "#ffffff";
String onPrimaryColorDark = "#003920";
String secondaryColorLight = "#4e6355";
String secondaryColorDark = "#b5ccba";
String tertiaryColorLight = "#3b6471";
String tertiaryColorDark = "#a3cddc";
String primaryContainerColorLight = "#aef2c6";
String primaryContainerColorDark = "#075232";
String onPrimaryContainerColorLight = "#075232";
String onPrimaryContainerColorDark = "#adf2c6";
String secondaryContainerColorLight = "#d1e8d6";
String secondaryContainerColorDark = "#374b3e";
String onSecondaryContainerColorLight = "#374b3e";
String onSecondaryContainerColorDark = "#d1e8d6";
String tertiaryContainerColorLight = "#bfe9f8";
String tertiaryContainerColorDark = "#224c58";
String inverseSurfaceColorLight = "#2c322d";
String inverseSurfaceColorDark = "#dfe4dd";
String inverseOnSurfaceColorLight = "#edf2eb";
String inverseOnSurfaceColorDark = "#2c322d";
String outlineColorLight = "#717972";
String outlineColorDark = "#8a938b";
String outlineVariantColorLight = "#c0c9c0";
String outlineVariantColorDark = "#404942";
String errorColorLight = "#ba1a1a";
String errorColorDark = "#ffb4ab";
String errorContainerColorLight = "#ffdad6";
String errorContainerColorDark = "#93000a";
String onSurfaceColorLight = "#171d19";
String onSurfaceColorDark = "#dfe4dd";
String onSurfaceVariantColorLight = "#404942";
String onSurfaceVariantColorDark = "#c0c9c0";


color cSurface, cSurfaceBright, cPrimary, cSecondary, cTertiary, cPrimaryTransparent;
color cSurfaceContainer, cSurfaceContainerHigh, cSurfaceContainerLow, cPrimaryContainer, cSecondaryContainer, cTertiaryContainer;
color cError, cErrorContainer, cOutline, cOutlineVariant;
color cOnPrimary, cOnSurface, cOnSurfaceVariant, cOnSurfaceVariantTransparent, cOnPrimaryContainer, cOnSecondaryContainer;
color cInverseSurface, cInverseOnSurface;

void applyThemeColors() {
  if (isDarkTheme) {
    cSurface         = hexToColor(surfaceColorDark);
    cSurfaceBright   = hexToColor(surfaceBrightColorDark);
    cSurfaceContainer = hexToColor(surfaceContainerColorDark);
    cPrimary            = hexToColor(primaryColorDark);
    cOnPrimary          = hexToColor(onPrimaryColorDark);
    cSecondary          = hexToColor(secondaryColorDark);
    cTertiary           = hexToColor(tertiaryColorDark);
    cPrimaryContainer   = hexToColor(primaryContainerColorDark);
    cSurfaceContainerLow = hexToColor(surfaceContainerLowColorDark);
    cSurfaceContainerHigh = hexToColor(surfaceContainerHighColorDark);
    cOnPrimaryContainer = hexToColor(onPrimaryContainerColorDark);
    cSecondaryContainer = hexToColor(secondaryContainerColorDark);
    cOnSecondaryContainer = hexToColor(onSecondaryContainerColorDark);
    cTertiaryContainer  = hexToColor(tertiaryContainerColorDark);
    cOutline            = hexToColor(outlineColorDark);
    cOutlineVariant     = hexToColor(outlineVariantColorDark);
    cError              = hexToColor(errorColorDark);
    cErrorContainer     = hexToColor(errorContainerColorDark);
    cOnSurface          = hexToColor(onSurfaceColorDark);
    cOnSurfaceVariant   = hexToColor(onSurfaceVariantColorDark);
    cPrimaryTransparent = unhex("4d296a48");
    cOnSurfaceVariantTransparent = unhex("4d404942");
    cInverseSurface = hexToColor(inverseSurfaceColorDark);
    cInverseOnSurface = hexToColor(inverseOnSurfaceColorDark);
  } else {
    cSurface         = hexToColor(surfaceColorLight);
    cSurfaceBright   = hexToColor(surfaceBrightColorLight);
    cSurfaceContainer = hexToColor(surfaceContainerColorLight);
    cSurfaceContainerLow = hexToColor(surfaceContainerLowColorLight);
    cSurfaceContainerHigh = hexToColor(surfaceContainerHighColorLight);
    cPrimary            = hexToColor(primaryColorLight);
    cOnPrimary          = hexToColor(onPrimaryColorLight);
    cSecondary          = hexToColor(secondaryColorLight);
    cTertiary           = hexToColor(tertiaryColorLight);
    cPrimaryContainer   = hexToColor(primaryContainerColorLight);
    cOnPrimaryContainer = hexToColor(onPrimaryContainerColorLight);
    cSecondaryContainer = hexToColor(secondaryContainerColorLight);
    cOnSecondaryContainer = hexToColor(onSecondaryContainerColorLight);
    cTertiaryContainer  = hexToColor(tertiaryContainerColorLight);
    cOutline            = hexToColor(outlineColorLight);
    cOutlineVariant     = hexToColor(outlineVariantColorLight);
    cError              = hexToColor(errorColorLight);
    cErrorContainer     = hexToColor(errorContainerColorLight);
    cOnSurface          = hexToColor(onSurfaceColorLight);
    cOnSurfaceVariant   = hexToColor(onSurfaceVariantColorLight);
    cPrimaryTransparent = unhex("4d296a48");
    cOnSurfaceVariantTransparent = unhex("4d404942");
    cInverseSurface = hexToColor(inverseSurfaceColorLight);
    cInverseOnSurface = hexToColor(inverseOnSurfaceColorLight);
  }
}

color hexToColor(String hexStr) {
  String cleanHex = hexStr.replace("#", "");
  return unhex("FF" + cleanHex);
}

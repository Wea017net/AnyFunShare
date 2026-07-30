void drawScreenSettings() {
  pushStyle();
  noStroke();
  textAlign(LEFT, TOP);
  textFont(GenShinGothic_Medium);
  textSize(32);
  rectMode(CORNERS);
  fill(cSurfaceContainer);
  rect(0, 0, width, height - height * 0.92);
  fill(cOnSurface);
  text("設定", width - width * 0.95, height - height * 0.975);

  textFont(GenShinGothic_Regular);
  textSize(18);
  fill(cPrimary);
  text("表示", setCatX, setCatY);
  text("デバッグ", setCatX, setCatY + 210);
  text("アプリ情報", setCatX, setCatY + 334);

  drawOptionItemToggle(0, iconDarkMode, "ダークモード", "目に優しい暗い色を使用");
  drawSwitch(width * 0.86, setItemY + 30, isDarkTheme);

  drawOptionItemToggle(86, iconFlip2Front, "ウィンドウ位置を保持", "次回起動時に位置を復元");
  drawSwitch(width * 0.86, setItemY + 86 + 30, keepWindowPos);

  drawOptionItemToggle(210, iconDescription, "ログを保存", "data\\user\\logs に保存されます");
  drawSwitch(width * 0.86, setItemY + 210 + 30, saveLogFile);

  drawOptionItemToggle(334, iconInfo, "バージョン", appVersion);

  popStyle();
}

// 共通の判定領域
boolean isOptionItemToggleHovered(float posY) {
  return isMouseOver(0, setItemY + posY - 12, width, 86, CORNER);
}

// トグル式設定オプション
void drawOptionItemToggle(float posY, PImage iconName, String optionName, String optionDetail) {
  pushStyle();
  boolean hovered = isOptionItemToggleHovered(posY);

  if (hovered) {
    noStroke();
    rectMode(CORNER);
    fill(cOnSurfaceVariantTransparent);
    rect(0, setItemY + posY - 12, width, 86);
  }

  tint(cOnSurface);
  image(iconName, width * 0.062, setItemY + posY + 6, 48, 48);

  textSize(24);
  fill(cOnSurface);
  text(optionName, width * 0.062 + 72, setItemY + posY + 6);

  textSize(20);
  fill(cOnSurfaceVariant);
  text(optionDetail, width * 0.062 + 72, setItemY + posY + 38);

  popStyle();
}

void checkSettingsTap() {
  if (mouseButton != LEFT) return;

  if (isOptionItemToggleHovered(0)) {
    isDarkTheme = !isDarkTheme;
    applyThemeColors();
    saveSettings(false);
    return;
  }

  if (isOptionItemToggleHovered(86)) {
    keepWindowPos = !keepWindowPos;
    saveSettings(false);
    return;
  }

  if (isOptionItemToggleHovered(210)) {
    saveLogFile = !saveLogFile;
    saveSettings(false);
    return;
  }
}
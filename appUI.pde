void drawBottomTabBar() {
  pushStyle();
  textAlign(CENTER, CENTER);
  textSize(20);
  noStroke();
  rectMode(CORNERS);
  fill(cSurfaceContainer);
  rect(0, tBHeight, width, height); // タブバー背景
  imageMode(CENTER);
  rectMode(CENTER);

  drawTabIcon("Connect", "接続", width / 5, iconSensors, 4, false, null);
  drawTabIcon("Record", "記録", width / 2, iconChart, 0, true, iconChartSelected);
  drawTabIcon("Settings", "設定", width * 4 / 5, iconSettings, 0, true, iconSettingsSelected);

  popStyle();
  return;
}

void drawTabIcon(String tabName, String tabNameDisp, int tabPosX, PImage icon, int revIconSize, boolean hasFillIcon, PImage iconSelected) {
  pushStyle();
  imageMode(CENTER);
  rectMode(CENTER);
  if (currentTab == tabName) {
    fill(cPrimaryTransparent);
    rect(tabPosX, tBHeight + 36, 76, 42, 96);
    fill(cPrimary);
    text(tabNameDisp, tabPosX, tBHeight + 76);
    tint(cPrimary);
    if (hasFillIcon) {
      image(iconSelected, tabPosX, tBHeight + 36, 38 + revIconSize, 38 + revIconSize);
    } else {
      image(icon, tabPosX, tBHeight + 36, 38 + revIconSize, 38 + revIconSize);
    }
  } else {
    fill(cOnSurfaceVariant);
    text(tabNameDisp, tabPosX, tBHeight + 76);
    tint(cOnSurfaceVariant);
    image(icon, tabPosX, tBHeight + 36, 38 + revIconSize, 38 + revIconSize);
  }
  popStyle();
  return;
}

void drawRadioButton(float x, float y, int size, boolean isSelected) {
  pushStyle();
  noStroke();
  if (isSelected) {
    fill(unhex("00FFFFFF"));
    stroke(cPrimary);
    strokeWeight(2);
    circle(x, y, size);
    fill(cPrimary);
    noStroke();
    circle(x, y, size * 0.6);
  } else {
    fill(unhex("00FFFFFF"));
    stroke(cOnSurfaceVariant);
    strokeWeight(2);
    circle(x, y, size);
  }
  popStyle();
}

void drawTextBox(String textFieldTitle, float x, float y, float w, float h, int mode, String targetTextField) {
  pushStyle();
  noStroke();
  rectMode(CENTER);
  fill(cSurfaceBright);
  noStroke();

  if (textFieldTitle == activeTextFieldTitle) {
    stroke(cPrimary);      // ダイアログ表示中はインジケーターをPrimaryに
    strokeWeight(3);       // 線を少し太くする
  } else {
    stroke(cOutline);    // 通常時
    strokeWeight(2);       // 通常の太さ
  }

  // rectModeごとに分岐してボックス描画
  if (mode == CENTER) { 
    rect(x, y, w, h, 8);
  } else if (mode == CORNER) {
    rect(x + w / 2.0, y + h / 2.0, w, h, 8);
  }
  
  textSize(16);
  fill(cOnSurfaceVariant);
  textAlign(LEFT, TOP);
  if (mode == CENTER) {
    text(textFieldTitle, x - w / 2.0 + 12, y - h / 2.0 + 10);
  } else if (mode == CORNER) {
    text(textFieldTitle, x + 16, y - 8);
  }
  fill(cOnSurface);
  textSize(22);
  textAlign(LEFT, CENTER);
  if (mode == CENTER) {
    text(targetTextField, x - w / 2.0 + 16, y + 10);
  } else {
    text(targetTextField, x, y);
  }
  popStyle();
  return;
}

void drawPopupBox(String textFieldTitle, float x, float y, float w, float h, int mode, String targetTextField) {
  pushStyle();
  noStroke();
  rectMode(CENTER);
  fill(cSurfaceBright);
  stroke(cOutline);    // 通常時
  strokeWeight(2);
  if (mode == CENTER) {
    rect(x, y, w, h, 8);
    // line(x - w / 2.0 + 2, y + h / 2.0 - 2, x + w / 2.0 - 2, y + h / 2.0 - 2);
  } else if (mode == CORNER) {
    rect(x + w / 2.0, y + h / 2.0, w, h, 8);
  }
  textSize(16);
  fill(cOnSurfaceVariant);
  textAlign(LEFT, TOP);
  if (mode == CENTER) {
    text(textFieldTitle, x - w / 2.0 + 12, y - h / 2.0 + 10);
  } else if (mode == CORNER) {
    text(textFieldTitle, x + 16, y - 8);
  }
  fill(cOnSurface);
  textSize(22);
  textAlign(LEFT, CENTER);
  if (mode == CENTER) {
    text(targetTextField, x - w / 2.0 + 16, y + 10);
  } else {
    text(targetTextField, x, y);
  }
  popStyle();
  return;
}

void drawPopupImageBox(String textFieldTitle, float x, float y, float w, float h, int mode, PImage targetImage) {
  pushStyle();
  noStroke();
  rectMode(CENTER);
  fill(cSurfaceBright);
  stroke(cOutline);
  strokeWeight(2);
  if (mode == CENTER) {
    rect(x, y, w, h, 8);
  } else if (mode == CORNER) {
    rect(x + w / 2.0, y + h / 2.0, w, h, 8);
  }

  textSize(16);
  fill(cOnSurfaceVariant);
  textAlign(LEFT, TOP);
  if (mode == CENTER) {
    text(textFieldTitle, x - w / 2.0 + 12, y - h / 2.0 + 10);
  } else if (mode == CORNER) {
    text(textFieldTitle, x + 16, y - 8);
  }

  imageMode(CENTER);
  tint(255);
  image(targetImage, x, y + 8, 36, 36);
  popStyle();
}

void drawElapsedTimePopupMenu(String popupTitle) {
  if (!isPopupOpen) {
    return;
  }

  String[] modeLabels = {
    "アプリ起動時の時刻を使用",
    "接続開始時の時刻を使用",
    "更新するたびにリセット"
  };

  float menuWidth = width * 0.8;
  float menuHeight = height * 0.34;
  float menuX = width / 2.0;
  float menuY = height / 2.0;
  float headerHeight = 46;
  float itemHeight = (menuHeight - headerHeight) / 3.8;

  pushStyle();
  rectMode(CENTER);
  textAlign(LEFT, CENTER);

  fill(0, 0, 0, 96);
  noStroke();
  rect(width / 2.0, height / 2.0, width, height);

  fill(cSurfaceContainerHigh);
  noStroke();
  rect(menuX, menuY, menuWidth, menuHeight, 24);

  fill(cOnSurface);
  textFont(GenShinGothic_Medium);
  textSize(28);
  text(popupTitle, menuX - menuWidth / 2.0 + 24, menuY - menuHeight / 2.0 + 38);
  stroke(cOutline);
  strokeWeight(2);
  line(menuX - menuWidth / 2.0, menuY - menuHeight / 2.0 + headerHeight + 32, menuX + menuWidth / 2.0, menuY - menuHeight / 2.0 + headerHeight + 32);

  for (int i = 0; i < 3; i++) {
    float itemCenterY = menuY - menuHeight / 2.5 + headerHeight + (itemHeight * i) + itemHeight / 2.0;
    if (isMouseOver(menuX - menuWidth / 2.0, itemCenterY - itemHeight / 2.0, menuWidth, itemHeight, CORNER)) {
      fill(cOnSurfaceVariantTransparent);
      noStroke();
      rect(menuX, itemCenterY, menuWidth, itemHeight);
    }

    if (elapsedTimeMode.equals(getElapsedTimeModeValueFromIndex(i))) {
      fill(cPrimary);
      drawRadioButton(menuX - menuWidth / 2.0 + 42, itemCenterY, 22, true);
    } else {
      fill(cOnSurfaceVariant);
      drawRadioButton(menuX - menuWidth / 2.0 + 42, itemCenterY, 22, false);
    }

    fill(cOnSurface);
    textFont(GenShinGothic_Regular);
    textSize(22);
    text(modeLabels[i], menuX - menuWidth / 2.0 + 72, itemCenterY - 1);
  }

  popStyle();
}

void drawActivityTypePopupMenu(String popupTitle) {
  if (!isPopupOpen) {
    return;
  }

  String[] activityLabels = {
    "勉強",
    "授業",
    "作業",
    "料理",
    "食事",
    "運動",
    "睡眠",
    "カスタム設定..."
  };

  float menuWidth = width * 0.86;
  float menuHeight = height * 0.74;
  float menuX = width / 2.0;
  float menuY = height / 2.0;
  float headerHeight = 60;
  float itemHeight = (menuHeight - headerHeight - 12) / 8.8;
  float menuTop = menuY - menuHeight / 2.0;

  pushStyle();
  rectMode(CENTER);
  textAlign(LEFT, CENTER);

  fill(0, 0, 0, 96);
  noStroke();
  rect(width / 2.0, height / 2.0, width, height);

  fill(cSurfaceContainerHigh);
  rect(menuX, menuY, menuWidth, menuHeight, 24);

  fill(cOnSurface);
  textFont(GenShinGothic_Medium);
  textSize(28);
  text(popupTitle, menuX - menuWidth / 2.0 + 24, menuTop + 38);
  stroke(cOutline);
  strokeWeight(2);
  line(menuX - menuWidth / 2.0, menuTop + headerHeight + 20, menuX + menuWidth / 2.0, menuTop + headerHeight + 20);

  for (int i = 0; i < activityLabels.length; i++) {
    float itemCenterY = menuTop + headerHeight + 28 + (itemHeight * i) + itemHeight / 2.0;
    boolean isHover = isMouseOver(menuX - menuWidth / 2.0, itemCenterY - itemHeight / 2.0, menuWidth, itemHeight, CORNER);
    boolean isSelected = i == activityLabels.length - 1
      ? !isPresetActivityTitle(textFieldActivityTitle, activityLabels)
      : textFieldActivityTitle.equals(activityLabels[i]);

    if (isHover) {
      fill(cOnSurfaceVariantTransparent);
      noStroke();
      rect(menuX, itemCenterY, menuWidth, itemHeight);
    }

    drawRadioButton(menuX - menuWidth / 2.0 + 42, itemCenterY, 22, isSelected);
    fill(cOnSurface);
    textFont(GenShinGothic_Regular);
    textSize(22);
    text(activityLabels[i], menuX - menuWidth / 2.0 + 72, itemCenterY - 1);
  }

  popStyle();
}

boolean isPresetActivityTitle(String activityTitle, String[] activityLabels) {
  for (int i = 0; i < activityLabels.length - 1; i++) {
    if (activityTitle.equals(activityLabels[i])) {
      return true;
    }
  }
  return false;
}

void drawIconPopupMenu(String popupTitle) {
  if (!isPopupOpen) {
    return;
  }

  String[] iconKeys = {
    "cooking_1f373",
    "dish_1f37d",
    "flexed_biceps_1f4aa",
    "zzz_1f4a4",
    "memo_1f4dd",
    "writing_270d",
    "technologist_1f9d1",
    "sandclock_23f3"
  };

  PImage[] iconImages = {
    actIconCooking,
    actIconDish,
    actIconMuscle,
    actIconZzz,
    actIconMemo,
    actIconWriting,
    actIconTechnologist,
    actIconSandclock
  };

  float menuWidth = width * 0.86;
  float menuHeight = height * 0.4;
  float menuX = width / 2.0;
  float menuY = height / 2.0;
  float headerHeight = 52;
  float tileSize = 96;
  float gapX = 12;
  float gapY = 12;
  float gridWidth = (tileSize * 4) + (gapX * 3);
  float gridHeight = (tileSize * 2) + gapY;
  float gridLeft = menuX - gridWidth / 2.0;
  float gridTop = menuY - gridHeight / 2.0 + 28;

  pushStyle();
  rectMode(CENTER);
  textAlign(LEFT, CENTER);

  fill(0, 0, 0, 96);
  noStroke();
  rect(width / 2.0, height / 2.0, width, height);

  fill(cSurfaceContainerHigh);
  noStroke();
  rect(menuX, menuY, menuWidth, menuHeight, 24);

  fill(cOnSurface);
  textFont(GenShinGothic_Medium);
  textSize(28);
  text(popupTitle, menuX - menuWidth / 2.0 + 24, menuY - menuHeight / 2.0 + 38);
  stroke(cOutline);
  strokeWeight(2);
  line(menuX - menuWidth / 2.0, menuY - menuHeight / 2.0 + headerHeight + 24, menuX + menuWidth / 2.0, menuY - menuHeight / 2.0 + headerHeight + 24);

  for (int i = 0; i < 8; i++) {
    int row = i / 4;
    int col = i % 4;
    float tileX = gridLeft + col * (tileSize + gapX) + tileSize / 2.0;
    float tileY = gridTop + row * (tileSize + gapY) + tileSize / 2.0;
    boolean isHover = isMouseOver(tileX - tileSize / 2.0, tileY - tileSize / 2.0, tileSize, tileSize, CORNER);
    boolean isSelected = dropdownLargeImageKey.equals(iconKeys[i]);

    if (isSelected) {
      fill(cPrimaryContainer);
    } else {
      fill(cSurfaceBright);
    }
    noStroke();
    rect(tileX, tileY, tileSize, tileSize, 14);

    if (isHover) {
      fill(cOnSurfaceVariantTransparent);
      rect(tileX, tileY, tileSize, tileSize, 14);
    }

    imageMode(CENTER);
    tint(255);
    image(iconImages[i], tileX, tileY, 48, 48);
  }

  popStyle();
}

String getElapsedTimeModeDisplay(String modeValue) {
  if (modeValue == null || modeValue.equals("")) {
    return "接続開始時の時刻を使用";
  }

  if (modeValue.equals("appLaunch")) {
    return "アプリ起動時の時刻を使用";
  }

  if (modeValue.equals("resetOnUpdate")) {
    return "更新するたびにリセット";
  }

  return "接続開始時の時刻を使用";
}

String getElapsedTimeModeValueFromIndex(int index) {
  if (index == 0) {
    return "appLaunch";
  }

  if (index == 1) {
    return "connectStart";
  }

  return "resetOnUpdate";
}

String getActivityIconDisplayName(String iconKey) {
  if (iconKey == null || iconKey.equals("")) {
    return "メモ";
  }

  if (iconKey.equals("cooking_1f373")) {
    return "料理";
  }
  if (iconKey.equals("dish_1f37d")) {
    return "食事";
  }
  if (iconKey.equals("flexed_biceps_1f4aa")) {
    return "筋トレ";
  }
  if (iconKey.equals("zzz_1f4a4")) {
    return "睡眠";
  }
  if (iconKey.equals("memo_1f4dd")) {
    return "メモ";
  }
  if (iconKey.equals("writing_270d")) {
    return "執筆";
  }
  if (iconKey.equals("technologist_1f9d1")) {
    return "作業";
  }
  if (iconKey.equals("sandclock_23f3")) {
    return "経過";
  }

  return "メモ";
}

PImage getActivityIconImage(String iconKey) {
  if (iconKey == null || iconKey.equals("")) {
    return actIconMemo;
  }

  if (iconKey.equals("cooking_1f373")) {
    return actIconCooking;
  }
  if (iconKey.equals("dish_1f37d")) {
    return actIconDish;
  }
  if (iconKey.equals("flexed_biceps_1f4aa")) {
    return actIconMuscle;
  }
  if (iconKey.equals("zzz_1f4a4")) {
    return actIconZzz;
  }
  if (iconKey.equals("memo_1f4dd")) {
    return actIconMemo;
  }
  if (iconKey.equals("writing_270d")) {
    return actIconWriting;
  }
  if (iconKey.equals("technologist_1f9d1")) {
    return actIconTechnologist;
  }
  if (iconKey.equals("sandclock_23f3")) {
    return actIconSandclock;
  }

  return actIconMemo;
}

String getActivityIconKeyFromIndex(int index) {
  if (index == 0) {
    return "cooking_1f373";
  }
  if (index == 1) {
    return "dish_1f37d";
  }
  if (index == 2) {
    return "flexed_biceps_1f4aa";
  }
  if (index == 3) {
    return "zzz_1f4a4";
  }
  if (index == 4) {
    return "memo_1f4dd";
  }
  if (index == 5) {
    return "writing_270d";
  }
  if (index == 6) {
    return "technologist_1f9d1";
  }
  return "sandclock_23f3";
}

PImage getActivityIconImageFromIndex(int index) {
  if (index == 0) {
    return actIconCooking;
  }
  if (index == 1) {
    return actIconDish;
  }
  if (index == 2) {
    return actIconMuscle;
  }
  if (index == 3) {
    return actIconZzz;
  }
  if (index == 4) {
    return actIconMemo;
  }
  if (index == 5) {
    return actIconWriting;
  }
  if (index == 6) {
    return actIconTechnologist;
  }
  return actIconSandclock;
}

void handleActivePopupMouseReleased() {
  if (activePopupMenu.equals("icon")) {
    handleIconPopupMouseReleased();
    return;
  }

  if (activePopupMenu.equals("activityType")) {
    handleActivityTypePopupMouseReleased();
    return;
  }

  handleElapsedTimePopupMouseReleased();
}

void handleActivityTypePopupMouseReleased() {
  String[] activityLabels = {
    "勉強",
    "授業",
    "作業",
    "料理",
    "食事",
    "運動",
    "睡眠",
    "カスタム設定..."
  };

  float menuWidth = width * 0.86;
  float menuHeight = height * 0.74;
  float menuX = width / 2.0;
  float menuY = height / 2.0;
  float headerHeight = 60;
  float itemHeight = (menuHeight - headerHeight - 12) / 8.8;
  float menuLeft = menuX - menuWidth / 2.0;
  float menuTop = menuY - menuHeight / 2.0;
  float menuRight = menuX + menuWidth / 2.0;
  float menuBottom = menuY + menuHeight / 2.0;

  if (mouseX < menuLeft || mouseX > menuRight || mouseY < menuTop || mouseY > menuBottom) {
    isPopupOpen = false;
    activePopupMenu = "";
    return;
  }

  for (int i = 0; i < activityLabels.length; i++) {
    float itemCenterY = menuTop + headerHeight + 28 + (itemHeight * i) + itemHeight / 2.0;
    float itemTop = itemCenterY - itemHeight / 2.0;
    float itemBottom = itemCenterY + itemHeight / 2.0;

    if (mouseY < itemTop || mouseY > itemBottom) {
      continue;
    }

    if (i == 7) {
      dropdownLargeImageKey = getActivityIconKeyFromTypeIndex(i);
      pendingDialogTitle = "カスタム設定";
      pendingDialogMessage = "アクティビティ名を入力してください";
      pendingTargetValue = textFieldActivityTitle;
      thread("openInputDialogAsync");
      return;
    }

    textFieldActivityTitle = activityLabels[i];
    dropdownLargeImageKey = getActivityIconKeyFromTypeIndex(i);
    saveUserProfiles();
    isPopupOpen = false;
    activePopupMenu = "";
    return;
  }
}

String getActivityIconKeyFromTypeIndex(int index) {
  if (index == 0) {
    return "memo_1f4dd";
  }
  if (index == 1) {
    return "technologist_1f9d1";
  }
  if (index == 2) {
    return "writing_270d";
  }
  if (index == 3) {
    return "cooking_1f373";
  }
  if (index == 4) {
    return "dish_1f37d";
  }
  if (index == 5) {
    return "flexed_biceps_1f4aa";
  }
  if (index == 6) {
    return "zzz_1f4a4";
  }
  return "sandclock_23f3";
}

void handleIconPopupMouseReleased() {
  float menuWidth = width * 0.86;
  float menuHeight = height * 0.4;
  float menuX = width / 2.0;
  float menuY = height / 2.0;
  float tileSize = 96;
  float gapX = 12;
  float gapY = 12;
  float gridWidth = (tileSize * 4) + (gapX * 3);
  float gridHeight = (tileSize * 2) + gapY;
  float gridLeft = menuX - gridWidth / 2.0;
  float gridTop = menuY - gridHeight / 2.0 + 28;

  if (mouseX < menuX - menuWidth / 2.0 || mouseX > menuX + menuWidth / 2.0 || mouseY < menuY - menuHeight / 2.0 || mouseY > menuY + menuHeight / 2.0) {
    isPopupOpen = false;
    activePopupMenu = "";
    return;
  }

  for (int i = 0; i < 8; i++) {
    int row = i / 4;
    int col = i % 4;
    float tileX = gridLeft + col * (tileSize + gapX) + tileSize / 2.0;
    float tileY = gridTop + row * (tileSize + gapY) + tileSize / 2.0;
    float tileLeft = tileX - tileSize / 2.0;
    float tileTop = tileY - tileSize / 2.0;
    float tileRight = tileX + tileSize / 2.0;
    float tileBottom = tileY + tileSize / 2.0;

    if (mouseX >= tileLeft && mouseX <= tileRight && mouseY >= tileTop && mouseY <= tileBottom) {
      dropdownLargeImageKey = getActivityIconKeyFromIndex(i);
      saveUserProfiles();
      isPopupOpen = false;
      activePopupMenu = "";
      return;
    }
  }
}

void handleElapsedTimePopupMouseReleased() {
  float menuWidth = width * 0.8;
  float menuHeight = height * 0.34;
  float menuX = width / 2.0;
  float menuY = height / 2.0;
  float headerHeight = 46;
  float itemHeight = (menuHeight - headerHeight) / 3.8;
  float menuLeft = menuX - menuWidth / 2.0;
  float menuTop = menuY - menuHeight / 2.0;
  float menuRight = menuX + menuWidth / 2.0;
  float menuBottom = menuY + menuHeight / 2.0;

  // メニュー枠の外をクリックした場合は閉じる
  if (mouseX < menuLeft || mouseX > menuRight || mouseY < menuTop || mouseY > menuBottom) {
    isPopupOpen = false;
    activePopupMenu = "";
    return;
  }

  // 3つの各項目の中心Y座標をループで計算し、マウスがその項目の高さ範囲内にあるかを判定する
  for (int i = 0; i < 3; i++) {
    float itemCenterY = menuY - menuHeight / 2.5 + headerHeight + (itemHeight * i) + itemHeight / 2.0;
    float itemTop = itemCenterY - itemHeight / 2.0;
    float itemBottom = itemCenterY + itemHeight / 2.0;

    if (mouseY >= itemTop && mouseY <= itemBottom) {
      elapsedTimeMode = getElapsedTimeModeValueFromIndex(i);
      dialogElapsedTimeMode = getElapsedTimeModeDisplay(elapsedTimeMode);
      saveSettings(false);
      isPopupOpen = false;
      activePopupMenu = "";
      return;
    }
  }
}

void checkPopupBox(float x, float y, float w, float h, int mode, String popupKind, String targetTab) {
  if (isPopupOpen) {
    return;
  }

  if (isMouseOver(x, y, w, h, mode) == true && currentTab.equals(targetTab)) {
    isPopupOpen = true;
    activePopupMenu = popupKind;
  }
  return;
}

void checkTabBarMouseOver() {
  pushStyle();
  noStroke();
  rectMode(CENTER);
  if (mouseY >= tBHeight && mouseY <= height) {

    if (mouseX < width * 0.35 && currentTab != "Connect") {
      fill(cOnSurfaceVariantTransparent);
      rect(width / 5, tBHeight + 36, 76, 42, 96);
    } else if (mouseX >= width * 0.35 && mouseX < width * 0.65 && currentTab != "Record") {
      fill(cOnSurfaceVariantTransparent);
      rect(width / 2, tBHeight + 36, 76, 42, 96);
    } else if (mouseX >= width * 0.65 && currentTab != "Settings") {
      fill(cOnSurfaceVariantTransparent);
      rect(width * 4 / 5, tBHeight + 36, 76, 42, 96);
    }
  }
  popStyle();
  return;
}

void drawCapsule(float x, float y, float w, float h) {
  if (w < h) {
    w = h;
  }

  // 円の半径
  float r = h / 2.0;
  // 中央の長方形部分の横幅（全体幅から左右の半径分を引いたもの）
  float rectW = w - (r * 2);

  rectMode(CENTER);
  ellipseMode(CENTER);

  pushMatrix();
  translate(x, y);

  // 中央の長方形を描画
  rect(0, 0, rectW + 2, h);

  // 左側の半円を描画（中心は左に rectW/2 動いた場所）
  arc(-rectW / 2.0, 0, h, h, HALF_PI, PI + HALF_PI);

  // 右側の半円を描画（中心は右に rectW/2 動いた場所）
  arc(rectW / 2.0, 0, h, h, -HALF_PI, HALF_PI);

  popMatrix();
}

void drawSwitch(float x, float y, boolean isOn) {
  pushStyle();
  pushMatrix();
  if (isOn) {
    fill(cPrimary);
    noStroke();
  } else {
    fill(cSurfaceContainerHigh);
    stroke(cOutline);
    strokeWeight(2);
  }
  drawCapsule(x, y, 84, 42);
  if (isOn) {
    fill(cOnPrimary);
    circle(x + 20, y, 32);
  } else {
    fill(cOutline);
    circle(x - 20, y, 22);
  }
  popStyle();
  popMatrix();
}

void drawScreenConnect() {
  pushStyle();
  noStroke();
  textAlign(LEFT, TOP);
  textFont(GenShinGothic_Medium);
  textSize(32);

  rectMode(CORNERS);
  fill(cSurfaceContainer);
  rect(0, 0, width, height * 0.08);

  fill(cOnSurface);
  text("接続", width * 0.05, height * 0.025);

  // 接続状態_ブロック
  rectMode(CENTER);
  if (dConnectStatusDisp == "未接続") {
    fill(cOnSurfaceVariantTransparent);
  } else if (dConnectStatusDisp == "接続失敗") {
    fill(cOnSurfaceVariantTransparent);
  } else {
    fill(cPrimaryContainer);
  }
  rect(width / 2, height * 0.125, width * 0.93, height * 0.06, 8);

  // 接続状態_テキスト
  if (dConnectStatusDisp == "未接続") {
    fill(cOnSurface);
  } else if (dConnectStatusDisp == "接続失敗") {
    fill(cError);
  } else {
    fill(cOnPrimaryContainer);
  }

  if (isStatusTextChanged && (millis() - statusTextChangeStartTime > 2000)) {
    isStatusTextChanged = false; // 2秒経ったらフラグを元に戻す
  }

  textFont(GenShinGothic_Regular);
  textSize(24);
  textAlign(LEFT, CENTER);
  if (isStatusTextChanged) {
    text("更新しました", width * 0.06, height * 0.122);
  } else {
    text("接続状態: " + dConnectStatusDisp, width * 0.06, height * 0.122);
  }

  fill(cSecondaryContainer);
  rect(width / 2, height * 0.47, width * 0.93, height * 0.6, 8);

  fill(cOnSecondaryContainer);
  textSize(16);
  text("表示内容", width * 0.06, height * 0.19);
  text("表示設定", width * 0.06, height * 0.51);
  // text("詳細情報1", width * 0.06, height * 0.3);

  drawPopupBox("アクティビティの種類（タイトル）", width * 0.388, height * 0.255, width * 0.652, height * 0.08, CENTER, textFieldActivityTitle);
  drawPopupImageBox("アイコン", width * 0.84, height * 0.255, width * 0.2, height * 0.08, CENTER, getActivityIconImage(dropdownLargeImageKey));

  drawTextBox("1行目の情報", width * 0.5, height * 0.355, width * 0.88, height * 0.08, CENTER, textFieldDetails);
  drawTextBox("2行目の情報", width * 0.5, height * 0.455, width * 0.88, height * 0.08, CENTER, textFieldState);

  drawPopupBox("経過時間の基準", width * 0.5, height * 0.57, width * 0.88, height * 0.08, CENTER, dialogElapsedTimeMode);

  drawActionButton("接続", iconCheck, connectingProgress == "none" || connectingProgress == "failure", cPrimary, cOnPrimary, width * 0.84, height * 0.84, width * 0.26, height * 0.06);
  drawActionButton("更新", iconRefresh, connectingProgress == "connected", cPrimary, cOnPrimary, width * 0.84, height * 0.84, width * 0.26, height * 0.06);
  drawActionButton("切断", iconCloseSmall, connectingProgress == "connected", cSurfaceContainer, cPrimary, width * 0.56, height * 0.84, width * 0.24, height * 0.06);

  if (isPopupOpen) {
    if (activePopupMenu.equals("icon")) {
      drawIconPopupMenu("アイコンの設定");
    } else if (activePopupMenu.equals("activityType")) {
      drawActivityTypePopupMenu("アクティビティの種類");
    } else {
      drawElapsedTimePopupMenu("経過時間の基準");
    }
  }

  popStyle();
  return;
}

void drawActionButton(String buttonText, PImage buttonIcon, boolean reqenabled, color buttonBgColor, color buttonCtColor, float buttonX, float buttonY, float buttonWidth, float buttonHeight) {
  if (reqenabled) {
    pushStyle();
    fill(buttonBgColor);
    drawCapsule(buttonX, buttonY, buttonWidth, buttonHeight);
    textSize(24);
    textAlign(LEFT, CENTER);
    tint(buttonCtColor);
    fill(buttonCtColor);
    image(buttonIcon, buttonX - (buttonWidth * 0.38), buttonY - 22, 42, 42);
    text(buttonText, buttonX - 6, buttonY - 2);
    popStyle();
  }
  return;
}
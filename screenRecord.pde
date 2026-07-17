String[] recordActivityOrder = {
  "勉強",
  "授業",
  "作業",
  "料理",
  "食事",
  "運動",
  "睡眠",
  "その他"
};

void ensureActivityDataFileExists() {
  String filePath = getActivityDataFilePath();
  File file = new File(filePath);

  if (file.exists()) {
    return;
  }

  JSONObject root = new JSONObject();
  root.setJSONObject("days", new JSONObject());
  saveJSONObject(root, filePath);
}

String getActivityDataFilePath() {
  return dataPath("user/activity-data.json");
}

JSONObject loadActivityDataRoot() {
  ensureActivityDataFileExists();

  JSONObject root = loadJSONObject(getActivityDataFilePath());
  if (root == null) {
    root = new JSONObject();
  }

  if (root.getJSONObject("days") == null) {
    root.setJSONObject("days", new JSONObject());
  }

  return root;
}

void saveActivityDataRoot(JSONObject root) {
  if (root == null) {
    return;
  }

  if (root.getJSONObject("days") == null) {
    root.setJSONObject("days", new JSONObject());
  }

  saveJSONObject(root, getActivityDataFilePath());
}

String getActivityRecordDateKey(long millisValue) {
  java.util.Calendar calendar = java.util.Calendar.getInstance();
  calendar.setTimeInMillis(millisValue);
  return nf(calendar.get(java.util.Calendar.YEAR), 4) + "-" + nf(calendar.get(java.util.Calendar.MONTH) + 1, 2) + "-" + nf(calendar.get(java.util.Calendar.DAY_OF_MONTH), 2);
}

long getNextDayStartMillis(long millisValue) {
  java.util.Calendar calendar = java.util.Calendar.getInstance();
  calendar.setTimeInMillis(millisValue);
  calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
  calendar.set(java.util.Calendar.MINUTE, 0);
  calendar.set(java.util.Calendar.SECOND, 0);
  calendar.set(java.util.Calendar.MILLISECOND, 0);
  calendar.add(java.util.Calendar.DAY_OF_MONTH, 1);
  return calendar.getTimeInMillis();
}

boolean isPresetActivityTitleForRecord(String activityTitle) {
  if (activityTitle == null) {
    return false;
  }

  for (int i = 0; i < recordActivityOrder.length - 1; i++) {
    if (activityTitle.equals(recordActivityOrder[i])) {
      return true;
    }
  }

  return false;
}

String normalizeRecordedActivityTitle(String activityTitle) {
  if (isPresetActivityTitleForRecord(activityTitle)) {
    return activityTitle;
  }

  return "その他";
}

void beginActivityRecordSession(String activityTitle, long startMillis) {
  activeRecordActivityTitle = activityTitle;
  activeRecordStartMillis = startMillis;
}

void clearActivityRecordSession() {
  activeRecordActivityTitle = "";
  activeRecordStartMillis = 0;
}

void recordActiveActivitySession(String activityTitle, long startMillis, long endMillis) {
  if (activityTitle == null || activityTitle.length() == 0) {
    return;
  }

  if (startMillis <= 0 || endMillis <= startMillis) {
    return;
  }

  JSONObject root = loadActivityDataRoot();
  JSONObject days = root.getJSONObject("days");

  long cursor = startMillis;
  while (cursor < endMillis) {
    long dayEndMillis = getNextDayStartMillis(cursor);
    long segmentEndMillis = endMillis < dayEndMillis ? endMillis : dayEndMillis;
    int elapsedMinutes = (int)((segmentEndMillis - cursor) / 60000L);

    if (elapsedMinutes > 0) {
      String dateKey = getActivityRecordDateKey(cursor);
      JSONArray dailyRecords = days.getJSONArray(dateKey);
      if (dailyRecords == null) {
        dailyRecords = new JSONArray();
        days.setJSONArray(dateKey, dailyRecords);
      }

      boolean updated = false;
      for (int i = 0; i < dailyRecords.size(); i++) {
        JSONObject entry = dailyRecords.getJSONObject(i);
        if (entry != null && activityTitle.equals(entry.getString("activity", ""))) {
          entry.setInt("minutes", entry.getInt("minutes", 0) + elapsedMinutes);
          updated = true;
          break;
        }
      }

      if (!updated) {
        JSONObject entry = new JSONObject();
        entry.setString("activity", activityTitle);
        entry.setInt("minutes", elapsedMinutes);
        dailyRecords.append(entry);
      }
    }

    if (segmentEndMillis <= cursor) {
      break;
    }

    cursor = segmentEndMillis;
  }

  saveActivityDataRoot(root);
}

IntDict getRecordedActivityTotals() {
  IntDict totals = new IntDict();
  for (int i = 0; i < recordActivityOrder.length; i++) {
    totals.set(recordActivityOrder[i], 0);
  }

  JSONObject root = loadActivityDataRoot();
  JSONObject days = root.getJSONObject("days");
  if (days == null) {
    return totals;
  }

  java.util.Set dateKeys = days.keys();
  if (dateKeys == null) {
    return totals;
  }

  for (Object dateKeyObject : dateKeys) {
    String dateKey = String.valueOf(dateKeyObject);
    JSONArray dailyRecords = days.getJSONArray(dateKey);
    if (dailyRecords == null) {
      continue;
    }

    for (int recordIndex = 0; recordIndex < dailyRecords.size(); recordIndex++) {
      JSONObject entry = dailyRecords.getJSONObject(recordIndex);
      if (entry == null) {
        continue;
      }

      String activityTitle = entry.getString("activity", "");
      int minutes = entry.getInt("minutes", 0);
      if (minutes <= 0) {
        continue;
      }

      String category = normalizeRecordedActivityTitle(activityTitle);
      totals.set(category, totals.get(category) + minutes);
    }
  }

  return totals;
}

color getRecordCategoryColor(int index) {
  if (index == 0) return color(77, 150, 255);
  if (index == 1) return color(80, 200, 170);
  if (index == 2) return color(255, 171, 77);
  if (index == 3) return color(255, 122, 122);
  if (index == 4) return color(255, 205, 86);
  if (index == 5) return color(141, 122, 255);
  if (index == 6) return color(120, 120, 120);
  return color(170, 170, 170);
}

String formatRecordDuration(int minutes) {
  if (minutes < 0) {
    minutes = 0;
  }

  int hours = minutes / 60;
  int remainingMinutes = minutes % 60;
  return hours + "時間" + remainingMinutes + "分";
}

void drawRecordLegendItem(String label, int minutes, color swatchColor, float x, float y) {
  pushStyle();
  noStroke();
  fill(swatchColor);
  ellipse(x + 10, y + 10, 24, 24);

  fill(cOnSurface);
  textAlign(LEFT, CENTER);
  textFont(GenShinGothic_Regular);
  textSize(30);
  text(label, x + 30, y + 6);

  textAlign(RIGHT, CENTER);
  text(formatRecordDuration(minutes), x + 460, y + 6);
  popStyle();
}

void drawScreenRecord() {
  pushStyle();
  noStroke();
  textAlign(LEFT, TOP);
  textFont(GenShinGothic_Medium);
  textSize(32);

  rectMode(CORNERS);
  fill(cSurfaceContainer);
  rect(0, 0, width, height * 0.08);

  fill(cOnSurface);
  text("記録", width * 0.05, height * 0.025);

  IntDict totals = getRecordedActivityTotals();
  String[] categoryLabels = recordActivityOrder;
  int totalMinutes = 0;
  for (int i = 0; i < categoryLabels.length; i++) {
    totalMinutes += totals.get(categoryLabels[i]);
  }

  float chartCenterX = width * 0.5;
  float chartCenterY = height * 0.26;
  float chartDiameter = min(width * 0.56, height * 0.28);

  if (totalMinutes > 0) {
    float startAngle = -HALF_PI;
    for (int i = 0; i < categoryLabels.length; i++) {
      int minutes = totals.get(categoryLabels[i]);
      if (minutes <= 0) {
        continue;
      }

      float sweepAngle = TWO_PI * (minutes / (float)totalMinutes);
      fill(getRecordCategoryColor(i));
      arc(chartCenterX, chartCenterY, chartDiameter, chartDiameter, startAngle, startAngle + sweepAngle, PIE);
      startAngle += sweepAngle;
    }

    fill(cSurface);
    noStroke();
    ellipse(chartCenterX, chartCenterY, chartDiameter * 0.44, chartDiameter * 0.44);

    fill(cOnSurface);
    textAlign(CENTER, CENTER);
    textFont(GenShinGothic_Medium);
    textSize(28);
    text(formatRecordDuration(totalMinutes), chartCenterX, chartCenterY - 6);
    textFont(GenShinGothic_Regular);
    textSize(14);
    text("合計", chartCenterX, chartCenterY + 22);
  } else {
    fill(cOnSurfaceVariantTransparent);
    ellipse(chartCenterX, chartCenterY, chartDiameter, chartDiameter);

    fill(cOnSurfaceVariant);
    textAlign(CENTER, CENTER);
    textFont(GenShinGothic_Regular);
    textSize(22);
    text("記録がありません", chartCenterX, chartCenterY);
  }

  float legendStartY = height * 0.46;
  float legendLeftX = width * 0.08;
  for (int i = 0; i < categoryLabels.length; i++) {
    float legendX = legendLeftX;
    float legendY = legendStartY + i * 48;
    drawRecordLegendItem(categoryLabels[i], totals.get(categoryLabels[i]), getRecordCategoryColor(i), legendX, legendY);
  }

  fill(cOnSurfaceVariant);
  textAlign(LEFT, TOP);
  textFont(GenShinGothic_Regular);
  textSize(14);
  text("カスタム入力は「その他」に集計されます", width * 0.08, tBHeight - height * 0.04);

  popStyle();
}

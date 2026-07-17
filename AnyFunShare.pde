import java.net.*;
import java.io.*;
import java.awt.*;
import processing.awt.PGraphicsJava2D;
import java.awt.Graphics2D;
import javax.swing.*;
import com.jogamp.newt.opengl.GLWindow;

String appVersion = "1.0.0";

int tBHeight;
int serverPort = 3005;
String serverType = "release";
String elapsedTimeMode = "connectStart";
boolean isPopupOpen = false;
String activePopupMenu = "";

Process nodeServer;

String activeTextFieldTitle = "";
String activeDialogTitle = "";
boolean pendingDialogOpen = false;
String pendingDialogMessage = "";
String pendingDialogTitle = "";
String pendingTargetValue = "";
boolean isDialogOpenNow = false;

int statusTextChangeStartTime = 0;
boolean isStatusTextChanged = false;
long appStartMillis = 0;
long activityStartMillis = 0;

boolean isDarkTheme = false;
boolean keepWindowPos = false;
String currentTab;

boolean isWindowLocked = false;

int windowPosX = 20;
int windowPosY = 20;

String textFieldDetails = "";
String textFieldState = "";
String dialogElapsedTimeMode = "";
String textFieldActivityTitle = "勉強";
String dropdownLargeImageKey = "memo_1f4dd";
String activeRecordActivityTitle = "";
long activeRecordStartMillis = 0;
String dConnectStatusDisp = "未接続";

String connectingProgress = "none";

float setCatX;
float setCatY;

float setItemX;
float setItemY;

PImage appIcon;
PImage iconSensors, iconChart, iconChartSelected, iconSettings, iconSettingsSelected, iconCheck, iconClose, iconCloseSmall, iconRefresh, iconBrush, iconDarkMode, iconFlip2Front;
PImage actIconCooking, actIconDish, actIconMuscle, actIconMemo, actIconSandclock, actIconTechnologist, actIconWriting, actIconZzz;
PFont GenShinGothic_Regular, GenShinGothic_Medium;

void settings() {
  pixelDensity(1);
  smooth(4);
  size(540, 960, P2D);
  PJOGL.setIcon("./assets/app_icon.png");
}

void setup() {
  surface.setResizable(false);
  surface.setTitle("AnyFunShare v" + appVersion);
  appStartMillis = System.currentTimeMillis();

  colorMode(RGB, 255, 255, 255, 255);

  GenShinGothic_Regular = createFont("./assets/font/GenShinGothic/GenShinGothic-Regular.ttf", 32, true);
  GenShinGothic_Medium = createFont("./assets/font/GenShinGothic/GenShinGothic-Medium.ttf", 32, true);

  appIcon = loadImage("./assets/app_icon.png");
  iconSensors = loadImage("./assets/icon/sensors.png");
  iconChart = loadImage("./assets/icon/insert_chart.png");
  iconChartSelected = loadImage("./assets/icon/insert_chart_fill.png");
  iconSettings = loadImage("./assets/icon/settings.png");
  iconSettingsSelected = loadImage("./assets/icon/settings_fill.png");
  iconCheck = loadImage("./assets/icon/check.png");
  iconClose = loadImage("./assets/icon/close.png");
  iconCloseSmall = loadImage("./assets/icon/close_small.png");
  iconRefresh = loadImage("./assets/icon/refresh.png");
  iconBrush = loadImage("./assets/icon/brush.png");
  iconDarkMode = loadImage("./assets/icon/dark_mode.png");
  iconFlip2Front = loadImage("./assets/icon/flip_to_front.png");

  actIconCooking = loadImage("./assets/icon_activity/cooking_1f373.png");
  actIconDish = loadImage("./assets/icon_activity/dish_1f37d.png");
  actIconMuscle = loadImage("./assets/icon_activity/flexed_biceps_1f4aa.png");
  actIconMemo = loadImage("./assets/icon_activity/memo_1f4dd.png");
  actIconSandclock = loadImage("./assets/icon_activity/sandclock_23f3.png");
  actIconTechnologist = loadImage("./assets/icon_activity/technologist_1f9d1.png");
  actIconWriting = loadImage("./assets/icon_activity/writing_270d.png");
  actIconZzz = loadImage("./assets/icon_activity/zzz_1f4a4.png");

  setCatX = width * 0.05;
  setCatY = height * 0.1;
  setItemX = width * 0.05;
  setItemY = height * 0.15;

  currentTab = "Connect";
  textFont(GenShinGothic_Regular);
  loadSettings();
  dialogElapsedTimeMode = getElapsedTimeModeDisplay(elapsedTimeMode);
  if (keepWindowPos) {
    surface.setLocation(windowPosX, windowPosY);
  } else {
    surface.setLocation(20, 20);
  }
  loadUserProfiles();
  ensureActivityDataFileExists();
  applyThemeColors();
  background(255);

  try {
    startServerProcess();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

// アプリ設定とサーバー設定を設定ファイルから読み込む
void loadSettings() {
  String fullPath = dataPath("config.json");

  try {
    File f = new File(fullPath);
    if (!f.exists()) {
      println("設定ファイルが見つからないため、デフォルトで起動します。");
      return;
    }

    JSONObject root = loadJSONObject(fullPath);
    if (root == null) {
      println("設定ファイルの読み込みに失敗しました: " + fullPath);
      return;
    }

    JSONObject inAppSettings = root.getJSONObject("InAppSettings");
    if (inAppSettings == null) {
      println("InAppSettings が見つからないため、既定値を維持します。");
      return;
    }

    JSONObject serverSettings = root.getJSONObject("ServerSettings");

    isDarkTheme = inAppSettings.getBoolean("DarkTheme", isDarkTheme);
    keepWindowPos = inAppSettings.getBoolean("KeepWindowPos", keepWindowPos);
    windowPosX = inAppSettings.getInt("WindowPosX", windowPosX);
    windowPosY = inAppSettings.getInt("WindowPosY", windowPosY);

    if (serverSettings != null) {
      serverType = serverSettings.getString("ServerType", serverType);
      serverPort = serverSettings.getInt("Port", serverPort);
    } else {
      serverType = inAppSettings.getString("ServerType", serverType);
      serverPort = inAppSettings.getInt("Port", serverPort);
    }

    println("設定（InAppSettings / ServerSettings）を読み込みました: " + fullPath);
  }
  catch(Exception e) {
    println("設定の読み込み中にエラーが発生しました: " + fullPath);
    e.printStackTrace();
  }
}

// ユーザー設定をconfigファイルから読み込む
void loadUserProfiles() {
  String fullPath = dataPath("config.json");

  try {
    File f = new File(fullPath);
    if (!f.exists()) {
      println("設定ファイルが見つからないため、デフォルトで起動します。");
      return;
    }

    JSONObject root = loadJSONObject(fullPath);
    if (root == null) {
      println("設定ファイルの読み込みに失敗しました: " + fullPath);
      return;
    }

    JSONObject userProfiles = root.getJSONObject("UserProfiles");
    if (userProfiles == null) {
      println("UserProfiles が見つからないため、既定値を維持します。");
      return;
    }

    textFieldDetails = userProfiles.getString("Details", textFieldDetails);
    textFieldState = userProfiles.getString("State", textFieldState);
    textFieldActivityTitle = userProfiles.getString("ActivityTitle", textFieldActivityTitle);
    dropdownLargeImageKey = userProfiles.getString("Large_Image", dropdownLargeImageKey);
    elapsedTimeMode = userProfiles.getString("ElapsedTimeMode", elapsedTimeMode);

    println("ユーザープロフィール（UserProfiles）を読み込みました: " + fullPath);
  }
  catch(Exception e) {
    println("ユーザープロフィールの読み込み中にエラーが発生しました: " + fullPath);
    e.printStackTrace();
  }
}

// 現在のユーザー設定をconfigファイルへ保存する。
void saveUserProfiles() {
  String fullPath = dataPath("config.json");

  try {
    saveConfigJsonOrdered(fullPath);
    println("ユーザープロフィールを保存しました: " + fullPath);
  }
  catch(Exception e) {
    println("ユーザープロフィールの保存中にエラーが発生しました: " + fullPath);
    e.printStackTrace();
  }
}

// 必要に応じてウィンドウ位置を更新してアプリ設定を保存する
void saveSettings(boolean updateWindowPos) {
  String fullPath = dataPath("config.json");

  try {
    if (updateWindowPos && keepWindowPos) {
      updateWindowPosFromSurface();
    }

    int saveX = windowPosX;
    int saveY = windowPosY;

    windowPosX = saveX;
    windowPosY = saveY;
    saveConfigJsonOrdered(fullPath);
    println("設定を保存しました: " + fullPath);
  }
  catch(Exception e) {
    println("設定の保存中にエラーが発生しました: " + fullPath);
    e.printStackTrace();
  }
}

// JSON文字列として安全に保存できるよう特殊文字を回避？
String escapeJsonString(String value) {
  if (value == null) {
    return "";
  }

  return value
    .replace("\\", "\\\\")
    .replace("\"", "\\\"")
    .replace("\n", "\\n")
    .replace("\r", "\\r")
    .replace("\t", "\\t");
}

// 現在の設定値を所定の順序でJSONファイルとして書き出す
void saveConfigJsonOrdered(String fullPath) {
  StringList lines = new StringList();

  lines.append("{");
  lines.append("  \"InAppSettings\": {");
  lines.append("    \"DarkTheme\": " + isDarkTheme + ",");
  lines.append("    \"KeepWindowPos\": " + keepWindowPos + ",");
  lines.append("    \"WindowPosX\": " + windowPosX + ",");
  lines.append("    \"WindowPosY\": " + windowPosY);
  lines.append("  },");
  lines.append("  \"UserProfiles\": {");
  lines.append("    \"ActivityTitle\": \"" + escapeJsonString(textFieldActivityTitle) + "\",");
  lines.append("    \"Large_Image\": \"" + escapeJsonString(dropdownLargeImageKey) + "\",");
  lines.append("    \"Details\": \"" + escapeJsonString(textFieldDetails) + "\",");
  lines.append("    \"State\": \"" + escapeJsonString(textFieldState) + "\",");
  lines.append("    \"ElapsedTimeMode\": \"" + escapeJsonString(elapsedTimeMode) + "\"");
  lines.append("  },");
  lines.append("  \"ServerSettings\": {");
  lines.append("    \"ServerType\": \"" + escapeJsonString(serverType) + "\",");
  lines.append("    \"Port\": " + serverPort);
  lines.append("  }");
  lines.append("}");

  saveStrings(fullPath, lines.toArray());
}

void mouseReleased() {
  if (isPopupOpen) {
    handleActivePopupMouseReleased();
    return;
  }

  checkTabBarTap();
  if (currentTab == "Connect") {
    if (connectingProgress == "none" || connectingProgress == "failure") {
      checkConnectButton();
    } else if (connectingProgress == "connected") {
      checkRefreshButton();
      checkDisconnectButton();
    }
    textFieldDetails = checkTextBox(width * 0.5, height * 0.35, width * 0.88, height * 0.08, CENTER, "1行目の情報", "1行目の情報を入力してください", textFieldDetails, "Connect");
    textFieldState = checkTextBox(width * 0.5, height * 0.45, width * 0.88, height * 0.08, CENTER, "2行目の情報", "2行目の情報を入力してください", textFieldState, "Connect");
    checkPopupBox(width * 0.388, height * 0.255, width * 0.652, height * 0.08, CENTER, "activityType", "Connect");
    checkPopupBox(width * 0.5, height * 0.57, width * 0.88, height * 0.08, CENTER, "elapsed", "Connect");
    checkPopupBox(width * 0.84, height * 0.255, width * 0.2, height * 0.08, CENTER, "icon", "Connect");
  } else if (currentTab == "Settings") {
    checkSettingsTap();
  }
}

// 指定した範囲内にマウスカーソルがあるか判定する
boolean isMouseOver(float x, float y, float w, float h, int mode) {
  float x1 = 0, y1 = 0, x2 = 0, y2 = 0;

  if (mode == CORNER) {
    x1 = x;
    y1 = y;
    x2 = x + w;
    y2 = y + h;
  } else if (mode == CENTER) {
    x1 = x - w / 2.0;
    y1 = y - h / 2.0;
    x2 = x + w / 2.0;
    y2 = y + h / 2.0;
  } else if (mode == CORNERS) {
    x1 = min(x, w);
    y1 = min(y, h);
    x2 = max(x, w);
    y2 = max(y, h);
  }

  // 現在のマウス座標が計算した範囲に入っているか判定
  if (mouseX >= x1 && mouseX <= x2 && mouseY >= y1 && mouseY <= y2) {
    return true;
  } else {
    return false;
  }
}

void checkTabBarTap() {
  if (mouseY >= tBHeight && mouseY <= height) {

    // 各タブの中心(20%, 50%, 80%)の中間を境界線(35%, 65%)に設定
    if (mouseX < width * 0.35) {
      currentTab = "Connect";
    } else if (mouseX >= width * 0.35 && mouseX < width * 0.65) {
      currentTab = "Record";
    } else if (mouseX >= width * 0.65) {
      currentTab = "Settings";
    }
  }
}

// テキストボックスのクリックを検出して入力ダイアログを開く
String checkTextBox(float x, float y, float w, float h, int mode, String textFieldTitle, String dialogMessage, String targetTextField, String targetTab) {
  if (!activeTextFieldTitle.equals("")) {
    return targetTextField;
  }

  if (isMouseOver(x, y, w, h, mode) == true && currentTab.equals(targetTab)) {

    activeTextFieldTitle = textFieldTitle;

    // ダイアログの情報を予約
    pendingDialogOpen = true;
    pendingDialogTitle = textFieldTitle;
    pendingDialogMessage = dialogMessage;
    pendingTargetValue = targetTextField;
    thread("openInputDialogAsync");
  }
  return targetTextField;
}

// 別スレッドで入力ダイアログを表示し、入力結果を各項目へ反映
void openInputDialogAsync() {
  if (isDialogOpenNow) return;
  isDialogOpenNow = true;

  activeTextFieldTitle = pendingDialogTitle;

  // 最前面に表示するためのダミーウィンドウを一時的に作成
  JFrame dummyFrame = new JFrame();
  dummyFrame.setAlwaysOnTop(true); // 常に最前面
  dummyFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);

  // 第1引数を「null」から「dummyFrame」に変更してダイアログを開く
  String result = JOptionPane.showInputDialog(
    dummyFrame,
    pendingDialogMessage,
    pendingTargetValue
    );

  dummyFrame.dispose(); // ダミーウィンドウを即座に破棄してメモリを解放

  activeTextFieldTitle = "";

  if (pendingDialogTitle.equals("1行目の情報")) {
    if (result == null || result.length() < 2) {
      textFieldDetails = "";
    } else {
      textFieldDetails = result;
    }
  } else if (pendingDialogTitle.equals("2行目の情報")) {
    if (result == null || result.length() < 2) {
      textFieldState = "";
    } else {
      textFieldState = result;
    }
  } else if (pendingDialogTitle.equals("カスタム設定")) {
    if (result != null && result.length() > 0) {
      textFieldActivityTitle = result;
    }
    isPopupOpen = false;
    activePopupMenu = "";
  }
  // 他のテキストボックスはここに追加
  // else if (pendingDialogTitle.equals("")) { serverPortStr = result; }

  saveUserProfiles();
  isDialogOpenNow = false;
}

// Discordへの接続を開始
void checkConnectButton() {
  if (connectingProgress == "none" || connectingProgress == "failure") {
    if (isMouseOver(width * 0.83, height * 0.83, width * 0.24, height * 0.06, CENTER)) {
      println("Clicked Connect button");
      activityStartMillis = resolveActivityStartMillis(true);
      connectingProgress = "connecting";
      int responseCode = updateDiscord(
        textFieldActivityTitle,
        textFieldDetails,
        textFieldState,
        0,
        dropdownLargeImageKey,
        activityStartMillis
        );

      if (responseCode == 200) {
        beginActivityRecordSession(textFieldActivityTitle, System.currentTimeMillis());
        dConnectStatusDisp = "接続完了";
        connectingProgress = "connected";
      } else if (responseCode >= 0) {
        dConnectStatusDisp = "接続失敗";
        connectingProgress = "failure";
      }
    }
  }
  return;
}

// 接続済みの状態からアクティビティを更新
void checkRefreshButton() {
  if (connectingProgress == "connected") {
    if (isMouseOver(width * 0.83, height * 0.83, width * 0.24, height * 0.06, CENTER)) {
      println("Clicked Refresh button");
      activityStartMillis = resolveActivityStartMillis(false);
      int responseCode = updateDiscord(
        textFieldActivityTitle,
        textFieldDetails,
        textFieldState,
        0,
        dropdownLargeImageKey,
        activityStartMillis
        );

      if (responseCode == 200) {
        recordActiveActivitySession(activeRecordActivityTitle, activeRecordStartMillis, System.currentTimeMillis());
        beginActivityRecordSession(textFieldActivityTitle, System.currentTimeMillis());
        isStatusTextChanged = true;
        statusTextChangeStartTime = millis();
        dConnectStatusDisp = "接続完了";
        connectingProgress = "connected";
      } else if (responseCode >= 0) {
        dConnectStatusDisp = "更新失敗";
        connectingProgress = "connected";
      }
    }
  }
  return;
}

// Discordとの接続を切断（アクティビティクリア）
void checkDisconnectButton() {
  if (connectingProgress == "connected") {
    if (isMouseOver(width * 0.56, height * 0.84, width * 0.24, height * 0.06, CENTER)) {
      println("Clicked Disconnect button");
      int responseCode = clearDiscordActivity();

      if (responseCode == 200) {
        recordActiveActivitySession(activeRecordActivityTitle, activeRecordStartMillis, System.currentTimeMillis());
        clearActivityRecordSession();
        isStatusTextChanged = false;
        dConnectStatusDisp = "未接続";
        connectingProgress = "none";
        activityStartMillis = 0;
      } else if (responseCode >= 0) {
        dConnectStatusDisp = "切断失敗";
        connectingProgress = "connected";
      }
    }
  }
  return;
}

void draw() {
  background(cSurface);
  tBHeight = height - height / 9; // ウィンドウサイズの動的変更に対応させるためdraw内で計算
  drawBottomTabBar();
  checkTabBarMouseOver();
  if (currentTab == "Connect") {
    drawScreenConnect();
  } else if (currentTab == "Record") {
    drawScreenRecord();
  } else if (currentTab == "Settings") {
    drawScreenSettings();
  }
  if (isPopupOpen) {
    pushStyle();
    noStroke();
    fill(33000000);
    rect(0, 0, width, height);
    popStyle();
  }
}

// サーバープロセス起動
void startServerProcess() throws Exception {
  File nodeServerDir = new File(sketchPath(), "node-server");

  if ("release".equalsIgnoreCase(serverType)) {
    File releaseServerExecutable = findReleaseServerExecutable(nodeServerDir);

    if (releaseServerExecutable != null) {
      nodeServer = new ProcessBuilder(
        releaseServerExecutable.getAbsolutePath()
        ).directory(releaseServerExecutable.getParentFile()).start();

      println("Release server started: " + releaseServerExecutable.getAbsolutePath());
      return;
    }

    throw new FileNotFoundException("Release server executable was not found under node-server.");
  }

  File nodeServerScript = new File(nodeServerDir, "afs_server.js");
  nodeServer = new ProcessBuilder(
    "node",
    nodeServerScript.getAbsolutePath()
    ).directory(nodeServerDir).start();

  println("Node server started: " + nodeServerScript.getAbsolutePath());
  waitForServerReady(serverPort, 10000);
  println("HTTP server is ready on port: " + serverPort);
}


// サーバーが応答可能になるまで待機
void waitForServerReady(int port, int timeoutMillis) throws Exception {
  long startTime = millis();

  while (millis() - startTime < timeoutMillis) {
    if (nodeServer != null && !nodeServer.isAlive()) {
      throw new IOException("Node server process exited before the HTTP port became ready.");
    }

    try {
      Socket socket = new Socket();
      socket.connect(new InetSocketAddress("127.0.0.1", port), 250);
      socket.close();
      return;
    }
    catch (IOException ignored) {
      delay(100);
    }
  }

  throw new IOException("Timed out waiting for HTTP server on port " + port + ".");
}

// サーバー実行ファイルを探す
File findReleaseServerExecutable(File nodeServerDir) {
  File preferredReleaseExecutable = new File(nodeServerDir, "release/afs_server.exe");
  if (preferredReleaseExecutable.exists()) {
    return preferredReleaseExecutable;
  }

  File releaseDir = new File(nodeServerDir, "release");
  if (releaseDir.exists() && releaseDir.isDirectory()) {
    File[] releaseFiles = releaseDir.listFiles();
    if (releaseFiles != null) {
      File foundExecutable = null;

      for (File releaseFile : releaseFiles) {
        if (releaseFile.isFile() && releaseFile.getName().toLowerCase().endsWith(".exe")) {
          if (foundExecutable != null) {
            return null;
          }

          foundExecutable = releaseFile;
        }
      }

      if (foundExecutable != null) {
        return foundExecutable;
      }
    }
  }

  File rootExecutable = new File(nodeServerDir, "afs_server.exe");
  if (rootExecutable.exists()) {
    return rootExecutable;
  }

  File[] rootFiles = nodeServerDir.listFiles();
  if (rootFiles != null) {
    File foundExecutable = null;

    for (File rootFile : rootFiles) {
      if (rootFile.isFile() && rootFile.getName().toLowerCase().endsWith(".exe")) {
        if (foundExecutable != null) {
          return null;
        }

        foundExecutable = rootFile;
      }
    }

    if (foundExecutable != null) {
      return foundExecutable;
    }
  }

  return null;
}

// 起動中のローカルサーバープロセスを終了
void stopServerProcess() {
  if (nodeServer == null) {
    return;
  }

  try {
    println("Server process is shutting down...");
    nodeServer.destroyForcibly();
    println("Server process was terminated.");
  }
  catch (Exception e) {
    e.printStackTrace();
  }
}

// ウィンドウの現在の表示位置を取得
void updateWindowPosFromSurface() {
  if (!keepWindowPos) return;

  try {
    Object nativeWindow = surface.getNative();
    if (nativeWindow instanceof com.jogamp.newt.Window) {
      com.jogamp.newt.Window w = (com.jogamp.newt.Window) nativeWindow;
      windowPosX = w.getX();
      windowPosY = w.getY();
    }
  }
  catch (Exception e) {
    // 取得失敗時は無視
  }
}

// 選択された経過時間モードに対応する開始時刻を返す
long resolveActivityStartMillis(boolean isConnectAction) {
  long nowMillis = System.currentTimeMillis();

  if (elapsedTimeMode == null || elapsedTimeMode.equals("appLaunch")) {
    return appStartMillis > 0 ? appStartMillis : nowMillis;
  }

  if (elapsedTimeMode.equals("resetOnUpdate")) {
    if (isConnectAction || activityStartMillis <= 0) {
      return nowMillis;
    }
    return nowMillis;
  }

  if (activityStartMillis > 0) {
    return activityStartMillis;
  }

  return nowMillis;
}

// 終了前に設定を保存し、ローカルサーバーを停止
@Override
  void exit() {
  if (connectingProgress == "connected") {
    recordActiveActivitySession(activeRecordActivityTitle, activeRecordStartMillis, System.currentTimeMillis());
    clearActivityRecordSession();
  }
  saveSettings(true);
  stopServerProcess();
  super.exit();
}

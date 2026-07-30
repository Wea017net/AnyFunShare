final int HTTP_CONNECT_TIMEOUT_MS = 5000;
final int HTTP_READ_TIMEOUT_MS = 12000;

String categorizeNetworkError(Exception e) {
  if (e instanceof UnknownHostException) {
    return "DNS解決失敗";
  }
  if (e instanceof ConnectException) {
    return "接続拒否";
  }
  if (e instanceof SocketTimeoutException) {
    return "タイムアウト";
  }
  return "通信エラー";
}

int updateDiscord(
  String name,
  String details,
  String state,
  int type,
  String largeImageKey,
  long startTimestampMillis
  ) {

  HttpURLConnection conn = null;

  try {

    URL url = new URL("http://localhost:" + serverPort + "/activity");

    conn =
      (HttpURLConnection)url.openConnection();
    conn.setConnectTimeout(HTTP_CONNECT_TIMEOUT_MS);
    conn.setReadTimeout(HTTP_READ_TIMEOUT_MS);

    conn.setRequestMethod("POST");
    conn.setRequestProperty(
      "Content-Type",
      "application/json"
      );
    conn.setRequestProperty(
      "X-AnyFunShare-Version",
      appVersion
      );

    conn.setDoOutput(true);

    String json =
      "{"
      + "\"name\":\"" + name + "\","
      + "\"details\":\"" + details + "\","
      + "\"state\":\"" + state + "\","
      + "\"type\":" + type
      + (startTimestampMillis > 0 ? ",\"timestamps\":{\"start\":" + startTimestampMillis + "}" : "")
      + ",\"assets\":{"
      + "\"large_image\":\"" + largeImageKey + "\""
      + "}"
      + "}";

    OutputStream os = conn.getOutputStream();
    os.write(json.getBytes("UTF-8"));
    os.close();

    int responseCode = conn.getResponseCode();
    if (responseCode >= 400) {
      InputStream errorStream = conn.getErrorStream();
      if (errorStream != null) {
        BufferedReader errorReader = new BufferedReader(new InputStreamReader(errorStream, "UTF-8"));
        StringBuilder errorBody = new StringBuilder();
        String errorLine;
        while ((errorLine = errorReader.readLine()) != null) {
          errorBody.append(errorLine);
        }
        errorReader.close();
        println("[HTTP] errorBody=" + errorBody.toString());
      }
    }
    println("[HTTP] status=" + responseCode + " url=" + url);
    return responseCode;
  }
  catch(Exception e) {
    println("[HTTP] " + categorizeNetworkError(e) + " url=http://localhost:" + serverPort + "/activity detail=" + e.getClass().getSimpleName());
    return -1;
  }
  finally {
    if (conn != null) {
      conn.disconnect();
    }
  }
}

int clearDiscordActivity() {
  return clearDiscordActivityWithRetry(2);
}

int clearDiscordActivityWithRetry(int maxAttempts) {
  int attempts = max(1, maxAttempts);

  for (int attempt = 1; attempt <= attempts; attempt++) {
    int responseCode = clearDiscordActivityOnce();
    if (responseCode != -1) {
      return responseCode;
    }

    if (attempt < attempts) {
      println("[HTTP] retry clear request attempt=" + (attempt + 1));
    }
  }

  return -1;
}

int clearDiscordActivityOnce() {
  HttpURLConnection conn = null;

  try {

    URL url = new URL("http://localhost:" + serverPort + "/activity/clear");

    conn =
      (HttpURLConnection)url.openConnection();
    conn.setConnectTimeout(HTTP_CONNECT_TIMEOUT_MS);
    conn.setReadTimeout(HTTP_READ_TIMEOUT_MS);

    conn.setRequestMethod("POST");
    conn.setRequestProperty(
      "Content-Type",
      "application/json"
      );
    conn.setDoOutput(true);

    OutputStream os = conn.getOutputStream();
    os.write("{}".getBytes("UTF-8"));
    os.close();

    int responseCode = conn.getResponseCode();
    if (responseCode >= 400) {
      InputStream errorStream = conn.getErrorStream();
      if (errorStream != null) {
        BufferedReader errorReader = new BufferedReader(new InputStreamReader(errorStream, "UTF-8"));
        StringBuilder errorBody = new StringBuilder();
        String errorLine;
        while ((errorLine = errorReader.readLine()) != null) {
          errorBody.append(errorLine);
        }
        errorReader.close();
        println("[HTTP] errorBody=" + errorBody.toString());
      }
    }
    println("[HTTP] status=" + responseCode + " url=" + url);
    return responseCode;
  }
  catch(Exception e) {
    println("[HTTP] " + categorizeNetworkError(e) + " url=http://localhost:" + serverPort + "/activity/clear detail=" + e.getClass().getSimpleName());
    return -1;
  }
  finally {
    if (conn != null) {
      conn.disconnect();
    }
  }
}

JSONObject fetchDiscordActivityState() {
  HttpURLConnection conn = null;

  try {
    URL url = new URL("http://localhost:" + serverPort + "/activity/state");

    conn = (HttpURLConnection)url.openConnection();
    conn.setConnectTimeout(HTTP_CONNECT_TIMEOUT_MS);
    conn.setReadTimeout(HTTP_READ_TIMEOUT_MS);
    conn.setRequestMethod("GET");

    int responseCode = conn.getResponseCode();
    if (responseCode != 200) {
      println("[HTTP] status=" + responseCode + " url=" + url);
      return null;
    }

    BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
    StringBuilder sb = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
      sb.append(line);
    }
    reader.close();

    return parseJSONObject(sb.toString());
  }
  catch(Exception e) {
    println("[HTTP] " + categorizeNetworkError(e) + " url=http://localhost:" + serverPort + "/activity/state detail=" + e.getClass().getSimpleName());
    return null;
  }
  finally {
    if (conn != null) {
      conn.disconnect();
    }
  }
}

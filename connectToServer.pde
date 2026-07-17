int updateDiscord(
  String name,
  String details,
  String state,
  int type,
  String largeImageKey,
  long startTimestampMillis
  ) {

  try {

    URL url = new URL("http://localhost:" + serverPort + "/activity");

    HttpURLConnection conn =
      (HttpURLConnection)url.openConnection();

    conn.setRequestMethod("POST");
    conn.setRequestProperty(
      "Content-Type",
      "application/json"
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
    println("Response: " + responseCode);
    return responseCode;
  }
  catch(Exception e) {
    e.printStackTrace();
    return -1;
  }
}

int clearDiscordActivity() {
  try {

    URL url = new URL("http://localhost:" + serverPort + "/activity/clear");

    HttpURLConnection conn =
      (HttpURLConnection)url.openConnection();

    conn.setRequestMethod("POST");
    conn.setDoOutput(true);

    OutputStream os = conn.getOutputStream();
    os.write("{}".getBytes("UTF-8"));
    os.close();

    int responseCode = conn.getResponseCode();
    println("Clear response: " + responseCode);
    return responseCode;
  }
  catch(Exception e) {
    e.printStackTrace();
    return -1;
  }
}

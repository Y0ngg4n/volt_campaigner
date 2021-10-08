class HttpUtils {
  static createHeader(String token) {

    return {
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": "Bearer $token"
    };
  }
}

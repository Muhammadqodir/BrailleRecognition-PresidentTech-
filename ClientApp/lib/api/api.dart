// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:braille_recognition/api/models/translation.dart';
import 'package:braille_recognition/api/models/user.dart';
import 'package:braille_recognition/api/result.dart';
import 'package:braille_recognition/language.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

const String BASE_URL = "https://abduvoitov.uz/braille/backend/";
const String BASE_SERVER_URL = "http://89.111.154.48:5000/";

class Api {
  String token;

  Api({
    this.token = "undefined",
  });

  void setToken(String val) {
    token = val;
  }

  Future<void> addTranslation(TranslationResult res) async {
    Map<String, String> body = {
      "token": token,
      "result_braille": res.resultBraille,
      "input_file": "uploads/" + res.code + ".jpg",
      "result_json": "",
      "result_marked": "uploads/" + res.code + ".jpg",
      "result": res.result,
      "lang": res.langCode,
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}add_translation.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        print(response.body);
        Map<String, dynamic> res = jsonDecode(response.body);
      } catch (e, stack) {
        print(response.body);
      }
    } else {
      print(response.body);
    }
  }

  Future<ApiResult<TranslationResult>> translate(
    File image,
    String lang,
  ) async {
    log("Image size before compressing:${image.lengthSync()}");
    XFile? compressed = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      join((await getApplicationSupportDirectory()).path,
          "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}_compressed.jpeg"),
      minWidth: 1920,
      minHeight: 1080,
    );

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${BASE_SERVER_URL}upload"),
    );

    request.fields["lang"] = lang;
    request.fields["token"] = token;
    request.files.add(
      http.MultipartFile.fromBytes(
        'images[]',
        await compressed!.readAsBytes(),
        filename: "photo.jpg",
      ),
    );

    http.Response response =
        await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> res = jsonDecode(response.body);
        return ApiResult.success(
          data: TranslationResult(
            id: res["result"]["id"],
            code: "",
            result: res["result"]["plainRes"],
            imageData: Uint8List(0),
            imageUrl: res["result"]["markedImage"],
            resultBraille: res["result"]["unicodeRes"],
            resultJson: res["result"]["jsonRes"],
            langCode: res["result"]["lang"],
            isFav: false,
          ),
        );
      } catch (e, stack) {
        return ApiResult.error(message: e.toString() + "\n" + stack.toString());
      }
    } else {
      return ApiResult.error(
          message: "${response.statusCode}\n${response.body}");
    }
  }

  Future<ApiResult<List<Language>>> getAvailableLangs() async {
    http.Response response =
        await http.get(Uri.parse("${BASE_URL}get_langs.php"));
    if (response.statusCode == 200) {
      try {
        List<Language> history = [];
        List<dynamic> elemets = jsonDecode(response.body);
        for (var element in elemets) {
          history.add(Language(element["title"], element["lang_code"]));
        }
        return ApiResult.success(data: history, message: "Success");
      } catch (e, stack) {
        return ApiResult.error(message: e.toString() + "\n" + stack.toString());
      }
    } else {
      return ApiResult.error(message: response.body);
    }
  }

  Future<ApiResult<List<TranslationResult>>> getHistory() async {
    Map<String, String> body = {
      "token": token,
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}get_history.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res["success"]) {
          List<TranslationResult> history = [];
          for (var element in res["data"]) {
            history.add(
              TranslationResult(
                id: int.parse(element["id"]),
                result: element["result"],
                code: "",
                resultBraille: element["result_braille"],
                resultJson: element["result_json"],
                imageData: Uint8List(0),
                imageUrl: element["result_marked"],
                langCode: element["lang"],
                isFav: element["is_fav"] == "1",
              ),
            );
          }
          return ApiResult.success(data: history, message: res["message"]);
        } else {
          return ApiResult.error(message: res["message"]);
        }
      } catch (e, stack) {
        return ApiResult.error(message: e.toString() + "\n" + stack.toString());
      }
    } else {
      return ApiResult.error(message: response.body);
    }
  }

  Future<ApiResult<User>> setRole(String role) async {
    Map<String, String> body = {
      "token": token,
      "role": role,
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}set_role.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        print(response.body);
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res["success"]) {
          return ApiResult.success(
            data: User.fromMap(res["data"]),
            message: res["message"],
          );
        } else {
          return ApiResult.error(message: res["message"]);
        }
      } catch (e, stack) {
        return ApiResult.error(message: e.toString() + "\n" + stack.toString());
      }
    } else {
      return ApiResult.error(message: response.body);
    }
  }

  Future<ApiResult<bool>> rateTranslation(int id, int rating) async {
    Map<String, String> body = {
      "token": token,
      "id": id.toString(),
      "rating": rating.toString(),
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}set_rating.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        print(response.body);
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res["success"]) {
          return ApiResult.success(
            data: true,
            message: res["message"],
          );
        } else {
          return ApiResult.error(message: res["message"]);
        }
      } catch (e, stack) {
        print(response.body);
        return ApiResult.error(message: "$e\n$stack");
      }
    } else {
      print(response.body);
      return ApiResult.error(message: response.body);
    }
  }

  Future<ApiResult<bool>> setFav(int id, String fav) async {
    Map<String, String> body = {
      "token": token,
      "id": id.toString(),
      "fav": fav,
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}set_fav.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        print(response.body);
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res["success"]) {
          return ApiResult.success(
            data: true,
            message: res["message"],
          );
        } else {
          return ApiResult.error(message: res["message"]);
        }
      } catch (e, stack) {
        print(response.body);
        return ApiResult.error(message: "$e\n$stack");
      }
    } else {
      print(response.body);
      return ApiResult.error(message: response.body);
    }
  }

  Future<ApiResult<bool>> setNotification(String notificationToken) async {
    Map<String, String> body = {
      "token": token,
      "notification_token": notificationToken,
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}set_notification_token.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res["success"]) {
          return ApiResult.success(data: true, message: res["message"]);
        } else {
          return ApiResult.error(message: res["message"]);
        }
      } catch (e, stack) {
        return ApiResult.error(message: e.toString() + "\n" + stack.toString());
      }
    } else {
      return ApiResult.error(message: response.body);
    }
  }

  Future<ApiResult<String>> registerNewUser(
      String name, String email, String password, String role) async {
    Map<String, String> body = {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
      "extra": Platform.isAndroid ? "android" : "ios"
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}register.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res["success"]) {
          token = res["token"];
          return ApiResult.success(data: res["token"], message: res["message"]);
        } else {
          return ApiResult.error(message: res["message"]);
        }
      } catch (e) {
        return ApiResult.error(message: response.body);
      }
    } else {
      return ApiResult.error(message: response.body);
    }
  }

  Future<ApiResult<User>> login(
    String email,
    String password,
  ) async {
    Map<String, String> body = {
      "email": email,
      "password": password,
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}login.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res["success"]) {
          token = res["data"]["token"];
          return ApiResult.success(
            data: User.fromMap(
              res["data"],
            ),
            message: res["message"],
          );
        } else {
          return ApiResult.error(message: res["message"]);
        }
      } catch (e, trace) {
        return ApiResult.error(message: e.toString() + "\n" + trace.toString());
      }
    } else {
      return ApiResult.error(message: response.body);
    }
  }

  Future<ApiResult<User>> loginGoogle(
    String email,
    String name,
    String authToken,
    String photoUrl,
  ) async {
    Map<String, String> body = {
      "email": email,
      "name": name,
      "photo_url": photoUrl,
      "extra": Platform.isAndroid ? "android" : "ios",
      "authToken": authToken,
    };

    http.Response response = await http.post(
      Uri.parse("${BASE_URL}google_auth.php"),
      body: body,
    );
    if (response.statusCode == 200) {
      try {
        print(response.body);
        Map<String, dynamic> res = jsonDecode(response.body);
        if (res["success"]) {
          token = res["data"]["token"];
          return ApiResult.success(
            data: User.fromMap(
              res["data"],
            ),
            message: res["message"],
          );
        } else {
          return ApiResult.error(message: res["message"]);
        }
      } catch (e, trace) {
        return ApiResult.error(message: e.toString() + "\n" + trace.toString());
      }
    } else {
      return ApiResult.error(message: response.body);
    }
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

class TranslationResult {
  int id;
  String result;
  String code;
  Uint8List imageData;
  String imageUrl;
  String resultBraille;
  String resultJson;
  String langCode;
  bool isFav;
  TranslationResult({
    required this.code,
    required this.id,
    required this.result,
    required this.imageData,
    required this.imageUrl,
    required this.resultBraille,
    required this.resultJson,
    required this.langCode,
    required this.isFav,
  });
}

class TranslationResultOld {
  int id;
  String result;
  String imageData;
  String resultBraille;
  String resultJson;
  String langCode;
  bool isFav;
  TranslationResultOld({
    required this.id,
    required this.result,
    required this.imageData,
    required this.resultBraille,
    required this.resultJson,
    required this.langCode,
    required this.isFav,
  });
}

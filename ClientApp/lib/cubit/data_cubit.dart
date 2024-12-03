import 'package:bloc/bloc.dart';
import 'package:braille_recognition/api/api.dart';
import 'package:braille_recognition/api/models/translation.dart';
import 'package:braille_recognition/api/result.dart';
import 'package:braille_recognition/language.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'data_state.dart';

class DataCubit extends Cubit<DataState> {
  DataCubit(String token)
      : super(
          DataState(
            items: [],
            langs: [
              Language("GR1 English", "EN"),
              Language("GR2 English", "EN2"),
              Language("Portuguese", "EN"),
              Language("Russian", "RU"),
              Language("Uzbek", "UZ"),
              Language("Uzbek(Latin)", "UZL"),
              Language("Deutsch", "DE"),
              Language("Greek", "GR"),
              Language("Latvian", "LV"),
              Language("Polish", "PL"),
            ],
          ),
        ) {
    api = Api(token: token);
  }

  Api api = Api();

  void setToken(String token) {
    api.setToken(token);
  }

  Future<void> getHistory() async {
    ApiResult<List<TranslationResult>> history = await api.getHistory();
    if (history.isSuccess) {
      emit(state.copyWith(items: history.data));
    } else {
      Fluttertoast.showToast(msg: history.message);
    }
  }

  String getLangTitle(String code) {
    for (var element in state.langs) {
      if (element.code == code) {
        return element.title;
      }
    }
    return "Undefined";
  }

  Future updateAvailableLangs() async {
    ApiResult<List<Language>> res = await api.getAvailableLangs();
    if (res.isSuccess) {
      emit(state.copyWith(langs: res.data));
    } else {
      Fluttertoast.showToast(msg: res.message);
    }
  }
}

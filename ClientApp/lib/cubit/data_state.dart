// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'data_cubit.dart';

class DataState {
  List<TranslationResult> items;
  List<Language> langs;
  DataState({required this.items, required this.langs});

  DataState copyWith({
    List<TranslationResult>? items,
    List<Language>? langs,
  }) {
    return DataState(
      items: items ?? this.items,
      langs: langs ?? this.langs,
    );
  }
}

import 'package:braille_recognition/api/models/translation.dart';
import 'package:braille_recognition/cubit/data_cubit.dart';
import 'package:braille_recognition/widgets/history_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContentHistory extends StatefulWidget {
  const ContentHistory({super.key, required this.context});

  final BuildContext context;

  @override
  State<ContentHistory> createState() => _ContentHistoryState();
}

class _ContentHistoryState extends State<ContentHistory> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  List<TranslationResult> getFavs(List<TranslationResult> items) {
    List<TranslationResult> favs = [];
    for (var item in items) {
      if (item.isFav) {
        favs.add(item);
      }
    }
    return favs;
  }

  @override
  Widget build(BuildContext context) {
    List<TranslationResult> items = context.read<DataCubit>().state.items;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Favorites",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                // MyButton(
                //   onTap: () {
                //     getData();
                //   },
                //   child: SvgPicture.asset("images/notification.svg"),
                //   width: 24,
                //   height: 24,
                // )
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    context.read<DataCubit>().getHistory();
                  },
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: getFavs(items).isNotEmpty
                            ? Column(
                                children: getFavs(items)
                                    .map((e) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 24),
                                          child: HistoryItem(
                                            result: e,
                                          ),
                                        ))
                                    .toList(),
                              )
                            : Center(
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 50,
                                    ),
                                    Image.asset(
                                      "images/empty.png",
                                      width: 150,
                                    ),
                                    Text(
                                      "Your favorites page is empty.\nStart adding items to your favorites!",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .color!
                                                .withAlpha(150),
                                          ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

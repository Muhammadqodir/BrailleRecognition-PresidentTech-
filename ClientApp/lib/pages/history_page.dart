import 'package:braille_recognition/api/models/translation.dart';
import 'package:braille_recognition/cubit/data_cubit.dart';
import 'package:braille_recognition/widgets/custom_button.dart';
import 'package:braille_recognition/widgets/history_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.context});

  final BuildContext context;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<TranslationResult> items = context.read<DataCubit>().state.items;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  MyButton(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset("icons/back.svg"),
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      "History",
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
                          child: items.isNotEmpty
                              ? Column(
                                  children: items
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 24),
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
                                        "Your history list is empty!",
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
      ),
    );
  }
}

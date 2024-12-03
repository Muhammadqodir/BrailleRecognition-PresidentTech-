import 'package:braille_recognition/api/api.dart';
import 'package:braille_recognition/api/models/translation.dart';
import 'package:braille_recognition/cubit/data_cubit.dart';
import 'package:braille_recognition/pages/image_result.dart';
import 'package:braille_recognition/pages/image_viewer_page.dart';
import 'package:braille_recognition/widgets/ontap_scale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem extends StatefulWidget {
  const HistoryItem({
    super.key,
    required this.result,
  });

  final TranslationResult result;

  @override
  State<HistoryItem> createState() => _HistoryItemState(result.isFav);
}

class _HistoryItemState extends State<HistoryItem> {
  bool isFav = false;

  _HistoryItemState(this.isFav);

  Future<Api> initApi() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token") ?? "undefined";
    return Api(token: token);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void toggleFav() async {
    Api api = await initApi();
    await api.setFav(widget.result.id, !isFav ? "1" : "0");
    await context.read<DataCubit>().getHistory();
    setState(() {
      isFav = !isFav;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnTapScaleAndFade(
      lowerBound: 0.90,
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: ((context) {
              return ImageResultPage(
                result: widget.result,
              );
            }),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 20,
              offset: const Offset(0, 10), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          children: [
            OnTapScaleAndFade(
              onTap: () {
                // Translator.translate(widget.result.image);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) {
                      return ImageViewer(
                        imageProvider: widget.result.imageData.length > 0
                            ? MemoryImage(
                                widget.result.imageData,
                              )
                            : Image.network(
                                BASE_SERVER_URL + widget.result.imageUrl,
                              ).image,
                      );
                    }),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 4), // changes position of shadow
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12),
                  ),
                  child: Image(
                    image: widget.result.imageData.length > 0
                        ? MemoryImage(
                            widget.result.imageData,
                          )
                        : Image.network(
                            BASE_SERVER_URL + widget.result.imageUrl,
                          ).image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.result.result
                        .substring(widget.result.result.indexOf("\n") + 1),
                    maxLines: 4,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // const SizedBox(
                  //   height: 8,
                  // ),
                  // Text(
                  //   widget.result.resultBraille,
                  //   maxLines: 1,
                  //   overflow: TextOverflow.fade,
                  //   style: Theme.of(context).textTheme.bodySmall!,
                  // ),
                ],
              ),
            ),
            OnTapScaleAndFade(
              onTap: toggleFav,
              child: Opacity(
                opacity: 0.7,
                child: SvgPicture.asset(
                  isFav ? "icons/star_gradient.svg" : "icons/star_outline.svg",
                  height: isFav ? 23 : 22,
                  width: isFav ? 23 : 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

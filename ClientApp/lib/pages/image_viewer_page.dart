import 'package:braille_recognition/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class ImageViewer extends StatefulWidget {
  ImageViewer({Key? key, required this.imageProvider}) : super(key: key);

  ImageProvider imageProvider;

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Appodeal.show(AppodealAdType.Interstitial);
  }

  @override
  Widget build(BuildContext context) {
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
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset("icons/back.svg"),
                    width: 24,
                    height: 24,
                  ),
                  Expanded(
                    child: Text(
                      "Marked image",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  MyButton(
                    onTap: () {},
                    child: SvgPicture.asset("icons/share.svg"),
                    width: 24,
                    height: 24,
                  )
                ],
              ),
            ),
            Expanded(
              child: PhotoView(
                minScale: 0.4,
                maxScale: 0.9,
                backgroundDecoration: BoxDecoration(color: Colors.white),
                heroAttributes: const PhotoViewHeroAttributes(tag: "image"),
                imageProvider: widget.imageProvider,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

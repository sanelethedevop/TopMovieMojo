import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TvSeriesPlayer extends StatefulWidget {
  const TvSeriesPlayer(
      {super.key,
      required this.movieId,
      required this.seasonNumber,
      required this.episodeNumber});
  final int movieId;
  final int seasonNumber;
  final int episodeNumber;

  @override
  State<TvSeriesPlayer> createState() => _TvSeriesPlayerState();
}

class _TvSeriesPlayerState extends State<TvSeriesPlayer> {
  @override
  Widget build(BuildContext context) {
    final String videoUrl =
        'https://autoembed.to/tv/tmdb/${widget.movieId}-${widget.seasonNumber}-${widget.episodeNumber}?server=2';

    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return InAppWebView(
              initialUrlRequest: URLRequest(url: Uri.parse(videoUrl)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
                android: AndroidInAppWebViewOptions(
                  useWideViewPort: true,
                  loadWithOverviewMode: true,
                  useHybridComposition: true,
                ),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                ),
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Pop-up ad closed, if the movie has not started, hit play again'),
                ));
                return NavigationActionPolicy.CANCEL;
              },
            );
          },
        ),
      ),
    );
  }
}

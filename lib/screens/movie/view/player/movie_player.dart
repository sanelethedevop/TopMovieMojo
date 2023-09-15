import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MoviePlayer extends StatefulWidget {
  const MoviePlayer({super.key, required this.movieId});
  final int movieId;

  @override
  State<MoviePlayer> createState() => _MoviePlayerState();
}

class _MoviePlayerState extends State<MoviePlayer> {
  @override
  Widget build(BuildContext context) {
    final String videoUrl =
        'https://autoembed.to/movie/tmdb/${widget.movieId}?server=2';

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

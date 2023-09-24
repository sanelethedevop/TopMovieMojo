import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:moviemojo/core/utils.dart';
import 'package:moviemojo/screens/home/widgets/moviecard.dart';
import 'package:moviemojo/screens/movie/view/player/movie_player.dart';

import '../../../constants/tmdb_constants.dart';
import 'package:http/http.dart' as http;

import '../widgets/rating_widget.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key, required this.movieId});
  final int movieId;

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  InterstitialAd? _interstitialAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  RewardedAd? _rewardedAd;

  final String _interstitialAdUnitId = 'ca-app-pub-9629396337903863/5468468652';
  final String _rewardedInterAdUnitId =
      'ca-app-pub-9629396337903863/4479654760';
  final String _rewardedAdUnitId = 'ca-app-pub-9629396337903863/8844359467';

  bool isInterstitialAdLoaded = false;
  bool isRewardedInterstitialAdLoaded = false;
  bool isRewardedAdLoaded = false;

  void initInterstitialAd() {
    InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            isInterstitialAdLoaded = true;

            log('Inter ad loaded ${ad.onPaidEvent}, ${ad.request.keywords} , ${ad.request.extras}');
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                initInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            log('Ad failed to load ${error.message}');
          },
        ));
  }

  void initRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
        adUnitId: _rewardedInterAdUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedInterstitialAd = ad;
            isRewardedInterstitialAdLoaded = true;
            log('Rewarded Inter AD Loaded');
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                initRewardedInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            log('Rewarded Inter Ad Failed to load ${error.message}');
          },
        ));
  }

  void initRewardedAd() {
    RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            log('Rewarded Ad Loaded');
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                initRewardedAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            log('RewardedAd Failed to load');
          },
        ));
  }

  void showInterAd() {
    if (isInterstitialAdLoaded) {
      _interstitialAd!.show();
    }
  }

  void showRewardedInterAd() {
    if (isRewardedInterstitialAdLoaded) {
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          log('Ad finished ${ad.responseInfo!.responseExtras}');
        },
      );
    }
  }

  void showRewardedAd() {
    if (isRewardedAdLoaded) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          log('RewardedAd finished ${ad.responseInfo!.responseExtras}');
        },
      );
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/movie/$movieId?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<Map<String, dynamic>> getSimillarMovies(int movieId) async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/movie/$movieId/similar?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<Map<String, dynamic>> getMovieImages(int movieId) async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/movie/$movieId/images?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  String errorHandler(String snapshotError) {
    if (snapshotError == 'Failed host lookup: \'api.themoviedb.org\'') {
      return 'No Netowrk connection';
    }
    if (snapshotError == 'Software caused connection abort') {
      return 'No Netowrk connection';
    }
    return 'Some unexpected Error occured';
  }

  showRandomAdType(int randomAd) {
    if (randomAd == 0) {
      showInterAd();
    }
    if (randomAd == 1) {
      showRewardedInterAd();
    } else {
      showRewardedAd();
    }
  }

  String overviewText(String overview) {
    if (overview.characters.length >= 150) {
      return "${overview.substring(0, 150)}...";
    } else {
      return overview;
    }
  }

  @override
  void initState() {
    super.initState();
    initInterstitialAd();
    initRewardedInterstitialAd();
    initRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getMovieDetails(widget.movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          final movieData = snapshot.data!;

          String? posterPath = movieData['backdrop_path'];
          String title = movieData['title'];
          double rating = movieData['vote_average'];
          int totalVotes = movieData['vote_count'];
          String overview = movieData['overview'];
          int duration = movieData['runtime'];
          String posterUrl = 'https://image.tmdb.org/t/p/w500$posterPath';

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                height: Screen.height(context) * 1.07,
                width: Screen.width(context),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      height: Screen.height(context) * .4,
                      width: Screen.width(context) * .95,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(posterUrl), fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RatingGlassWidget(
                            rating: rating.toStringAsFixed(2),
                            totalVotes: totalVotes,
                          ),
                          WhiteText(
                            text: title,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                          GreyText(
                              text:
                                  '${duration ~/ 60} Hrs ${duration % 60} Min')
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () async {
                                int randomAd = math.Random().nextInt(2);
                                log('$randomAd');
                                showRandomAdType(randomAd);
                                Screen.to(context,
                                    MoviePlayer(movieId: widget.movieId));
                              },
                              child: const Text('Watch For Free Now ')),
                        )
                      ],
                    ),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.all(5.0),
                      width: Screen.width(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WhiteText(
                                  text: 'Movie Overview:',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              const SizedBox(
                                height: 10,
                              ),
                              WhiteText(
                                text: overviewText(overview),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          WhiteText(
                            text: 'Movie Images',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          FutureBuilder(
                            future: getMovieImages(widget.movieId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<Widget> images = [];
                                final Map<String, dynamic> movieImagesRawData =
                                    snapshot.data!;
                                final List imgaesData =
                                    movieImagesRawData['backdrops'];

                                for (var movieImageData in imgaesData) {
                                  final String movieFilePath =
                                      movieImageData['file_path'];
                                  final String imageUrl =
                                      'https://image.tmdb.org/t/p/w500$movieFilePath';
                                  final Widget movieImage = Container(
                                    margin: const EdgeInsets.all(2.0),
                                    height: Screen.height(context) * .2,
                                    child: Image.network(imageUrl),
                                  );
                                  images.add(movieImage);
                                  log(movieFilePath);
                                }
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: images,
                                  ),
                                );
                              }

                              return const Text('Loading');
                            },
                          ),
                          const Spacer(),
                          WhiteText(
                            text: 'You may also like:',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          FutureBuilder(
                            future: getSimillarMovies(widget.movieId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<Widget> simillarMoviesWidgets = [];
                                final Map<String, dynamic>
                                    simillarMoviesRawData = snapshot.data!;
                                final List simillarMoviesResults =
                                    simillarMoviesRawData['results'];

                                for (var simillarMovie
                                    in simillarMoviesResults) {
                                  final String movieName =
                                      simillarMovie['title'];
                                  final String? moviePosterPath =
                                      simillarMovie['poster_path'];
                                  if (moviePosterPath != null) {
                                    final String moviePoster =
                                        'https://image.tmdb.org/t/p/w500$moviePosterPath';

                                    final movieWidget = MovieCard(
                                      title: movieName,
                                      genre: '',
                                      posterImagePath: moviePoster,
                                    );
                                    simillarMoviesWidgets.add(movieWidget);
                                  }
                                }
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: simillarMoviesWidgets,
                                  ),
                                );
                              } else {
                                return WhiteText(text: 'Loading');
                              }
                            },
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text(errorHandler(snapshot.error.toString())),
          ),
        );
      },
    );
  }
}

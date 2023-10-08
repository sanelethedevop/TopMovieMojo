import 'dart:convert';
import 'dart:math' as math;
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:moviemojo/core/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moviemojo/screens/tvshow/player/tvseries_player.dart';

import '../../../constants/tmdb_constants.dart';
import 'package:http/http.dart' as http;

import '../../../controller/views_controller.dart';
import '../../movie/widgets/rating_widget.dart';

class TVShowScreen extends ConsumerStatefulWidget {
  const TVShowScreen({super.key, required this.movieId});
  final int movieId;

  @override
  ConsumerState<TVShowScreen> createState() => Consumer_TVShowScreenState();
}

class Consumer_TVShowScreenState extends ConsumerState<TVShowScreen> {
  InterstitialAd? _interstitialAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  final String _interstitialAdUnitId = 'ca-app-pub-9629396337903863/5468468652';
  final String _rewardedInterAdUnitId =
      'ca-app-pub-9629396337903863/4479654760';

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
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                initInterstitialAd();
              },
            );

            log('Inter ad loaded ${ad.onPaidEvent}, ${ad.request.keywords} , ${ad.request.extras}');
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

  showRandomAdType(int randomAd) {
    if (randomAd == 0) {
      showInterAd();
    }
    if (randomAd == 1) {
      showRewardedInterAd();
    }
  }

  Future<Map<String, dynamic>> getSeriesDetails(int series) async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/tv/$series?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<Map<String, dynamic>> getSimillarSeries(int seriesId) async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/tv/$seriesId/similar?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<Map<String, dynamic>> getSeasons(
      int seriesId, int seasonNumber) async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/tv/$seriesId/season/$seasonNumber?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
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
  }

  @override
  Widget build(BuildContext context) {
    final viewsController = ref.watch(viewsControllerProvider);
    return FutureBuilder(
      future: getSeriesDetails(widget.movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          final seriesData = snapshot.data!;
          List<Widget> creators = [];
          List<Widget> genres = [];
          List genresData = seriesData['genres'];
          List creatorsData = seriesData['created_by'];
          String? posterPath = seriesData['backdrop_path'];
          String title = seriesData['name'];
          double rating = seriesData['vote_average'];
          int totalVotes = seriesData['vote_count'];
          int numberOfSeasons = seriesData['number_of_seasons'];
          int numberOfEpisodes = seriesData['number_of_episodes'];

          for (var creator in creatorsData) {
            final String creatorName = creator['name'];
            Widget creatorWidget = GreyText(text: creatorName);
            creators.add(creatorWidget);
          }
          for (var genre in genresData) {
            String genreName() {
              if (genre['name'].toString().contains('&')) {}
              return '${genre['name']}, ';
            }

            Widget genreWidget = GreyText(text: genreName());
            genres.add(genreWidget);
          }
          String overview = seriesData['overview'];
          String posterUrl = 'https://image.tmdb.org/t/p/w500$posterPath';
          log(seriesData.toString());
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 0,
            ),
            body: SingleChildScrollView(
              child: SizedBox(
                height: Screen.height(context) * 1.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        height: Screen.height(context) * .4,
                        width: Screen.width(context) * .95,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(posterUrl),
                              fit: BoxFit.cover),
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
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: const BoxDecoration(color: Colors.blue),
                            child: ExpansionTile(
                              onExpansionChanged: (value) {
                                int randomAd = math.Random().nextInt(1);
                                log('$randomAd');
                                showRandomAdType(randomAd);
                              },
                              title: Center(
                                child: WhiteText(text: 'Watch for free Now'),
                              ),
                              children: [
                                SizedBox(
                                  height: numberOfSeasons <= 3
                                      ? Screen.height(context) * .2
                                      : Screen.height(context) * .3,
                                  width: Screen.width(context),
                                  child: ListView.builder(
                                    itemCount: numberOfSeasons,
                                    itemBuilder: (context, index) {
                                      return ExpansionTile(
                                        title: WhiteText(
                                            text: 'Season ${index + 1}'),
                                        children: [
                                          FutureBuilder(
                                            future: getSeasons(
                                                widget.movieId, index + 1),
                                            builder: (context, snapshot) {
                                              List<Widget> episodesWidget = [];
                                              if (snapshot.hasData) {
                                                Map<String, dynamic>
                                                    seasonRawData =
                                                    snapshot.data!;
                                                List episodes =
                                                    seasonRawData['episodes'];

                                                for (Map<String,
                                                        dynamic> episode
                                                    in episodes) {
                                                  log('$episode');
                                                  Widget episodeWidget =
                                                      InkWell(
                                                    onTap: () {
                                                      viewsController
                                                          .incrementViews();
                                                      Screen.to(
                                                        context,
                                                        TvSeriesPlayer(
                                                            movieId:
                                                                widget.movieId,
                                                            seasonNumber:
                                                                index + 1,
                                                            episodeNumber: episode[
                                                                'episode_number']),
                                                      );
                                                      log('Going to play ${index + 1}:${episode['episode_number']}');
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      color: Colors.green,
                                                      height: 50,
                                                      width: 50,
                                                      child: WhiteText(
                                                          text:
                                                              '${episode['episode_number']}'),
                                                    ),
                                                  );
                                                  episodesWidget
                                                      .add(episodeWidget);
                                                }

                                                return Wrap(
                                                  children: episodesWidget,
                                                );
                                              }
                                              return const Text(
                                                  'Loading episodes');
                                            },
                                          )
                                        ],
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ))
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          width: Screen.width(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  WhiteText(
                                    text: 'OverView',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  WhiteText(text: overviewText(overview)),
                                ],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      WhiteText(text: 'Creators : '),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      ...creators
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      WhiteText(text: 'Genres : '),
                                      ...genres
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      WhiteText(text: 'Number of seasons : '),
                                      GreyText(text: '$numberOfSeasons')
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      WhiteText(text: 'Number of Episodes : '),
                                      GreyText(text: '$numberOfEpisodes')
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Center(
          child: Text('${snapshot.error}'),
        );
      },
    );
  }
}

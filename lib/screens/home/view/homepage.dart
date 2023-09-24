import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:moviemojo/constants/tmdb_constants.dart';
import 'package:moviemojo/core/utils.dart';
import 'package:http/http.dart' as http;
import 'package:moviemojo/screens/tvshow/view/tv_showscreen.dart';

import '../../featured_movies/featured_movie_screen.dart';
import '../../movie/view/moviescreen.dart';
import '../../trending_movies/trending_movies.dart';
import '../widgets/moviecard.dart';
import '../widgets/slider_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NativeAd? _nativeAd;
  final String _nativeAdUnitId = 'ca-app-pub-9629396337903863/7423714000';
  bool _isNativeAdLoaded = false;

  initNativeAd() {
    _nativeAd = NativeAd(
        adUnitId: _nativeAdUnitId,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('Ad Loaded');
            setState(() {
              _isNativeAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            log('Ad failed to load ${error.message}');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
            templateType: TemplateType.small,
            mainBackgroundColor: Colors.black))
      ..load();
  }

  Future<Map<String, dynamic>> getTrendingNow() async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/trending/all/day?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<Map<String, dynamic>> getNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/movie/now_playing?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<Map<String, dynamic>> getTrendingSeries() async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/trending/tv/day?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  final ScrollController scrollController = ScrollController();
  double scrollPosition = 0.0;
  double itemWidth = 200.0; // Width of each item in the slider
  int currentIndex = 0;
  int totalItems = 12; // Total number of items in the slider
  late Timer timer;
  void scrollToIndex(int index) {
    scrollPosition = itemWidth * index;
    scrollController.animateTo(
      scrollPosition,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void startAutoScroll() {
    timer =
        Timer.periodic(const Duration(seconds: 3, milliseconds: 800), (timer) {
      if (currentIndex < totalItems - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      scrollToIndex(currentIndex);
    });
  }

  @override
  void initState() {
    super.initState();
    initNativeAd();
  }

  @override
  void dispose() {
    timer.cancel();
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder(
                future: getTrendingSeries(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    List<Widget> movies = [];
                    final List allTrendingMovies = snapshot.data!['results'];

                    for (var element in allTrendingMovies) {
                      String? posterPath = element['backdrop_path'];
                      String title = element['name'];
                      double rating = element['vote_average'];
                      int movieId = element['id'];
                      String posterUrl =
                          'https://image.tmdb.org/t/p/w500$posterPath';

                      if (posterPath != null) {
                        Widget movieUi = InkWell(
                          onTap: () {
                            log('$element');
                            Screen.to(context, TVShowScreen(movieId: movieId));
                          },
                          child: SliderWidget(
                            backdropImage: posterUrl,
                            rating: '$rating',
                            title: title,
                          ),
                        );

                        movies.add(movieUi);
                      }
                    }
                    if (_isNativeAdLoaded) {
                      int randomIndex = math.Random().nextInt(4);
                      Widget nativeADContainer = ConstrainedBox(
                        constraints: const BoxConstraints(
                            minHeight: 90,
                            minWidth: 320,
                            maxHeight: 200,
                            maxWidth: 400),
                        child: AdWidget(ad: _nativeAd!),
                      );

                      movies.insert(randomIndex, nativeADContainer);
                    }
                    startAutoScroll();
                    return SingleChildScrollView(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: movies,
                      ),
                    );
                  }
                  return Text(snapshot.error.toString());
                }),
            FutureBuilder(
                future: getTrendingNow(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> movies = [];
                    final List allTrendingMovies = snapshot.data!['results'];

                    for (var element in allTrendingMovies) {
                      String posterPath = element['poster_path'];
                      String posterUrl =
                          'https://image.tmdb.org/t/p/w500$posterPath';
                      bool isTvShow = element['media_type'] == 'tv';

                      final String title =
                          isTvShow ? element['name'] : element['title'];
                      final int movieId = element['id'];
                      final Widget movieUi = InkWell(
                        onTap: () {
                          Screen.to(
                              context,
                              isTvShow
                                  ? TVShowScreen(movieId: movieId)
                                  : MovieScreen(movieId: movieId));
                        },
                        child: MovieCard(
                          title: title,
                          genre: 'action',
                          posterImagePath: posterUrl,
                        ),
                      );
                      movies.add(movieUi);
                    }

                    return Column(
                      children: [
                        ListTile(
                          title: WhiteText(
                            text: 'Trending Now',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                Screen.to(context, const TrendingMovies());
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              )),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: movies,
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(snapshot.error.toString());
                }),
            FutureBuilder(
                future: getNowPlayingMovies(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    List<Widget> movies = [];
                    final List allTrendingMovies = snapshot.data!['results'];

                    for (var element in allTrendingMovies) {
                      String posterPath = element['poster_path'];
                      String posterUrl =
                          'https://image.tmdb.org/t/p/w500$posterPath';
                      //  log(element.toString());

                      final String title = element['title'];
                      final int movieId = element['id'];
                      final Widget movieUi = InkWell(
                        onTap: () {
                          //  fecthMovie(title);
                          Screen.to(
                            context,
                            MovieScreen(movieId: movieId),
                          );
                        },
                        child: MovieCard(
                          title: title,
                          genre: 'action',
                          posterImagePath: posterUrl,
                        ),
                      );
                      movies.add(movieUi);
                    }
                    return Column(
                      children: [
                        ListTile(
                          title: WhiteText(
                            text: 'Featured Movies',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                Screen.to(context, const FeaturedMovies());
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              )),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: movies,
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(snapshot.error.toString());
                }),
          ],
        ),
      ),
    );
  }
}

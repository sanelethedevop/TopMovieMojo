import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:moviemojo/constants/tmdb_constants.dart';
import 'package:moviemojo/core/utils.dart';
import 'package:http/http.dart' as http;
import 'package:moviemojo/screens/tvshow/view/tv_showscreen.dart';

import '../../movie/view/moviescreen.dart';
import '../widgets/moviecard.dart';
import '../widgets/slider_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Future<Map<String, dynamic>> getPopularMoview() async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/movie/popular?api_key=${TMDBConstants.tmdbApi}'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<Map<String, dynamic>> getTopRatedSeries() async {
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
                future: getTopRatedSeries(),
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
                              onPressed: () {},
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
                future: getPopularMoview(),
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
                              onPressed: () {},
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

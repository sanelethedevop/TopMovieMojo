import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
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
                              onPressed: () {
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
                                  text: overview.length >= 20
                                      ? '${overview.substring(0, 150)}...'
                                      : overview),
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

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moviemojo/core/utils.dart';
import 'package:moviemojo/screens/home/widgets/moviecard.dart';
import 'package:moviemojo/screens/movie/view/moviescreen.dart';

import '../../constants/tmdb_constants.dart';

class UpcomingMovies extends StatefulWidget {
  const UpcomingMovies({super.key});

  @override
  State<UpcomingMovies> createState() => _UpcomingMoviesState();
}

class _UpcomingMoviesState extends State<UpcomingMovies> {
  List movies = [];
  int page = 1;
  Future<Map<String, dynamic>> getUpcomingMovies() async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/movie/upcoming?api_key=${TMDBConstants.tmdbApi}&page=$page'),
    );
    if (response.statusCode == 200) {
      final moviesRawData = jsonDecode(response.body);
      final List results = moviesRawData['results'];
      setState(() {
        movies.addAll(results);
      });
      return moviesRawData;
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  @override
  void initState() {
    getUpcomingMovies();
    super.initState();
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: WhiteText(text: 'New & Upcomming'),
        ),
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            itemCount: movies.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemBuilder: (context, index) {
              if (index == movies.length) {
                if (movies.isNotEmpty) {
                  page++;
                  log('$page');
                  getUpcomingMovies();
                }
                return const Center(child: CircularProgressIndicator());
              } else {
                final Map<String, dynamic> movieData = movies[index];
                final String title = movieData['title'];
                final String? posterPath = movieData['poster_path'];
                final int movieId = movieData['id'];
                final String posterUrl = posterPath == null
                    ? 'https://mtek3d.com/wp-content/uploads/2018/01/image-placeholder-500x500.jpg'
                    : 'https://image.tmdb.org/t/p/w500$posterPath';
                return InkWell(
                  onTap: () {
                    Screen.to(context, MovieScreen(movieId: movieId));
                  },
                  child: MovieCard(
                    title: title,
                    genre: '',
                    posterImagePath: posterUrl,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

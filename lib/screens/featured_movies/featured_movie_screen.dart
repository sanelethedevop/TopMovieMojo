import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moviemojo/core/utils.dart';
import 'package:moviemojo/screens/home/widgets/moviecard.dart';
import 'package:moviemojo/screens/movie/view/moviescreen.dart';

import '../../constants/tmdb_constants.dart';

class FeaturedMovies extends StatefulWidget {
  const FeaturedMovies({super.key});

  @override
  State<FeaturedMovies> createState() => _FeaturedMoviesState();
}

class _FeaturedMoviesState extends State<FeaturedMovies> {
  List movies = [];
  int page = 1;
  Future<Map<String, dynamic>> getFeaturedMovies() async {
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/movie/now_playing?api_key=${TMDBConstants.tmdbApi}&page=$page'),
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
    getFeaturedMovies();
    super.initState();
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: WhiteText(text: 'Featured Movies'),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                    getFeaturedMovies();
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
      ),
    );
  }
}

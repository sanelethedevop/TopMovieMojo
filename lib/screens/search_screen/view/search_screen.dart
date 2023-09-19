import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moviemojo/core/utils.dart';
import 'package:moviemojo/screens/home/widgets/moviecard.dart';
import 'package:moviemojo/screens/movie/view/moviescreen.dart';
import 'package:moviemojo/screens/tvshow/view/tv_showscreen.dart';
import '../../../constants/tmdb_constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool isSearch = false;
  Future<void> _searchMovies(String query) async {
    final String baseUrl = '${TMDBConstants.tmbdBaseUrl}/search/multi';
    final String apiKeyParam = 'api_key=${TMDBConstants.tmdbApi}';
    final String queryParam = 'query=${query.replaceAll(' ', '%20')}';

    final response =
        await http.get(Uri.parse('$baseUrl?$apiKeyParam&$queryParam'));

    if (response.statusCode == 200) {
      final movieResultsRawData = json.decode(response.body);
      setState(() {
        _searchResults = movieResultsRawData['results'];
      });
      log('$_searchResults');
    } else {
      log('Error: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, dynamic>> getTopRatedMovies() async {
    math.Random random = math.Random();
    int randomPage = random.nextInt(500) + 1;
    final response = await http.get(
      Uri.parse(
          '${TMDBConstants.tmbdBaseUrl}/movie/top_rated?api_key=${TMDBConstants.tmdbApi}&page=$randomPage'),
    );

    if (response.statusCode == 200) {
      log(response.body);
      return json.decode(response.body);
    } else {
      log(response.body);
      throw Exception('Failed to load movie details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TextField(
            onChanged: (query) {
              _searchMovies(query);
            },
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _searchResults.clear();
                          _searchController.clear();
                        });
                      },
                      icon: const Icon(Icons.close))
                  : null,
              border: InputBorder.none,
              hintText: 'Search',
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: Screen.height(context) * 1.08,
          width: Screen.width(context),
          child: _searchController.text.isEmpty
              ? Column(
                  children: [
                    ListTile(
                        title: WhiteText(text: 'Top Rated Movies of all Time')),
                    SingleChildScrollView(
                      child: SizedBox(
                        height: Screen.height(context),
                        child: FutureBuilder(
                          future: getTopRatedMovies(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<Widget> moviesUI = [];
                              final List movies = snapshot.data!['results'];
                              for (var movie in movies) {
                                final String title = movie['title'];
                                final String? posterPath = movie['poster_path'];
                                final String posterUrl =
                                    'https://image.tmdb.org/t/p/w500$posterPath';
                                final int movieId = movie['id'];
                                if (posterPath != null) {
                                  final Widget movieUi = InkWell(
                                    onTap: () {
                                      Screen.to(
                                        context,
                                        MovieScreen(movieId: movieId),
                                      );
                                    },
                                    child: MovieCard(
                                      title: title,
                                      genre: '',
                                      posterImagePath: posterUrl,
                                    ),
                                  );
                                  moviesUI.insert(0, movieUi);
                                }
                              }
                              return GridView(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2),
                                children: moviesUI,
                              );
                            }
                            return const Center(
                              child: Text('Loading'),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> movieMap = _searchResults[index];
                    final String mediaType = movieMap['media_type'];
                    final String releaseDate = mediaType == 'tv'
                        ? movieMap['first_air_date']
                        : movieMap['release_date'];
                    final String movieTitle = mediaType == 'tv'
                        ? movieMap['name']
                        : movieMap['title'];
                    final String? posterPath = movieMap['poster_path'];
                    final String posterUrl = posterPath == null
                        ? 'https://mtek3d.com/wp-content/uploads/2018/01/image-placeholder-500x500.jpg'
                        : 'https://image.tmdb.org/t/p/w500$posterPath';
                    final int movieId = movieMap['id'];
                    return InkWell(
                      onTap: () {
                        mediaType == 'tv'
                            ? Screen.to(context, TVShowScreen(movieId: movieId))
                            : Screen.to(
                                context,
                                MovieScreen(movieId: movieId),
                              );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(color: Colors.grey.shade900),
                        child: ListTile(
                          leading: Image.network(posterUrl),
                          title: WhiteText(text: movieTitle),
                          trailing: GreyText(text: releaseDate),
                          subtitle: GreyText(
                              text:
                                  mediaType == 'tv' ? 'Tv Series' : mediaType),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

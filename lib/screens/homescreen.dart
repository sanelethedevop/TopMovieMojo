import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moviemojo/screens/home/view/homepage.dart';
import 'package:moviemojo/screens/upcoming_tv_shows/upcoming_tv_shows.dart';
import 'package:moviemojo/screens/upcomming_movies/upcoming_movies.dart';

import 'search_screen/view/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  late DateTime lastPressedTime;
  List<Widget> pages = [
    const HomePage(),
    const SearchScreen(),
    const UpcomingMovies(),
    const PopularTvShows(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          setState(() {
            selectedIndex = 0;
          });
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: selectedIndex == 1
            ? null
            : AppBar(
                title: const Text('TopMovieMojo'),
                centerTitle: true,
              ),
        body: Center(
          child: pages[selectedIndex],
        ),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              setState(() {
                selectedIndex = value;
              });
            });
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: 'home'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search), label: 'search'),
            BottomNavigationBarItem(
                icon: Icon(Icons.movie_rounded), label: 'Upcoming Movies'),
            BottomNavigationBarItem(
                icon: Icon(Icons.tv), label: 'Popular Series'),
          ],
        ),
      ),
    );
  }
}

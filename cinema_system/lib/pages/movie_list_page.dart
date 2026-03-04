import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/movie.dart';
import 'showing_pages.dart';
import '../widgets/animated_background.dart';
import 'my_page.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  String searchQuery = '';
  String selectedGenre = 'All';

  List<Movie> get filteredMovies {
    return movies.where((movie) {
      final matchesSearch =
          movie.title.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesGenre =
          selectedGenre == 'All' ? true : movie.genres.contains(selectedGenre);

      return matchesSearch && matchesGenre;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: ListView(
            children: [
              _header(),
              _searchSection(),
             FeaturedBanner(
                movies: movies
                    .where((movie) =>
                        movie.title != "Avatar" &&
                        movie.title != "Interstellar")
                    .take(6)
                    .toList(),
              ),

              const SizedBox(height: 20),
              _sectionTitle('Now Playing'),
              _movieHorizontalList(context),
              const SizedBox(height: 20),
              _sectionTitle('Popular'),
              _movieHorizontalList(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

 Widget _header() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Movies',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyPage(),
              ),
            );
          },
        )
      ],
    ),
  );
}


 Widget _searchSection() {
  final genres = ['All', ...movies.expand((m) => m.genres).toSet()];

  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 搜索框
        TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search movies...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 分类按钮
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              final selected = genre == selectedGenre;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedGenre = genre;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: selected
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF6C63FF),
                                Color(0xFF8A85FF),
                              ],
                            )
                          : null,
                      color: selected
                          ? null
                          : Colors.white.withOpacity(0.08),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}



  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _movieHorizontalList(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredMovies.length,
        itemBuilder: (context, index) {
          return _MovieCard(movie: filteredMovies[index]);
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// 🔥 Banner 改为宽度 1/3（高度不变）
//////////////////////////////////////////////////////////////

class FeaturedBanner extends StatefulWidget {
  final List<Movie> movies;

  const FeaturedBanner({super.key, required this.movies});

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  late PageController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      initialPage: 1000,
      viewportFraction: 0.18, // ⭐ 宽度变为原来的 1/3
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_controller.hasClients) {
        _controller.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380, // ⭐ 高度保持不变
      child: PageView.builder(
        controller: _controller,
        itemBuilder: (context, index) {
          final movie =
              widget.movies[index % widget.movies.length];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double scale = 1.0;

              if (_controller.hasClients &&
                  _controller.position.haveDimensions) {
                final page = _controller.page ?? 0;
                scale =
                    (1 - (page - index).abs() * 0.2).clamp(0.85, 1.0);
              }

              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: _buildBannerItem(movie),
          );
        },
      ),
    );
  }

  Widget _buildBannerItem(Movie movie) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ShowingPage(movieTitle: movie.title),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 5 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                movie.poster,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
}

//////////////////////////////////////////////////////////////
// Movie Card
//////////////////////////////////////////////////////////////

class _MovieCard extends StatefulWidget {
  final Movie movie;

  const _MovieCard({required this.movie});

  @override
  State<_MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<_MovieCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.1 : 1.0),
        child: SizedBox(
          width: 220,
          child: Material(
            elevation: _isHovered ? 25 : 6,
            borderRadius: BorderRadius.circular(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: () {
                  
                  Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ShowingPage(movieTitle: widget.movie.title),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final fadeAnimation =
                          CurvedAnimation(parent: animation, curve: Curves.easeInOut);

                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.0)
                              .animate(fadeAnimation),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
                },
                child: Stack(
                  children: [
                    // 🎬 海报
                    Hero(
                      tag: "${widget.movie.id}_poster",
                      child: Image.asset(
                        widget.movie.poster,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),


                    // ⭐ 评分
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.rating.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 🎨 底部渐变遮罩 + 信息
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isHovered ? 1 : 0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${widget.movie.duration} min",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

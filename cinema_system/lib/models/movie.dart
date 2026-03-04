class Movie {
  final String id;
  final String title;
  final double rating;
  final String poster;

  // 👇 新增
  final String description;
  final int duration; // 分钟
  final List<String> genres;

  Movie({
    required this.id,
    required this.title,
    required this.rating,
    required this.poster,
    required this.description,
    required this.duration,
    required this.genres,
  });
}

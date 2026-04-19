import 'package:cinema_system/models/movie.dart';
import 'package:cinema_system/models/showing.dart';
import 'package:cinema_system/models/seat.dart';
import 'package:cinema_system/models/snack.dart';
import 'dart:math';
import '../models/ticket.dart';


List<Ticket> myTickets = [];

final snacks = [
  Snack(
    id: 'popcorn',
    name: 'Popcorn',
    price: 3.0,
    image: 'assets/snacks/popcorn.png',
  ),
  Snack(
    id: 'cola',
    name: 'Coca-Cola',
    price: 2.0,
    image: 'assets/snacks/cola.png',
  ),
  Snack(
    id: 'nachos',
    name: 'Nachos',
    price: 4.5,
    image: 'assets/snacks/nachos.png',
  ),
];


final movies = [
  Movie(
    id: 'interstellar',
    title: 'Interstellar',
    rating: 8.6,
    poster: 'assets/posters/interstellar.jpg',
    duration: 169,
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    description:
        'A team of explorers travel through a wormhole in space in an attempt to ensure humanity’s survival.',
  ),
  Movie(
    id: 'inception',
    title: 'Inception',
    rating: 8.8,
    poster: 'assets/posters/inception.jpg',
    duration: 148,
    genres: ['Sci-Fi', 'Action'],
    description:
        'A thief who steals corporate secrets through dream-sharing technology is given the inverse task of planting an idea.',
  ),
  Movie(
    id: 'avatar',
    title: 'Avatar',
    rating: 7.9,
    poster: 'assets/posters/avatar.jpg',
    duration: 162,
    genres: ['Sci-Fi', 'Adventure'],
    description:
        'A paraplegic Marine is dispatched to the moon Pandora on a unique mission but becomes torn between following orders and protecting an alien civilization.',
  ),
  Movie(
    id: 'dune',
    title: 'Dune',
    rating: 8.2,
    poster: 'assets/posters/dune.jpg',
    duration: 155,
    genres: ['Sci-Fi', 'Adventure', 'Drama'],
    description:
        'Feature adaptation of Frank Herbert’s science fiction novel about the son of a noble family entrusted with the protection of the most valuable asset in the galaxy.',
  ),

  // ================= 新增电影 =================

  Movie(
    id: 'zootopia',
    title: 'Zootopia',
    rating: 8.5,
    poster: 'assets/posters/zootopia.jpg',
    duration: 110,
    genres: ['Animation', 'Adventure', 'Comedy'],
    description:
        'Detectives Judy Hopps and Nick Wilde return to solve a new mystery in the bustling city of Zootopia.',
  ),
  Movie(
    id: 'avengers',
    title: 'Avengers: Endgame',
    rating: 8.4,
    poster: 'assets/posters/avengers.jpg',
    duration: 181,
    genres: ['Action', 'Sci-Fi', 'Adventure'],
    description:
        'After the devastating events of Infinity War, the Avengers assemble once more to reverse Thanos’ actions and restore balance to the universe.',
  ),

  Movie(
  id: 'forrest_gump',
  title: 'Forrest Gump',
  rating: 8.8,
  poster: 'assets/posters/forrest_gump.jpg',
  duration: 142,
  genres: ['Drama', 'Romance'],
  description:
      'The story of Forrest Gump, a man with a low IQ but a kind heart, who unwittingly influences several historical events in the United States while pursuing his lifelong love, Jenny.',
),

  Movie(
  id: 'harry_potter',
  title: 'Harry Potter',
  rating: 8.5,
  poster: 'assets/posters/harry_potter.jpg',
  duration: 152,
  genres: ['Fantasy', 'Adventure'],
  description:
      'An epic fantasy series following the journey of a young wizard, Harry Potter, and his friends as they battle dark forces and uncover the secrets of the magical world.',
),


];


  final showings = [
  Showing(id: 's1', time: '10:00', hallType: 'Standard', movieId: 'Zootopia'),
  Showing(id: 's2', time: '14:00', hallType: 'IMAX', movieId: 'Zootopia'),
  Showing(id: 's3', time: '20:00', hallType: 'VIP', movieId: 'Zootopia'),
];




List<Seat> generateSeatsByHall(String hallType) {
  int rows;
  int cols;

  switch (hallType) {
    case 'IMAX':
      rows = 15;
      cols = 20; // 300 seats
      break;
    case 'VIP':
      rows = 3;
      cols = 4; // 12 seats
      break;
    default:
      rows = 5;
      cols = 10; // 50 seats
  }

  final random = Random();

  return List.generate(rows * cols, (index) {
    final row = index ~/ cols;
    final col = index % cols;

    double soldProbability = hallType == 'IMAX'
        ? 0.4
        : hallType == 'VIP'
            ? 0.15
            : 0.25;

    final isSold = random.nextDouble() < soldProbability;

    return Seat(
      id: index + 1, // mock 数据给个假 id
      row: row,
      col: col,
      status: isSold ? 'SOLD' : 'AVAILABLE',
      selected: false,
    );
  });
}

    
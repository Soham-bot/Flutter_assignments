import 'package:movie_explorer/models/movie.dart';

/// Booking Model representing a confirmed ticket purchase.
class Booking {
  final String bookingId;
  final Movie movie;
  final String customerName;
  final String email;
  final String phone;
  final String showtime;
  final String seatType;
  final double seatPrice;
  final int ticketsCount;
  final bool hasPopcorn;
  final bool sendSms;
  final double totalAmount;
  final DateTime bookingDate;

  Booking({
    required this.bookingId,
    required this.movie,
    required this.customerName,
    required this.email,
    required this.phone,
    required this.showtime,
    required this.seatType,
    required this.seatPrice,
    required this.ticketsCount,
    required this.hasPopcorn,
    required this.sendSms,
    required this.totalAmount,
    required this.bookingDate,
  });
}

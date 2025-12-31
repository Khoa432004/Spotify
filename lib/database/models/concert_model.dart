import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

/// Model cho Concert
class ConcertModel {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final ConcertVenue venue;
  final DateTime dateTime;
  final String? imageUrl;
  final String? ticketUrl;
  final ConcertPrice? price;
  final ConcertStatus status;
  final int? capacity;
  final List<String> attendees;
  final DateTime createdAt;

  ConcertModel({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    required this.venue,
    required this.dateTime,
    this.imageUrl,
    this.ticketUrl,
    this.price,
    this.status = ConcertStatus.upcoming,
    this.capacity,
    this.attendees = const [],
    required this.createdAt,
  });

  factory ConcertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConcertModel(
      id: doc.id,
      title: data['title'] ?? '',
      artistId: data['artistId'] ?? '',
      artistName: data['artistName'] ?? '',
      venue: ConcertVenue.fromMap(data['venue'] ?? {}),
      dateTime: (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'],
      ticketUrl: data['ticketUrl'],
      price: data['price'] != null
          ? ConcertPrice.fromMap(data['price'])
          : null,
      status: ConcertStatusExtension.fromString(data['status'] ?? 'upcoming'),
      capacity: data['capacity'],
      attendees: List<String>.from(data['attendees'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artistId': artistId,
      'artistName': artistName,
      'venue': venue.toMap(),
      'dateTime': Timestamp.fromDate(dateTime),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (ticketUrl != null) 'ticketUrl': ticketUrl,
      if (price != null) 'price': price!.toMap(),
      'status': status.value,
      if (capacity != null) 'capacity': capacity,
      'attendees': attendees,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isUpcoming => status == ConcertStatus.upcoming;
  bool get isOngoing => status == ConcertStatus.ongoing;
  bool get isCompleted => status == ConcertStatus.completed;
  bool get isCancelled => status == ConcertStatus.cancelled;

  ConcertModel copyWith({
    String? id,
    String? title,
    String? artistId,
    String? artistName,
    ConcertVenue? venue,
    DateTime? dateTime,
    String? imageUrl,
    String? ticketUrl,
    ConcertPrice? price,
    ConcertStatus? status,
    int? capacity,
    List<String>? attendees,
    DateTime? createdAt,
  }) {
    return ConcertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      venue: venue ?? this.venue,
      dateTime: dateTime ?? this.dateTime,
      imageUrl: imageUrl ?? this.imageUrl,
      ticketUrl: ticketUrl ?? this.ticketUrl,
      price: price ?? this.price,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      attendees: attendees ?? this.attendees,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ConcertVenue {
  final String name;
  final String address;
  final String city;
  final String country;
  final GeoPoint? coordinates;

  ConcertVenue({
    required this.name,
    required this.address,
    required this.city,
    required this.country,
    this.coordinates,
  });

  factory ConcertVenue.fromMap(Map<String, dynamic> map) {
    return ConcertVenue(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      coordinates: map['coordinates'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'country': country,
      if (coordinates != null) 'coordinates': coordinates,
    };
  }

  String get fullAddress => '$address, $city, $country';
}

class ConcertPrice {
  final double min;
  final double max;
  final String currency;

  ConcertPrice({
    required this.min,
    required this.max,
    this.currency = 'USD',
  });

  factory ConcertPrice.fromMap(Map<String, dynamic> map) {
    return ConcertPrice(
      min: (map['min'] ?? 0).toDouble(),
      max: (map['max'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'USD',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'min': min,
      'max': max,
      'currency': currency,
    };
  }

  String get formattedPrice {
    if (min == max) {
      return '$currency ${min.toStringAsFixed(2)}';
    }
    return '$currency ${min.toStringAsFixed(2)} - ${max.toStringAsFixed(2)}';
  }
}


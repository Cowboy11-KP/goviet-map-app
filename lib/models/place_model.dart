// models/place_model.dart
import 'package:goviet_map_app/models/location_model.dart';

class Comment {
  final String user;
  final String comment;
  final double rating;
  final DateTime date;
  final List<String> images;

  Comment({
    required this.user,
    required this.comment,
    required this.rating,
    required this.date,
    required this.images,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      user: map['user'],
      comment: map['comment'],
      rating: (map['rating'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      images: map['images'] != null 
          ? (map['images'] as List).map((e) => e.toString()).toList() 
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'comment': comment,
      'rating': rating,
      'date': date.toIso8601String(),
    };
  }
}

class Place {
  final String id;
  final String name;
  final String province;
  final String description;
  final PlaceLocation location;
  final List<String> images;
  final String category; // beach, mountain, pagoda, city, waterfall…
  final double rating; // average rating (1–5)
  final int reviewCount;
  final String openHours; // <--- mới thêm
  final List<Comment> comments;

  Place({
    required this.id,
    required this.name,
    required this.province,
    required this.description,
    required this.location,
    required this.images,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.openHours, // <--- mới thêm
    required this.comments,
  });

  factory Place.fromJson(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      name: map['name'],
      province: map['province'],
      description: map['description'],
      
      location: PlaceLocation.fromMap(map['location'] ?? {}),

      images: map['images'] != null 
        ? (map['images'] as List).map((e) => e.toString()).toList() 
        : [],
      category: map['category'],
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'],
      openHours: map['openHours'], // <--- mới thêm
      comments: (map['comments'] as List)
          .map((c) => Comment.fromMap(c))
          .toList(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'province': province,
      'description': description,
      'location': location.toMap(),
      'images': images,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'openHours': openHours, // <--- mới thêm
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }
}


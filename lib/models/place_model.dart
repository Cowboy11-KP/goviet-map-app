import 'package:goviet_map_app/models/location_model.dart';

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
  final String openHours;

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
    required this.openHours,
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
      openHours: map['openHours'], 
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
    };
  }
}


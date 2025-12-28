import 'package:flutter/material.dart';
import 'package:goviet_map_app/models/place_model.dart';

class CityCard extends StatelessWidget {
  final String cityName;
  final List<Place> places; // Danh sách địa điểm thuộc thành phố này
  final VoidCallback onTap;

  const CityCard({
    super.key,
    required this.cityName,
    required this.places,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy ảnh đại diện từ địa điểm đầu tiên của thành phố (hoặc placeholder)
    final String imageUrl = places.isNotEmpty && places.first.images.isNotEmpty
        ? places.first.images.first
        : "https://via.placeholder.com/400x200";

    // final String categories = "Du lịch | Ăn uống | Khám phá"; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white
        ),
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hình ảnh to, bo góc
            AspectRatio(
              aspectRatio: 1.6, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // 2. Tên Thành Phố
            Text(
              cityName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            // 3. Danh mục nhỏ bên dưới
            // Text(
            //   categories,
            //   style: const TextStyle(
            //     fontSize: 14,
            //     color: Colors.grey,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
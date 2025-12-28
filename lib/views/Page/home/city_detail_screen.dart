import 'package:flutter/material.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/viewmodels/map_viewmodel.dart';
import 'package:goviet_map_app/views/components/place_card.dart'; // Tận dụng lại PlaceCard cũ
import 'package:goviet_map_app/views/detail/detail_screen.dart';
import 'package:provider/provider.dart';


class CityDetailScreen extends StatelessWidget {
  final String cityName;
  final List<Place> places;

  const CityDetailScreen({
    super.key,
    required this.cityName,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    final mapVM = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final place = places[index];
          
          // Tính khoảng cách (Logic cũ)
          double? distance;
          if (mapVM.hasPosition) {
            distance = MapViewModel.calculateDistance(
              mapVM.currentPosition!.latitude,
              mapVM.currentPosition!.longitude,
              place.location.latitude,
              place.location.longitude,
            );
          }

          // Tái sử dụng PlaceCard nhưng có thể bọc Container để chỉnh size nếu cần
          return PlaceCard(
            place: place,
            width: double.infinity,
            distance: distance != null
                ? "Cách ${distance.toStringAsFixed(1)} km"
                : "Đang tính...",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    place: place,
                    // Logic dẫn đường (như cũ)
                    onDirectionsPressed: () { /* ... copy logic cũ vào đây hoặc truyền callback ... */ }, 
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
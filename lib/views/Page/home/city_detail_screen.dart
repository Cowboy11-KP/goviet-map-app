import 'package:flutter/material.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/viewmodels/map_viewmodel.dart';
import 'package:goviet_map_app/views/Page/root_screen.dart.dart';
import 'package:goviet_map_app/views/components/place_card.dart';
import 'package:goviet_map_app/views/detail/detail_screen.dart';
import 'package:latlong2/latlong.dart'; // [QUAN TRỌNG] Import LatLng
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
          
          // Tính khoảng cách
          double? distance;
          if (mapVM.hasPosition) {
            distance = MapViewModel.calculateDistance(
              mapVM.currentPosition!.latitude,
              mapVM.currentPosition!.longitude,
              place.location.latitude,
              place.location.longitude,
            );
          }

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
                    // --- LOGIC DẪN ĐƯỜNG ĐÃ SỬA ---
                    onDirectionsPressed: () {
                      // 1. Đóng màn hình Detail
                      Navigator.pop(context);

                      if (mapVM.hasPosition) {
                        // 2. Gọi ViewModel để tìm đường
                        mapVM.fetchRoute(
                          LatLng(mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude),
                          LatLng(place.location.latitude, place.location.longitude)
                        );

                        // 3. Reset Stack về RootScreen và mở Tab Map (index 1)
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const RootScreen(initialIndex: 1)
                          ),
                          (route) => false,
                        );

                        // 4. Thông báo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đang dẫn đường tới ${place.name}"),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          )
                        );
                      } else {
                        mapVM.fetchLocation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng bật định vị"))
                        );
                      }
                    }, 
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
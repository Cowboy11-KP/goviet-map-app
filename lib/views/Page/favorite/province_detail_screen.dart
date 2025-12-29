import 'package:flutter/material.dart';
import 'package:goviet_map_app/models/favorite_model.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/viewmodels/map_viewmodel.dart';
import 'package:goviet_map_app/viewmodels/place_viewmodel.dart';
import 'package:goviet_map_app/views/Page/root_screen.dart.dart';
import 'package:goviet_map_app/views/components/place_card.dart'; 
import 'package:goviet_map_app/views/detail/detail_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ProvinceDetailScreen extends StatelessWidget {
  final String provinceName;
  final List<FavoriteModel> favorites;

  const ProvinceDetailScreen({
    super.key,
    required this.provinceName,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final placeVM = context.read<PlaceViewModel>();
    final mapVM = context.watch<MapViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          provinceName, 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: favorites.isEmpty 
        ? const Center(child: Text("Chưa có địa điểm yêu thích nào."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favItem = favorites[index];

              return FutureBuilder<Place?>(
                future: placeVM.getPlaceById(favItem.placeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 100, margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }

                  final place = snapshot.data!;
                  
                  String distanceText = "";
                  if (mapVM.hasPosition) {
                    double dist = MapViewModel.calculateDistance(
                      mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude,
                      place.location.latitude, place.location.longitude,
                    );
                    distanceText = "Cách ${dist.toStringAsFixed(1)} km";
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: PlaceCard(
                      place: place,
                      distance: distanceText,
                      onTap: () {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              place: place,
                              // --- LOGIC DẪN ĐƯỜNG ĐÃ SỬA ---
                              onDirectionsPressed: () {
                                // 1. Đóng DetailScreen
                                Navigator.pop(context); 

                                if (mapVM.hasPosition) {
                                  // 2. Gọi API tìm đường (Dữ liệu sẽ được lưu trong MapViewModel)
                                  mapVM.fetchRoute(
                                    LatLng(mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude),
                                    LatLng(place.location.latitude, place.location.longitude)
                                  );

                                  // 3. Xóa hết các màn hình cũ và mở lại RootScreen tại Tab Map (index 1)
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const RootScreen(initialIndex: 1)
                                    ),
                                    (route) => false, // Xóa sạch stack
                                  );
                                  
                                  // 4. Thông báo nhẹ
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
                            )
                          )
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
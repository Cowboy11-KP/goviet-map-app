import 'package:flutter/material.dart';
import 'package:goviet_map_app/viewmodels/map_viewmodel.dart';
import 'package:goviet_map_app/viewmodels/place_viewmodel.dart';
import 'package:goviet_map_app/views/Page/home/city_detail_screen.dart';
import 'package:goviet_map_app/views/components/city_card.dart';
import 'package:goviet_map_app/views/components/place_card.dart';
import 'package:goviet_map_app/views/detail/detail_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:goviet_map_app/models/place_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaceViewModel>().loadPlaces();
      if (!context.read<MapViewModel>().hasPosition) {
        context.read<MapViewModel>().fetchLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapVM = context.watch<MapViewModel>();
    final placeVM = context.watch<PlaceViewModel>();

    final placesByProvince = placeVM.placesByProvince;
    final provinceNames = placesByProvince.keys.toList();

    final theme = Theme.of(context);

    if (placeVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final allPlaces = placeVM.masterPlaces;

    // --- 1. LỌC: PHỔ BIẾN (Rating >= 4.5) ---
    final popularPlaces = allPlaces.where((p) => p.rating >= 4.5).toList();

    // --- 2. LỌC: GẦN BẠN (< 20km) ---
    List<Place> nearPlaces = [];
    if (mapVM.hasPosition) {
      nearPlaces = allPlaces.where((place) {
        final distance = MapViewModel.calculateDistance(
          mapVM.currentPosition!.latitude,
          mapVM.currentPosition!.longitude,
          place.location.latitude,
          place.location.longitude,
        );
        return distance < 20.0; // Chỉ lấy dưới 20km
      }).toList();
      
      // (Tùy chọn) Sắp xếp từ gần đến xa
      nearPlaces.sort((a, b) {
        final distA = MapViewModel.calculateDistance(mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude, a.location.latitude, a.location.longitude);
        final distB = MapViewModel.calculateDistance(mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude, b.location.latitude, b.location.longitude);
        return distA.compareTo(distB);
      });
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- UI SECTION 1: GẦN BẠN ---
            _buildSectionHeader(theme, 'Gần bạn (< 20km)', () {}),
            
            // Kiểm tra trạng thái vị trí để hiển thị UI phù hợp
            if (!mapVM.hasPosition)
              _buildEmptyState("Vui lòng bật định vị để xem địa điểm gần bạn", Icons.location_off)
            else if (nearPlaces.isEmpty)
              _buildEmptyState("Không có địa điểm nào trong bán kính 20km", Icons.map)
            else
              _buildPlaceList(nearPlaces, mapVM),

            const SizedBox(height: 24),

            // --- UI SECTION 2: PHỔ BIẾN ---
            _buildSectionHeader(theme, 'Phổ biến', () {}),
            
            if (popularPlaces.isEmpty)
              _buildEmptyState("Chưa có địa điểm nổi bật", Icons.star_border)
            else
              _buildPlaceList(popularPlaces, mapVM),
            
            const SizedBox(height: 24),
            
            Text(
              'Khám phá tất cả',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provinceNames.length,
              itemBuilder: (context, index) {
                final provinceName = provinceNames[index];
                final provincePlaces = placesByProvince[provinceName]!;

                return CityCard(
                  cityName: provinceName,
                  places: provincePlaces,
                  onTap: () {
                    // Chuyển sang màn hình danh sách địa điểm của tỉnh đó
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CityDetailScreen(
                          cityName: provinceName,
                          places: provincePlaces,
                        ),
                      ),
                    );
                  },
                );
              },
            ), 
          ],
        ),
      ),
    );
  }

  // Widget hiển thị khi danh sách rỗng
  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      height: 150,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20)),
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
        )
      ],
    );
  }

  Widget _buildPlaceList(List<Place> places, MapViewModel mapVM) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];

          // Tính toán lại để hiển thị text trên Card
          double? distance;
          if (mapVM.currentPosition != null) {
            distance = MapViewModel.calculateDistance(
              mapVM.currentPosition!.latitude,
              mapVM.currentPosition!.longitude,
              place.location.latitude,
              place.location.longitude,
            );
          }

          return PlaceCard(
            place: place,
            distance: distance != null
                ? "Cách ${distance.toStringAsFixed(1)} km"
                : "Đang tính...",
            
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    place: place,
                    onDirectionsPressed: () {
                      Navigator.pop(context);
                      if (mapVM.hasPosition) {
                        mapVM.fetchRoute(
                          LatLng(mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude),
                          LatLng(place.location.latitude, place.location.longitude)
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đã tìm thấy đường! Chuyển sang tab Khám phá."),
                            backgroundColor: Colors.green,
                          )
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng bật định vị"))
                        );
                        mapVM.fetchLocation();
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
import 'package:flutter/material.dart';
import 'package:goviet_map_app/models/favorite_model.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/models/location_model.dart';
import 'package:goviet_map_app/views/components/place_card.dart'; 
import 'package:goviet_map_app/views/detail/detail_screen.dart';

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final favItem = favorites[index];
          final placeConvert = Place(
            id: favItem.placeId,
            name: favItem.placeName,
            province: favItem.province,
            description: "Đã lưu vào danh sách yêu thích", 
            images: [favItem.placeImage],
            rating: 0.0, // FavoriteModel hiện tại chưa lưu rating, nên để 0
            openHours: "", // Chưa lưu giờ mở cửa
            reviewCount: 0,
            category: "favorite",
            location: PlaceLocation(latitude: 0, longitude: 0, address: ""), // Placeholder
          );
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12), // Tạo khoảng cách giữa các card
            child: PlaceCard(
              place: placeConvert,
              distance: "",
              onTap: () {
                 Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => DetailScreen(place: placeConvert))
                );
              }
            ),
          );
        },
      ),
    );
  }
}
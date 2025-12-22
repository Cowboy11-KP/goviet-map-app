import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goviet_map_app/models/favorite_model.dart';
import 'package:goviet_map_app/viewmodels/favorite_viewmodel.dart';
import 'package:goviet_map_app/views/Home/favorite/province_detail_screen.dart';
class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favViewModel = context.read<FavoriteViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Danh sách yêu thích", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<FavoriteModel>>(
        stream: favViewModel.getMyFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Chưa có địa điểm yêu thích nào"));
          }

          final allFavorites = snapshot.data!;
          
          // --- LOGIC NHÓM THEO TỈNH ---
          Map<String, List<FavoriteModel>> grouped = {};
          
          for (var item in allFavorites) {
            // Xử lý tên tỉnh (trim khoảng trắng)
            String pName = item.province.trim();
            if (pName.isEmpty) pName = "Khác";

            if (!grouped.containsKey(pName)) {
              grouped[pName] = [];
            }
            grouped[pName]!.add(item);
          }
          
          final provinces = grouped.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provinces.length,
            itemBuilder: (context, index) {
              final provinceName = provinces[index];
              final itemsInProvince = grouped[provinceName]!;
              // Lấy ảnh của địa điểm đầu tiên làm ảnh bìa
              final firstImage = itemsInProvince.first.placeImage;
              final count = itemsInProvince.length;

              return GestureDetector(
                onTap: () {
                  // Chuyển sang màn hình chi tiết
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProvinceDetailScreen(
                        provinceName: provinceName,
                        favorites: itemsInProvince,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          firstImage,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => Container(height: 180, color: Colors.grey[300]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provinceName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Đã lưu $count",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                      )
                    ],
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
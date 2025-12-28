import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/viewmodels/favorite_viewmodel.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final String distance;
  final VoidCallback onTap; // Hàm callback khi bấm vào thẻ để chuyển trang
  final double? width;

  const PlaceCard({
    super.key,
    required this.place,
    required this.distance,
    required this.onTap,
    this.width
  });

  @override
  Widget build(BuildContext context) {
    // Lấy ViewModel trực tiếp trong Widget này
    final favViewModel = context.read<FavoriteViewModel>();

    return GestureDetector(
      onTap: onTap, // Gọi hàm chuyển trang khi bấm vào thẻ
      child: Container(
        height: 280,
        width: width ?? 210,
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 4,
              color: Colors.black.withOpacity(0.25),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN ẢNH VÀ ICON TIM ---
            Stack(
              children: [
                // Ảnh nền
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      fit: BoxFit.cover, // Đổi thành cover để ảnh không bị méo
                      image: NetworkImage(place.images.isNotEmpty ? place.images[0] : ''),
                      // Thêm xử lý lỗi nếu ảnh chết
                      onError: (_, __) => const Icon(Icons.broken_image),
                    ),
                  ),
                ),

                // Nút Tim
                Positioned(
                  top: 8,
                  right: 8,
                  child: StreamBuilder<bool>(
                    stream: favViewModel.isFavorite(place.id),
                    builder: (context, snapshot) {
                      final isFav = snapshot.data ?? false;

                      return GestureDetector(
                        onTap: () {
                          // Chỉ xử lý toggle, không ảnh hưởng đến onTap của cả thẻ
                          favViewModel.toggleFavorite(place);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4), // Tăng padding chút cho dễ bấm
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7), // Thêm nền mờ để nổi trên ảnh
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SvgPicture.asset(
                            isFav ? 'assets/icons/heart_bold.svg' : 'assets/icons/heart.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              isFav ? const Color(0xffFF383C) : const Color(0xff4D4D4D),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // --- PHẦN THÔNG TIN ---
            Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      place.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    distance,
                    style: const TextStyle(fontSize: 10, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/clock.svg'),
                          const SizedBox(width: 4),
                          Text(place.openHours, style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                      Row(
                        children: [
                          Text(place.rating.toString(), style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 2),
                          SvgPicture.asset('assets/icons/star.svg'),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset('assets/icons/notebook.svg'),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.description,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 10, height: 1.4),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
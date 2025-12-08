import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:goviet_map_app/viewmodels/location_viewmodel.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // MapController giúp điều khiển bản đồ di chuyển sau khi build xong
  final MapController _mapController = MapController();
  bool _hasMovedToUser = false; 

  final List<Map<String, dynamic>> touristSpots = [
    {
      "name": "Hồ Gươm (Hà Nội)",
      "coords": const LatLng(21.0285, 105.8542),
      "icon": Icons.star,
      "color": Colors.red,
    },
    {
      "name": "Chợ Bến Thành (TP.HCM)",
      "coords": const LatLng(10.7721, 106.6983),
      "icon": Icons.shopping_cart,
      "color": Colors.blue,
    },
    {
      "name": "Phố Cổ Hội An (Quảng Nam)",
      "coords": const LatLng(15.8801, 108.3380),
      "icon": Icons.camera_alt,
      "color": Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().fetchLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final currentPosition = locationProvider.currentPosition;
    // Tạo biến an toàn: Nếu có vị trí thì lấy, nếu không thì null
    LatLng? myLocation;
    if (currentPosition != null) {
      myLocation = LatLng(16.047079, 108.206230);
      // LatLng(currentPosition.latitude, currentPosition.longitude);
      
      // Tự động di chuyển camera đến vị trí người dùng khi mới lấy được tọa độ lần đầu
      if (!_hasMovedToUser) {
        // Cần dùng addPostFrameCallback để tránh lỗi vẽ lại khi đang build
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(myLocation!, 15.0);
        });
        _hasMovedToUser = true; // Đánh dấu đã di chuyển
      }
    }
    
    // Vị trí mặc định (Đà Nẵng)
    final defaultLocation = const LatLng(16.047079, 108.206230);

    return Scaffold(
      body: FlutterMap(
        mapController: _mapController, // Gắn controller vào đây
        options: MapOptions(
          // initialCenter chỉ có tác dụng LẦN ĐẦU TIÊN vẽ bản đồ.
          // Vì lúc đầu myLocation là null nên nó sẽ lấy defaultLocation.
          // Sau khi có vị trí, ta phải dùng mapController để di chuyển (như code ở trên).
          initialCenter: defaultLocation, 
          initialZoom: 6.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.goviet_map_app',
          ),
          
          MarkerLayer(
            markers: [
              // 1. Thêm Marker hiển thị vị trí của TÔI (nếu có)
              if (myLocation != null)
                Marker(
                  point: myLocation,
                  width: 60,
                  height: 60,
                  child: const Icon(Icons.my_location, color: Colors.blueAccent, size: 30),
                ),

              // 2. Các địa điểm du lịch
              ...touristSpots.map((spot) {
                return Marker(
                  point: spot['coords'],
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(20),
                          height: 200,
                          child: Column(
                            children: [
                              Text(
                                spot['name'],
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                  "Thông tin chi tiết..."),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Icon(
                          spot['icon'],
                          color: spot['color'],
                          size: 20,
                        ),
                        Text(
                          spot['name'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            backgroundColor: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: null,
              ),
            ],
          ),
        ],
      ),
      // Nút để quay về vị trí của tôi
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            if (myLocation != null) {
                _mapController.move(myLocation, 15.0);
            } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đang lấy vị trí..."))
                );
                context.read<LocationProvider>().fetchLocation();
            }
        },
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }
}
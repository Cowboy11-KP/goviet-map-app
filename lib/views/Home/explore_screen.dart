  import 'package:flutter/material.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:goviet_map_app/viewmodels/location_viewmodel.dart';
  import 'package:goviet_map_app/viewmodels/place_viewmodel.dart';
  import 'package:goviet_map_app/views/detail/detail_screen.dart';
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

      final placeViewModel = context.watch<PlaceViewModel>();
      final places = placeViewModel.places;

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
                ...places.map((place) {
                  return Marker(
                    point: LatLng(place.location.latitude, place.location.longitude),
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(20),
                            side: BorderSide(width: 1, color: Color(0xffCBCBCB))
                          ),
                          showDragHandle: true,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.5, // Chiều cao ban đầu (90% màn hình)
                            minChildSize: 0.5,
                            maxChildSize: 1.0,
                            expand: false,
                            builder: (_, scrollController) => ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: DetailScreen(place: place, scrollController: scrollController),
                            ),
                          ),
                        );
                      },
                      child: Column(
                      children: [
                        const Icon(
                          Icons.location_on, // Icon chung cho địa điểm
                          color: Colors.red,
                          size: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            place.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
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
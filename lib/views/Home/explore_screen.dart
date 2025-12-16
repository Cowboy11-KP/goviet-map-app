  import 'dart:convert'; // Để decode JSON
  import 'package:http/http.dart' as http; // Để gọi API
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
    
    // Biến lưu danh sách tọa độ đường đi
    List<LatLng> _routePoints = [];
    // --- BIẾN LƯU THÔNG TIN ĐƯỜNG ĐI ---
    double _distanceKm = 0.0;
    double _durationMinutes = 0.0;
    bool _isRouteVisible = false;
  
    // Hàm gọi API lấy đường đi (Sử dụng OSRM miễn phí)
    Future<void> _getRoute(LatLng start, LatLng end) async {
      // API OSRM format: longitude,latitude (Lưu ý thứ tự: Kinh độ trước, Vĩ độ sau)
      final url = Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // 1. Lấy thông tin quãng đường & thời gian
          final routeProps = data['routes'][0];
          final double distMet = (routeProps['distance'] as num).toDouble();
          final double durSec = (routeProps['duration'] as num).toDouble();

          // 2. Lấy tọa độ đường đi
          final List coordinates = routeProps['geometry']['coordinates'];
          
          setState(() {
            // _routePoints = coordinates.map((c) => LatLng(c[1], c[0])).toList(); 
            // c[1] là lat, c[0] là long
            _routePoints = coordinates.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
            _distanceKm = distMet / 1000; // Đổi sang km
            _durationMinutes = durSec / 60; // Đổi sang phút
            _isRouteVisible = true;
          });

          // 3. Zoom bản đồ bao trọn đường đi (Fit Bounds)
          if (_routePoints.isNotEmpty) {
            // Tính toán giới hạn (Bounds) của đường đi
            final bounds = LatLngBounds.fromPoints(_routePoints);
            
            // Di chuyển camera
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50.0), // Chừa lề để không bị sát mép
              ),
            );
          }
        }
      } catch (e) {
        print("Lỗi lấy đường đi: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể tìm thấy đường đi")),
        );
      }
    }

    // Hàm xóa đường đi (Reset)
    void _clearRoute() {
      setState(() {
        _routePoints = [];
        _isRouteVisible = false;
      });
    }

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
        body: Stack(
          children: [
            FlutterMap(
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
                // Lớp vẽ đường đi (PolylineLayer) - Đặt dưới MarkerLayer
                if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue, // Màu của đường đi
                    ),
                  ],
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
                            _clearRoute();
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
                                  child: DetailScreen(
                                    place: place, 
                                    scrollController: scrollController,
                                    onDirectionsPressed: () {
                                    if (myLocation != null) {
                                      // Gọi hàm lấy đường đi
                                      _getRoute(
                                        myLocation, 
                                        LatLng(place.location.latitude, place.location.longitude)
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Đang xác định vị trí của bạn..."))
                                      );
                                    }
                                  },
                                  ),
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

                // 2. BẢNG THÔNG TIN LỘ TRÌNH (Chỉ hiện khi có đường đi)
                if (_isRouteVisible)
                  Positioned(
                    top: 50, // Cách mép trên (tránh tai thỏ)
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                              child: const Icon(Icons.directions_car, color: Colors.blue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Khoảng cách: ${_distanceKm.toStringAsFixed(1)} km",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Thời gian ước tính: ${_formatDuration(_durationMinutes)}",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _clearRoute, 
                              icon: const Icon(Icons.close, color: Colors.grey)
                            )
                          ],
                        ),
                      ),
                    ),
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

  // Hàm format thời gian cho đẹp (vd: 65 phút -> 1 giờ 5 phút)
  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return "${minutes.round()} phút";
    } else {
      int hours = (minutes / 60).floor();
      int mins = (minutes % 60).round();
      return "$hours giờ $mins phút";
    }
  }

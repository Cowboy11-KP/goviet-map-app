import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:goviet_map_app/utils/place_category_helper.dart';
import 'package:goviet_map_app/viewmodels/map_viewmodel.dart';
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
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _hasMovedToUser = false;

  LatLng? _currentDestination;

  // Danh sách bộ lọc
  final List<Map<String, dynamic>> _filters = [
    {"label": "Phổ biến", "icon": Icons.trending_up},
    {"label": "Núi", "icon": Icons.terrain}, 
    {"label": "Chụp hình", "icon": Icons.camera_alt},
    {"label": "Biển", "icon": Icons.beach_access},
    {"label": "Ăn uống", "icon": Icons.restaurant},
  ];

  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapVM = context.read<MapViewModel>();
      mapVM.fetchLocation();
      mapVM.startTrackingLocation();
    });
  }

  // Hàm xử lý khi bấm "Chỉ đường" từ DetailScreen
  void _handleDirectionTap(LatLng destination) {
    //Lưu lại đích đến
    final mapVM = context.read<MapViewModel>();

    _currentDestination = destination;
    
    if (Navigator.canPop(context)) Navigator.pop(context);

    // Reset trạng thái dẫn đường về false khi tìm đường mới
    mapVM.stopNavigation();

    if (mapVM.hasPosition) {
      final myLocation = LatLng(
        mapVM.currentPosition!.latitude, 
        mapVM.currentPosition!.longitude
      );
      
      mapVM.fetchRoute(myLocation, destination).then((_) {
        if (mapVM.routePoints.isNotEmpty) {
           final bounds = LatLngBounds.fromPoints(mapVM.routePoints);
           _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.only(top: 220, bottom: 220, left: 50, right: 50),
              ),
           );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang xác định vị trí...")),
      );
      mapVM.fetchLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapVM = context.watch<MapViewModel>();
    final placeVM = context.watch<PlaceViewModel>();
    
    // Logic di chuyển camera lần đầu
    if (mapVM.hasPosition && !_hasMovedToUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(
          LatLng(mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude), 
          18.0
        );
      });
      _hasMovedToUser = true;
    }

    final defaultLocation = const LatLng(16.047079, 108.206230);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // --------------------------
          // LAYER 1: BẢN ĐỒ
          // --------------------------
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: defaultLocation,
              initialZoom: 6.0,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              onTap: (_, __) => FocusScope.of(context).unfocus(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.goviet_map_app',
              ),
              
              if (mapVM.isRouteVisible && mapVM.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: mapVM.routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blueAccent,
                      borderColor: Colors.blue[900]!,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),

              CurrentLocationLayer(
                // 1. Nếu đang dẫn đường -> Luôn căn giữa. Ngược lại -> Không làm gì.
                alignPositionOnUpdate: mapVM.isNavigating 
                    ? AlignOnUpdate.always 
                    : AlignOnUpdate.never,

                // 2. Nếu đang dẫn đường -> Xoay bản đồ theo hướng đi.
                alignDirectionOnUpdate: mapVM.isNavigating 
                    ? AlignOnUpdate.always 
                    : AlignOnUpdate.never,

                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.navigation, color: Colors.white, size: 20),
                  ),
                  markerSize: Size(40, 40),
                  markerDirection: MarkerDirection.heading, // Mũi tên chỉ theo hướng la bàn
                ),
              ),

              MarkerLayer(
                markers: placeVM.places.map((place) {
                  
                  String categoryName = place.category.toString();

                  return Marker(
                    point: LatLng(place.location.latitude, place.location.longitude),
                    width: 50, 
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        mapVM.clearRoute();
                        _showPlaceDetailSheet(context, place);
                      },
                      child: PlaceCategoryHelper.getIconWidget(categoryName),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // --------------------------
          // LAYER 2: HAI THANH TÌM KIẾM (NHƯ ẢNH GỐC)
          // --------------------------
          _buildDoubleSearchBar(mapVM),

          // --------------------------
          // LAYER 3: CÔNG CỤ BẢN ĐỒ (BÊN PHẢI)
          // --------------------------
          Positioned(
            top: 200, // Đẩy xuống thấp hơn vì có 2 thanh search
            right: 16,
            child: Column(
              children: [
                _buildMapButton(Icons.layers_outlined, () {}),
                const SizedBox(height: 12),
                _buildMapButton(Icons.compass_calibration_outlined, () => _mapController.rotate(0)),
              ],
            ),
          ),

          // --------------------------
          // LAYER 4: THÔNG TIN CHỈ ĐƯỜNG
          // --------------------------
          if (mapVM.isRouteVisible)
            _buildRouteInfoSheet(mapVM),

          // --------------------------
          // LAYER 5: LOADING
          // --------------------------
          if (mapVM.isLoadingRoute)
             const Center(
               child: Card(
                 color: Colors.white,
                 child: Padding(
                   padding: EdgeInsets.all(16.0),
                   child: CircularProgressIndicator(),
                 ),
               ),
             )
        ],
      ),

      // FAB
      floatingActionButton: _buildFab(mapVM),
    );
  }

  // --- CÁC WIDGET CON ĐÃ ĐƯỢC TÁCH ---

  // Widget hiển thị 2 thanh tìm kiếm + bộ lọc
  Widget _buildDoubleSearchBar(MapViewModel mapVM) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Column(
              children: [
                // 1. THANH VỊ TRÍ CỦA BẠN
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.green, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          mapVM.currentAddress ?? "Vị trí của bạn",
                          style: TextStyle(color: Colors.grey[800], fontSize: 14, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (mapVM.isLoadingLocation)
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        const Icon(Icons.search, color: Colors.grey, size: 22),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),

                // 2. THANH TÌM KIẾM ĐỊA ĐIỂM
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Tìm địa điểm, loại hình...",
                          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                          prefixIcon: const Icon(Icons.add_location_alt_outlined, color: Colors.red, size: 22),
                          suffixIcon: mapVM.isSearching
                            ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                            : IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  mapVM.clearSearchResults(); // Xóa kết quả khi bấm X
                                },
                              ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          isDense: true, 
                        ),
                        onSubmitted: (value) {
                          mapVM.searchPlaces(value);
                        },
                      ),

                      // --- DANH SÁCH KẾT QUẢ TÌM KIẾM (HIỆN DƯỚI Ô INPUT) ---
                      if (mapVM.searchResults.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200), // Giới hạn chiều cao
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: mapVM.searchResults.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final result = mapVM.searchResults[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                                title: Text(result['display_name'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis),
                                onTap: () {
                                  // 1. Lấy tọa độ từ kết quả
                                  final lat = double.parse(result['lat']);
                                  final lon = double.parse(result['lon']);
                                  final dest = LatLng(lat, lon);

                                  // 2. Di chuyển map đến đó
                                  _mapController.move(dest, 16.0);
                                  
                                  // 3. Xóa danh sách gợi ý và ẩn bàn phím
                                  mapVM.clearSearchResults();
                                  FocusScope.of(context).unfocus();

                                  // 4. (Tùy chọn) Tự động vẽ đường đến đó nếu đang có vị trí
                                  if (mapVM.hasPosition) {
                                     _handleDirectionTap(dest);
                                  }
                                },
                              );
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 3. DANH SÁCH BỘ LỌC
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilterIndex == index;

                return ActionChip(
                  // Đổi màu nền và màu chữ khi được chọn
                  backgroundColor: isSelected ? Colors.green[100] : Colors.white,
                  avatar: Icon(
                    filter['icon'], 
                    size: 16, 
                    color: isSelected ? Colors.green[800] : Colors.green[700]
                  ),
                  label: Text(
                    filter['label'], 
                    style: TextStyle(
                      fontSize: 13, 
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.green[900] : Colors.black87
                    )
                  ),
                  elevation: isSelected ? 0 : 2,
                  shadowColor: Colors.black26,
                  side: isSelected 
                      ? BorderSide(color: Colors.green.shade300, width: 1) 
                      : BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  
                  // [XỬ LÝ SỰ KIỆN]
                  onPressed: () {
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                    
                    // Gọi ViewModel để lọc data
                    context.read<PlaceViewModel>().filterPlacesByLabel(filter['label']);
                    
                    // Reset kết quả tìm kiếm text (nếu có) để tránh xung đột
                    context.read<MapViewModel>().clearSearchResults();
                    _searchController.clear();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfoSheet(MapViewModel mapVM) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDuration(mapVM.durationMinutes), 
                        style: const TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold)
                      ),
                      Text(
                        "(${mapVM.distanceKm.toStringAsFixed(1)} km)", 
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)
                      ),
                    ],
                  ),
                ),
                // NÚT HỦY
                OutlinedButton(
                  onPressed: () {
                    if (mapVM.isNavigating && _currentDestination != null) {
                      
                      mapVM.stopNavigation(); // Gọi VM để update trạng thái
                      
                      // Logic UI: Zoom out về toàn cảnh
                      _handleDirectionTap(_currentDestination!); 
                      
                    } else {
                      mapVM.clearRoute();
                      _mapController.rotate(0);
                      _currentDestination = null;
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    foregroundColor: Colors.black
                  ),
                  child: Text(mapVM.isNavigating ? "Dừng" : "Hủy"),
                ),
                const SizedBox(width: 10),
                
                // NÚT BẮT ĐẦU
                if (!mapVM.isNavigating)
                  ElevatedButton.icon(
                    onPressed: () {
                      if (mapVM.hasPosition) {
                        mapVM.startNavigation();
                        // 1. Lấy vị trí và hướng (heading)
                        final currentPos = mapVM.currentPosition!;
                        final latLng = LatLng(currentPos.latitude, currentPos.longitude);
                        final heading = currentPos.heading; // Hướng GPS (0-360)

                        // 2. Di chuyển map + Xoay map + Zoom gần (18.0)
                        _mapController.moveAndRotate(latLng, 18.0, heading);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đang lấy vị trí của bạn..."))
                        );
                        mapVM.fetchLocation();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                    ),
                    icon: const Icon(Icons.navigation),
                    label: const Text("Bắt đầu"),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(MapViewModel mapVM) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: mapVM.isRouteVisible ? const Offset(0, -2.5) : Offset.zero,
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          if (mapVM.hasPosition) {
            _mapController.move(
              LatLng(mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude), 
              18.0
            );
          } else {
            mapVM.fetchLocation();
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        shape: BoxShape.circle, 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))]
      ),
      child: IconButton(icon: Icon(icon, color: Colors.black87, size: 24), onPressed: onTap),
    );
  }

  void _showPlaceDetailSheet(BuildContext context, dynamic place) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5, minChildSize: 0.5, maxChildSize: 1.0, expand: false,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: DetailScreen(
            place: place,
            scrollController: scrollController,
            onDirectionsPressed: () => _handleDirectionTap(LatLng(place.location.latitude, place.location.longitude)),
          ),
        ),
      ),
    );
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) return "${minutes.round()} phút";
    int hours = (minutes / 60).floor();
    int mins = (minutes % 60).round();
    return "$hours giờ $mins phút";
  }
}
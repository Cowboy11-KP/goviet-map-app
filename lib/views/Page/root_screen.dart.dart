import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/viewmodels/map_viewmodel.dart';
import 'package:goviet_map_app/views/Page/map/explore_screen.dart';
import 'package:goviet_map_app/views/Page/favorite/favorite_screen.dart';
import 'package:goviet_map_app/views/Page/home/home_screen.dart';
import 'package:goviet_map_app/views/Page/profile/profile_screen.dart';
import 'package:goviet_map_app/views/Page/search/place_search_delegate.dart';
import 'package:goviet_map_app/views/detail/detail_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class RootScreen extends StatefulWidget {
  final int initialIndex;

  const RootScreen({
    super.key, 
    this.initialIndex = 0 // Mặc định là 0 (Trang chủ)
  });

  @override
  State<RootScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<RootScreen> {
  int currentIndex = 0;

  final items = [
    {"icon": "assets/icons/home.svg", "label": "Trang chủ"},
    {"icon": "assets/icons/map.svg", "label": "Khám phá"},
    {"icon": "assets/icons/heart.svg", "label": "Yêu thích"},
    {"icon": "assets/icons/profile.svg", "label": "Hồ sơ"},
  ];

  late List<Widget> _screens;

  @override
  void initState(){
    super.initState();
    currentIndex = widget.initialIndex;
    _screens = [
      HomeScreen(),
      ExploreScreen(),
      FavoriteScreen(),
      ProfileScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().fetchLocation();
    });
  }

  // Hàm xử lý khi chọn kết quả từ Search
  void _handleSearchResult(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          place: place,
          // Callback này sẽ chạy khi người dùng ấn nút "Dẫn đường" trong DetailScreen
          onDirectionsPressed: () {
            Navigator.pop(context);
            setState(() {
              currentIndex = 1;
            });

            // 3. Thực hiện vẽ đường đi
            final mapVM = context.read<MapViewModel>();
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mapVM.hasPosition) {
                mapVM.fetchRoute(
                  LatLng(mapVM.currentPosition!.latitude, mapVM.currentPosition!.longitude),
                  LatLng(place.location.latitude, place.location.longitude)
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Đang tìm đường đến ${place.name}..."), 
                    backgroundColor: Colors.green
                  )
                );
              } else {
                mapVM.fetchLocation();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng bật định vị"))
                );
              }
            });
          },
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final locationProvider = context.watch<MapViewModel>();
    return  Scaffold(
      body: Column(
        children: [
          //header
          if (currentIndex != 1) 
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff80B966),
                    Color(0xff71A759),
                    Color(0xff6CA155),
                    Color(0xff588D40),
                    Color(0xff4D8235),
                  ],
                  stops: [0.0, 0.29, 0.44, 0.75, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16), // Padding cho status bar
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                      ),
                    ),
                    title: Row(
                      children: [
                        Container(
                          height: 24,
                          width: 24,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              context.read<MapViewModel>().fetchLocation();
                            },
                            icon: Icon(
                              Icons.location_on_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Text('Vị trí của bạn là'),
                      ],
                    ),
                    titleTextStyle: theme.textTheme.displaySmall!
                        .copyWith(color: Color(0xffE5E5E5)),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: locationProvider.isLoadingLocation
                          ? SizedBox(
                              width: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            )
                          : locationProvider.hasPosition
                              ? Text(
                                  locationProvider.currentAddress.toString(),
                                )
                              : TextButton(
                                  onPressed: () {
                                    context
                                        .read<MapViewModel>()
                                        .fetchLocation();
                                  },
                                  child:
                                      const Text('Nhấn để lấy vị trí hiện tại'),
                                ),
                    ),
                    subtitleTextStyle: theme.textTheme.displayLarge!
                        .copyWith(color: Colors.white),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/icons/notifi.svg',
                        width: 24,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // 1. Mở màn hình Search
                      final Place? result = await showSearch<Place?>(
                        context: context,
                        delegate: PlaceSearchDelegate(),
                      );

                      // 2. Nếu chọn địa điểm -> Xử lý
                      if (result != null) {
                        _handleSearchResult(result);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xff8B8B8B)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 12),
                          Text(
                            "Tìm kiếm địa điểm...",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          //body
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
          ) 
        ],
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.25),             
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = index == currentIndex;

            return GestureDetector(
              onTap: () {
                setState(() => currentIndex = index);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isSelected
                        ? Color(0xff517C3E)
                        : Colors.transparent,
                      width: 2
                    )
                  )
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      child: SvgPicture.asset(
                        items[index]["icon"]!,
                        color: isSelected
                            ? Color(0xff659B4D)
                            : const Color(0xff6E6E6E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]["label"]!,
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: isSelected
                            ? Color(0xff659B4D)
                            : const Color(0xff6E6E6E),
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
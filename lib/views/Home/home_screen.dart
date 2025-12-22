import 'package:flutter/material.dart';
import 'package:goviet_map_app/viewmodels/location_viewmodel.dart';
import 'package:goviet_map_app/viewmodels/place_viewmodel.dart';
import 'package:goviet_map_app/views/components/place_card.dart';
import 'package:goviet_map_app/views/detail/detail_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final placeViewModel = context.watch<PlaceViewModel>();

    final theme = Theme.of(context);
    
    if (placeViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final places = placeViewModel.places;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  
            children: [
              Text(
                'Gần bạn',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: (){}, 
                icon: Icon(Icons.arrow_forward_ios_rounded)
              )
            ],
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                
                double? distance;
                if (locationProvider.currentPosition != null) {
                  distance = LocationProvider.calculateDistance(
                    locationProvider.currentPosition!.latitude,
                    locationProvider.currentPosition!.longitude,
                    place.location.latitude,
                    place.location.longitude,
                  );
                }
      
                return PlaceCard(
                  place: place,
                  distance: distance != null
                      ? "Cách ${distance.toStringAsFixed(1)} km"
                      : "Không xác định",
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => DetailScreen(place: place))
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  
            children: [
              Text(
                'Phổ biến',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: (){}, 
                icon: Icon(Icons.arrow_forward_ios_rounded)
              )
            ],
          ),
          SizedBox(
            height: 286,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              itemBuilder: (context, index) {
                 final place = places[index];
      
                 double? distance;
                if (locationProvider.currentPosition != null) {
                  distance = LocationProvider.calculateDistance(
                    locationProvider.currentPosition!.latitude,
                    locationProvider.currentPosition!.longitude,
                    place.location.latitude,
                    place.location.longitude,
                  );
                }
                return PlaceCard(
                  place: place,
                  distance: distance != null
                      ? "Cách ${distance.toStringAsFixed(1)} km"
                      : "Không xác định",
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => DetailScreen(place: place))
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Khám phá các địa điểm hấp dẫn   ',
            style: theme.textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/viewmodels/location_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<List<Place>> loadPlaces() async {
    final jsonStr = await rootBundle.loadString('assets/data/sample_place.json');
    final List data = jsonDecode(jsonStr);
    return data.map((e) => Place.fromJson(e)).toList();
  }

  List<Place> places = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPlaces().then((data) {
      setState(() {
        places = data;
        isLoading = false;
      });
    });
  } 

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final theme = Theme.of(context);
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
                    place.latitude,
                    place.longitude,
                  );
                }
      
                return GestureDetector(
                  child: _build(
                    imageUrl: place.image,
                    name: place.name,
                    distance: distance != null
                      ? "Cách ${distance!.toStringAsFixed(1)} km"
                      : "Không xác định",
                    openHours: place.openHours,       
                    rating: place.rating.toString(),
                    description: place.description,
                  )
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
                    place.latitude,
                    place.longitude,
                  );
                }
                return GestureDetector(
                  child: _build(
                    imageUrl: place.image,
                    name: place.name,
                    distance: distance != null
                      ? "Cách ${distance!.toStringAsFixed(1)} km"
                      : "Không xác định", 
                    openHours: place.openHours,     
                    rating: place.rating.toString(),
                    description: place.description,
                  )
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

  Widget _build({required String imageUrl, required String name, required String distance, required String openHours, required String rating, required String description} ) {
    return Container(
      height: 280,
      width: 210,
      padding: const EdgeInsets.all(4),
      margin: EdgeInsets.only(right: 8),
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
          // Image
          Container(
            height: 150,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(imageUrl),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distance,
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/clock.svg'),
                        const SizedBox(width: 4),
                        Text(openHours, style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(rating.toString(), style: const TextStyle(fontSize: 10)),
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
                        description,
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
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goviet_map_app/models/place_model.dart';

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
    
    final theme = Theme.of(context);
    return Column(
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
            itemCount: 1,
            itemBuilder: (context, index) {
              return GestureDetector(
                child: _build(
                  'https://lh3.googleusercontent.com/p/AF1QipMd7iMOFu0NZHQVAL5PmnlxkLiF8CW1nT3oUsnI=w289-h312-n-k-no',
                  'Tiệm Cà Phê Túi Mơ To', 
                  'Cách 2km',
                  '8:00-16:00', 
                  '5.0', 
                  'Bạn có thể đến vào buổi chiều để vừa nhâm nhi ly cà phê vừa ngắm ánh hoàng hôn mờ ảo của Đà Lạt'
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
              return GestureDetector(
                child: _build(
                  place.image,
                  place.name,
                  '${place.province}', // hoặc khoảng cách nếu có geolocator
                  place.openHours,        // nếu JSON có, lấy luôn
                  place.rating.toString(),
                  place.description,
                )
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _build(String imageUrl, String name, String distance, String openHours, String rating, String description ) {
    return Container(
      height: 280,
      width: 210,
      padding: const EdgeInsets.all(4),
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

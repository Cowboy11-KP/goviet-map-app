import 'package:flutter/material.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/viewmodels/place_viewmodel.dart';
import 'package:provider/provider.dart';

class PlaceSearchDelegate extends SearchDelegate<Place?> {
  @override
  String? get searchFieldLabel => 'Tìm địa điểm...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final placeVM = context.read<PlaceViewModel>();
    
    // Gọi hàm search (lọc trên local data nên rất nhanh)
    placeVM.searchPlaces(query); 
    final results = placeVM.places;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off, size: 50, color: Colors.grey),
            Text("Không tìm thấy kết quả", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final place = results[index];
        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.redAccent),
          title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(place.location.address, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            // Khi chọn địa điểm, đóng màn search và trả về Place đã chọn
            close(context, place);
          },
        );
      },
    );
  }
}
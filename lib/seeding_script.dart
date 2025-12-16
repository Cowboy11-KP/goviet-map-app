import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Để dùng debugPrint

// ==========================================
// PHẦN 1: HÀM CHẠY (LOGIC)
// ==========================================

Future<void> runSeeding() async {
  debugPrint("🚀 [SEEDING] Đang khởi động quá trình nạp dữ liệu...");
  
  final FirebaseFirestore db = FirebaseFirestore.instance;
  WriteBatch batch = db.batch(); // Dùng batch để ghi nhanh hơn
  int count = 0;
  int batchCount = 0;

  for (var place in rawData) {
    String placeId = place['id']; // Lấy ID địa điểm (1, 2, 3...)
    List comments = place['comments'] ?? [];

    for (var c in comments) {
      // Tạo ID ngẫu nhiên cho comment trên Firestore
      DocumentReference docRef = db.collection('comments').doc();

      // Map dữ liệu
      batch.set(docRef, {
        'placeId': placeId,             // Link với địa điểm
        'userId': 'seed_bot_${placeId}', // Fake ID user
        'userName': c['user'],          // Tên người comment
        'userAvatarUrl': null,
        'content': c['comment'],        // Nội dung
        'rating': (c['rating'] as num).toDouble(),
        'images': c['images'] ?? [],
        'timestamp': DateTime.parse(c['date']), // Chuyển chuỗi ngày thành DateTime
        'isFakeData': true,             // Đánh dấu để sau này dễ xóa
      });

      count++;
      batchCount++;

      // Firestore giới hạn 500 lệnh/batch -> Reset nếu đầy
      if (batchCount >= 400) {
        await batch.commit();
        batch = db.batch(); // Tạo batch mới
        batchCount = 0;
        debugPrint("... Đã ghi $count dòng ...");
      }
    }
  }

  // Commit nốt số lẻ còn lại
  if (batchCount > 0) {
    await batch.commit();
  }

  debugPrint("✅ [SEEDING HOÀN TẤT] Tổng cộng đã đẩy $count comments lên Firestore!");
}

// ==========================================
// PHẦN 2: DỮ LIỆU (DATA)
// ==========================================

final List<Map<String, dynamic>> rawData = [
  {
    "id": "1",
    "name": "Hồ Gươm",
    "province": "Hà Nội",
    "description": "Hồ Gươm là một trong những điểm đến nổi tiếng nhất tại Hà Nội, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 21.0288313,
      "longitude": 105.8525357,
      "address": "Hồ Hoàn Kiếm, Phường Hoàn Kiếm, Thành phố Hà Nội, 11024, Việt Nam"
    },
    "images": [
      "https://ik.imagekit.io/tvlk/blog/2022/08/ho-guom-16-1024x683.jpg?tr=dpr-2,w-675"
    ],
    "category": "travel",
    "rating": 4.2,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:08.960907",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:08.960916",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:08.960919",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:08.960921",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:08.960923",
        "images": []
      }
    ]
  },
  {
    "id": "2",
    "name": "Lăng Chủ tịch Hồ Chí Minh",
    "province": "Hà Nội",
    "description": "Lăng Chủ tịch Hồ Chí Minh là một trong những điểm đến nổi tiếng nhất tại Hà Nội, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 21.0367831,
      "longitude": 105.8346888,
      "address": "Lăng Chủ tịch Hồ Chí Minh, 1, Đường Hùng Vương, Phường Ba Đình, Thành phố Hà Nội, 11120, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:11.890511",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:46:11.890556",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:11.890571",
        "images": []
      }
    ]
  },
  {
    "id": "3",
    "name": "Văn Miếu Quốc Tử Giám",
    "province": "Hà Nội",
    "description": "Văn Miếu Quốc Tử Giám là một trong những điểm đến nổi tiếng nhất tại Hà Nội, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 21.0287903,
      "longitude": 105.8359533,
      "address": "Văn Miếu - Quốc Tử Giám, Phường Văn Miếu - Quốc Tử Giám, Thành phố Hà Nội, 11508, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.2,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:15.488600",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:46:15.488625",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:46:15.488633",
        "images": []
      }
    ]
  },
  {
    "id": "4",
    "name": "Vịnh Hạ Long",
    "province": "Quảng Ninh",
    "description": "Vịnh Hạ Long là một trong những điểm đến nổi tiếng nhất tại Quảng Ninh, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 20.9084384,
      "longitude": 107.0682782,
      "address": "Vịnh Hạ Long, Hồng Gai, Tỉnh Quảng Ninh, 01000, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:18.504404",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:18.504428",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:18.504430",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:18.504432",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:46:18.504434",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:18.504436",
        "images": []
      }
    ]
  },
  {
    "id": "5",
    "name": "Yên Tử",
    "province": "Quảng Ninh",
    "description": "Yên Tử là một trong những điểm đến nổi tiếng nhất tại Quảng Ninh, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 21.0442964,
      "longitude": 106.7111181,
      "address": "Phường Yên Tử, Tỉnh Quảng Ninh, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.2,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:22.148751",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:22.148778",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:22.148788",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:22.148797",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:22.148805",
        "images": []
      }
    ]
  },
  {
    "id": "6",
    "name": "Đảo Tuần Châu",
    "province": "Quảng Ninh",
    "description": "Đảo Tuần Châu là một trong những điểm đến nổi tiếng nhất tại Quảng Ninh, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 20.9284916,
      "longitude": 106.9701928,
      "address": "Đảo Tuần Châu, Bãi Cháy, Tỉnh Quảng Ninh, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.4,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:25.356433",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:25.356449",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:25.356454",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:25.356459",
        "images": []
      }
    ]
  },
  {
    "id": "7",
    "name": "Fansipan",
    "province": "Lào Cai",
    "description": "Fansipan là một trong những điểm đến nổi tiếng nhất tại Lào Cai, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 22.3066106,
      "longitude": 103.7747781,
      "address": "Fansipan, Đường mòn Trạm Tôn, Xã Tả Van, Tỉnh Lào Cai, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.6,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:28.919605",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:46:28.919638",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:28.919650",
        "images": []
      }
    ]
  },
  {
    "id": "8",
    "name": "Bản Cát Cát",
    "province": "Lào Cai",
    "description": "Bản Cát Cát là một trong những điểm đến nổi tiếng nhất tại Lào Cai, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Lào Cai, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:33.719734",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:33.719753",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:33.719758",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:33.719763",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:33.719769",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:46:33.719775",
        "images": []
      }
    ]
  },
  {
    "id": "9",
    "name": "Nhà thờ đá Sapa",
    "province": "Lào Cai",
    "description": "Nhà thờ đá Sapa là một trong những điểm đến nổi tiếng nhất tại Lào Cai, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Lào Cai, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:37.785172",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:46:37.785199",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:37.785209",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:46:37.785217",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:37.785224",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:37.785232",
        "images": []
      }
    ]
  },
  {
    "id": "10",
    "name": "Cột cờ Lũng Cú",
    "province": "Hà Giang",
    "description": "Cột cờ Lũng Cú là một trong những điểm đến nổi tiếng nhất tại Hà Giang, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Hà Giang, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:40.895592",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:40.895623",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:40.895634",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:40.895645",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:40.895656",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:40.895667",
        "images": []
      }
    ]
  },
  {
    "id": "11",
    "name": "Đèo Mã Pí Lèng",
    "province": "Hà Giang",
    "description": "Đèo Mã Pí Lèng là một trong những điểm đến nổi tiếng nhất tại Hà Giang, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Hà Giang, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.8,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:45.153090",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:45.153099",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:45.153102",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:45.153104",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:46:45.153106",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:45.153108",
        "images": []
      }
    ]
  },
  {
    "id": "12",
    "name": "Sông Nho Quế",
    "province": "Hà Giang",
    "description": "Sông Nho Quế là một trong những điểm đến nổi tiếng nhất tại Hà Giang, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Hà Giang, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.7,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:48.893597",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:46:48.893623",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:46:48.893632",
        "images": []
      }
    ]
  },
  {
    "id": "13",
    "name": "Khu du lịch Tràng An",
    "province": "Ninh Bình",
    "description": "Khu du lịch Tràng An là một trong những điểm đến nổi tiếng nhất tại Ninh Bình, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Ninh Bình, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 5.0,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:46:53.397552",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:46:53.397561",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:53.397563",
        "images": []
      }
    ]
  },
  {
    "id": "14",
    "name": "Chùa Bái Đính",
    "province": "Ninh Bình",
    "description": "Chùa Bái Đính là một trong những điểm đến nổi tiếng nhất tại Ninh Bình, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 20.2728394,
      "longitude": 105.8640252,
      "address": "Chùa Bái Đính, Quốc lộ 38B, Phường Tây Hoa Lư, Tỉnh Ninh Bình, 40000, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.7,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:56.789197",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:56.789228",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:46:56.789239",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:56.789249",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:46:56.789258",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:46:56.789267",
        "images": []
      }
    ]
  },
  {
    "id": "15",
    "name": "Hang Múa",
    "province": "Ninh Bình",
    "description": "Hang Múa là một trong những điểm đến nổi tiếng nhất tại Ninh Bình, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 20.2295474,
      "longitude": 105.9342536,
      "address": "Hang Múa;Lying Dragon Top, Lotus lake boardwalk, Phường Hoa Lư, Tỉnh Ninh Bình, 08213, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.8,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:00.584160",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:47:00.584192",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:00.584204",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:00.584215",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:47:00.584227",
        "images": []
      }
    ]
  },
  {
    "id": "16",
    "name": "Thác Bản Giốc",
    "province": "Cao Bằng",
    "description": "Thác Bản Giốc là một trong những điểm đến nổi tiếng nhất tại Cao Bằng, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 22.8539003,
      "longitude": 106.7232867,
      "address": "Thác Bản Giốc, Xã Đàm Thủy, Tỉnh Cao Bằng, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.4,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:03.995531",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:03.995541",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:03.995543",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:03.995545",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:47:03.995547",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:47:03.995549",
        "images": []
      }
    ]
  },
  {
    "id": "17",
    "name": "Hang Pác Bó",
    "province": "Cao Bằng",
    "description": "Hang Pác Bó là một trong những điểm đến nổi tiếng nhất tại Cao Bằng, thuộc vùng Miền Bắc. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 22.6699603,
      "longitude": 106.2619945,
      "address": "Cửa hàng xe điện Tuấn Thủy, 196, Đường Pác Bó, Tổ dân phố 20, Phường Nùng Trí Cao, Tỉnh Cao Bằng, 21110, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:11.642158",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:11.642168",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:11.642170",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:11.642171",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:11.642174",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:47:11.642176",
        "images": []
      }
    ]
  },
  {
    "id": "18",
    "name": "Bà Nà Hills",
    "province": "Đà Nẵng",
    "description": "Bà Nà Hills là một trong những điểm đến nổi tiếng nhất tại Đà Nẵng, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 16.0593284,
      "longitude": 108.2060139,
      "address": "Bus 03 to Ba Na Hills, Đường Nguyễn Tri Phương, Chính Gián, Phường Thanh Khê, Thành phố Đà Nẵng, 50207, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.2,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:47:15.611328",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:15.611336",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:15.611338",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:15.611340",
        "images": []
      }
    ]
  },
  {
    "id": "19",
    "name": "Cầu Rồng",
    "province": "Đà Nẵng",
    "description": "Cầu Rồng là một trong những điểm đến nổi tiếng nhất tại Đà Nẵng, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 16.0611682,
      "longitude": 108.2278968,
      "address": "Cầu Rồng, Phường An Hải, Thành phố Đà Nẵng, 02363, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.7,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:19.612260",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:19.612269",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:19.612271",
        "images": []
      }
    ]
  },
  {
    "id": "20",
    "name": "Ngũ Hành Sơn",
    "province": "Đà Nẵng",
    "description": "Ngũ Hành Sơn là một trong những điểm đến nổi tiếng nhất tại Đà Nẵng, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 16.00402,
      "longitude": 108.2627745,
      "address": "Ngũ Hành Sơn, Đường Sư Vạn Hạnh, Phường Ngũ Hành Sơn, Thành phố Đà Nẵng, 50507, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.7,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:22.792020",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:22.792029",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:22.792031",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:22.792033",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:22.792035",
        "images": []
      }
    ]
  },
  {
    "id": "21",
    "name": "Phố cổ Hội An",
    "province": "Quảng Nam",
    "description": "Phố cổ Hội An là một trong những điểm đến nổi tiếng nhất tại Quảng Nam, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 15.8799726,
      "longitude": 108.3260302,
      "address": "Quán Phở Tiến, 133, Trần Hưng Đạo, Phố cổ Hội An, Cẩm Phô, Phường Hội An, Thành phố Đà Nẵng, 64000, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.5,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:26.178207",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:26.178216",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:47:26.178218",
        "images": []
      }
    ]
  },
  {
    "id": "22",
    "name": "Thánh địa Mỹ Sơn",
    "province": "Quảng Nam",
    "description": "Thánh địa Mỹ Sơn là một trong những điểm đến nổi tiếng nhất tại Quảng Nam, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Quảng Nam, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:30.789979",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:30.790011",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:30.790023",
        "images": []
      }
    ]
  },
  {
    "id": "23",
    "name": "Cù Lao Chàm",
    "province": "Quảng Nam",
    "description": "Cù Lao Chàm là một trong những điểm đến nổi tiếng nhất tại Quảng Nam, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Quảng Nam, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.8,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:34.672332",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:34.672343",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:34.672346",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:34.672348",
        "images": []
      }
    ]
  },
  {
    "id": "24",
    "name": "Đại Nội Huế",
    "province": "Thừa Thiên Huế",
    "description": "Đại Nội Huế là một trong những điểm đến nổi tiếng nhất tại Thừa Thiên Huế, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 16.4689726,
      "longitude": 107.5781266,
      "address": "Hoàng Thành Huế, Sân Đại Triều Nghi, Đông Ba, Phường Phú Xuân, Thành phố Huế, 54000, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:37.831856",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:37.831865",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:37.831867",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:47:37.831869",
        "images": []
      }
    ]
  },
  {
    "id": "25",
    "name": "Chùa Thiên Mụ",
    "province": "Thừa Thiên Huế",
    "description": "Chùa Thiên Mụ là một trong những điểm đến nổi tiếng nhất tại Thừa Thiên Huế, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 16.4537195,
      "longitude": 107.5445808,
      "address": "Chùa Thiên Mụ, Đường Văn Thánh, Phường Kim Long, Thành phố Huế, 54000, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.5,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Đức Thắng",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:41.869616",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:41.869624",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:47:41.869626",
        "images": []
      }
    ]
  },
  {
    "id": "26",
    "name": "Lăng Khải Định",
    "province": "Thừa Thiên Huế",
    "description": "Lăng Khải Định là một trong những điểm đến nổi tiếng nhất tại Thừa Thiên Huế, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 16.3990174,
      "longitude": 107.5903393,
      "address": "Lăng Khải Định, Đường Đại Nam, Thủy Bằng, Thủy Xuân, Phường Thủy Xuân, Thành phố Huế, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 5.0,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:44.976598",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:44.976620",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:44.976628",
        "images": []
      }
    ]
  },
  {
    "id": "27",
    "name": "VinWonders Nha Trang",
    "province": "Khánh Hòa",
    "description": "VinWonders Nha Trang là một trong những điểm đến nổi tiếng nhất tại Khánh Hòa, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Khánh Hòa, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.6,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:48.453750",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:48.453779",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:48.453788",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:48.453796",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:48.453805",
        "images": []
      }
    ]
  },
  {
    "id": "28",
    "name": "Đảo Hòn Mun",
    "province": "Khánh Hòa",
    "description": "Đảo Hòn Mun là một trong những điểm đến nổi tiếng nhất tại Khánh Hòa, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 12.1666859,
      "longitude": 109.3049424,
      "address": "Hòn Mun, Phường Nam Nha Trang, Tỉnh Khánh Hòa, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:51.630962",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:51.630990",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:47:51.630999",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:51.631006",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:51.631013",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:51.631021",
        "images": []
      }
    ]
  },
  {
    "id": "29",
    "name": "Tháp Bà Ponagar",
    "province": "Khánh Hòa",
    "description": "Tháp Bà Ponagar là một trong những điểm đến nổi tiếng nhất tại Khánh Hòa, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Khánh Hòa, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.2,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:55.294215",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:47:55.294227",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:47:55.294230",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:47:55.294234",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:47:55.294237",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:55.294240",
        "images": []
      }
    ]
  },
  {
    "id": "30",
    "name": "Động Phong Nha",
    "province": "Quảng Bình",
    "description": "Động Phong Nha là một trong những điểm đến nổi tiếng nhất tại Quảng Bình, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Quảng Bình, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:47:58.577296",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:58.577328",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:47:58.577339",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:47:58.577349",
        "images": []
      }
    ]
  },
  {
    "id": "31",
    "name": "Hang Sơn Đoòng",
    "province": "Quảng Bình",
    "description": "Hang Sơn Đoòng là một trong những điểm đến nổi tiếng nhất tại Quảng Bình, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Quảng Bình, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Đức Thắng",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:02.182109",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:02.182140",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:02.182150",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:02.182159",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:02.182168",
        "images": []
      }
    ]
  },
  {
    "id": "32",
    "name": "Đồi Cát Bay Mũi Né",
    "province": "Bình Thuận",
    "description": "Đồi Cát Bay Mũi Né là một trong những điểm đến nổi tiếng nhất tại Bình Thuận, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 10.948883,
      "longitude": 108.2978477,
      "address": "Đồi Cát Bay, Xuân Thủy, Phường Mũi Né, Tỉnh Lâm Đồng, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.6,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:48:05.274395",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:05.274406",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:05.274409",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:05.274412",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:05.274415",
        "images": []
      }
    ]
  },
  {
    "id": "33",
    "name": "Đảo Phú Quý",
    "province": "Bình Thuận",
    "description": "Đảo Phú Quý là một trong những điểm đến nổi tiếng nhất tại Bình Thuận, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Bình Thuận, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.2,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:10.676371",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:10.676385",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:10.676388",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:10.676392",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:10.676395",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:48:10.676399",
        "images": []
      }
    ]
  },
  {
    "id": "34",
    "name": "Gành Đá Đĩa",
    "province": "Phú Yên",
    "description": "Gành Đá Đĩa là một trong những điểm đến nổi tiếng nhất tại Phú Yên, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Phú Yên, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:13.823526",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:13.823534",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:13.823536",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:13.823538",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:13.823540",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:13.823543",
        "images": []
      }
    ]
  },
  {
    "id": "35",
    "name": "Bãi Xép",
    "province": "Phú Yên",
    "description": "Bãi Xép là một trong những điểm đến nổi tiếng nhất tại Phú Yên, thuộc vùng Miền Trung. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Phú Yên, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:17.459950",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:17.459959",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:17.459961",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:48:17.459963",
        "images": []
      }
    ]
  },
  {
    "id": "36",
    "name": "Hồ Xuân Hương Đà Lạt",
    "province": "Lâm Đồng",
    "description": "Hồ Xuân Hương Đà Lạt là một trong những điểm đến nổi tiếng nhất tại Lâm Đồng, thuộc vùng Tây Nguyên. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 11.9450803,
      "longitude": 108.4487222,
      "address": "Hồ Xuân Hương, Đà Lạt, Phường Xuân Hương - Đà Lạt, Tỉnh Lâm Đồng, 66100, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.2,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:20.732410",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:20.732424",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:20.732429",
        "images": []
      }
    ]
  },
  {
    "id": "37",
    "name": "Thung lũng Tình Yêu",
    "province": "Lâm Đồng",
    "description": "Thung lũng Tình Yêu là một trong những điểm đến nổi tiếng nhất tại Lâm Đồng, thuộc vùng Tây Nguyên. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 11.9781853,
      "longitude": 108.4499229,
      "address": "Thung Lũng Tình Yêu, Mai Anh Đào, Phường Lâm Viên - Đà Lạt, Tỉnh Lâm Đồng, 66100, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.4,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:24.183722",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:24.183734",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:24.183737",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:24.183741",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:48:24.183744",
        "images": []
      }
    ]
  },
  {
    "id": "38",
    "name": "Langbiang",
    "province": "Lâm Đồng",
    "description": "Langbiang là một trong những điểm đến nổi tiếng nhất tại Lâm Đồng, thuộc vùng Tây Nguyên. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 12.0472573,
      "longitude": 108.4405826,
      "address": "Núi Lang Biang, Phường Lang Biang - Đà Lạt, Tỉnh Lâm Đồng, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:27.021304",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:27.021313",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:27.021315",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:48:27.021317",
        "images": []
      }
    ]
  },
  {
    "id": "39",
    "name": "Bảo tàng Thế giới Cà phê",
    "province": "Đắk Lắk",
    "description": "Bảo tàng Thế giới Cà phê là một trong những điểm đến nổi tiếng nhất tại Đắk Lắk, thuộc vùng Tây Nguyên. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 12.6907074,
      "longitude": 108.0448679,
      "address": "Bảo tàng Thế giới Cà phê, Lý Thường Kiệt, Tổ dân phố 12, Buôn Ma Thuột, Phường Buôn Ma Thuột, Tỉnh Đắk Lắk, 63119, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.8,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:30.667519",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:30.667534",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:30.667538",
        "images": []
      }
    ]
  },
  {
    "id": "40",
    "name": "Buôn Đôn",
    "province": "Đắk Lắk",
    "description": "Buôn Đôn là một trong những điểm đến nổi tiếng nhất tại Đắk Lắk, thuộc vùng Tây Nguyên. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 12.878569,
      "longitude": 107.7120405,
      "address": "Huyện Buôn Đôn, Tỉnh Đắk Lắk, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:33.654684",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:33.654703",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:48:33.654709",
        "images": []
      }
    ]
  },
  {
    "id": "41",
    "name": "Biển Hồ Pleiku",
    "province": "Gia Lai",
    "description": "Biển Hồ Pleiku là một trong những điểm đến nổi tiếng nhất tại Gia Lai, thuộc vùng Tây Nguyên. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 14.0468591,
      "longitude": 107.9960066,
      "address": "Biển Hồ Pleiku, Đường dẫn Biển Hồ Pleiku, Xã Biển Hồ, Tỉnh Gia Lai, 60000, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.7,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:37.076731",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:48:37.076740",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:37.076742",
        "images": []
      }
    ]
  },
  {
    "id": "42",
    "name": "Chợ Bến Thành",
    "province": "TP.HCM",
    "description": "Chợ Bến Thành là một trong những điểm đến nổi tiếng nhất tại TP.HCM, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 10.7725301,
      "longitude": 106.6980365,
      "address": "Chợ Bến Thành, Công trường Quách Thị Trang, Khu phố 6, Phường Bến Thành, Thủ Đức, Thành phố Hồ Chí Minh, 71009, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:40.328707",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:40.328726",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:40.328732",
        "images": []
      }
    ]
  },
  {
    "id": "43",
    "name": "Dinh Độc Lập",
    "province": "TP.HCM",
    "description": "Dinh Độc Lập là một trong những điểm đến nổi tiếng nhất tại TP.HCM, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 10.7770348,
      "longitude": 106.695488,
      "address": "Dinh Độc Lập, 135, Nam Kỳ Khởi Nghĩa, Khu phố 7, Phường Bến Thành, Thủ Đức, Thành phố Hồ Chí Minh, 71009, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:48:43.972278",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:43.972292",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:43.972296",
        "images": []
      }
    ]
  },
  {
    "id": "44",
    "name": "Phố đi bộ Nguyễn Huệ",
    "province": "TP.HCM",
    "description": "Phố đi bộ Nguyễn Huệ là một trong những điểm đến nổi tiếng nhất tại TP.HCM, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 10.7737196,
      "longitude": 106.7040457,
      "address": "Phố đi bộ Nguyễn Huệ, Khu phố 8, Phường Sài Gòn, Thủ Đức, Thành phố Hồ Chí Minh, 71006, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:46.956024",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:46.956038",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:46.956042",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:46.956046",
        "images": []
      }
    ]
  },
  {
    "id": "45",
    "name": "VinWonders Phú Quốc",
    "province": "Kiên Giang",
    "description": "VinWonders Phú Quốc là một trong những điểm đến nổi tiếng nhất tại Kiên Giang, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Kiên Giang, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.5,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:50.678240",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:50.678259",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:50.678265",
        "images": []
      }
    ]
  },
  {
    "id": "46",
    "name": "Bãi Sao Phú Quốc",
    "province": "Kiên Giang",
    "description": "Bãi Sao Phú Quốc là một trong những điểm đến nổi tiếng nhất tại Kiên Giang, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Kiên Giang, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.6,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:48:53.655383",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:53.655392",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:48:53.655395",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:53.655397",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:48:53.655399",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:53.655402",
        "images": []
      }
    ]
  },
  {
    "id": "47",
    "name": "Tượng Chúa Kitô Vua",
    "province": "Bà Rịa - Vũng Tàu",
    "description": "Tượng Chúa Kitô Vua là một trong những điểm đến nổi tiếng nhất tại Bà Rịa - Vũng Tàu, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 0.0,
      "longitude": 0.0,
      "address": "Bà Rịa - Vũng Tàu, Việt Nam (Đang cập nhật)"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.7,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:56.489209",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:48:56.489218",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:48:56.489220",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:48:56.489222",
        "images": []
      }
    ]
  },
  {
    "id": "48",
    "name": "Côn Đảo",
    "province": "Bà Rịa - Vũng Tàu",
    "description": "Côn Đảo là một trong những điểm đến nổi tiếng nhất tại Bà Rịa - Vũng Tàu, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 8.6778963,
      "longitude": 106.6011901,
      "address": "Con Dao Resort, 8, Nguyễn Đức Thuận, Khu 5, Côn Sơn, Đặc khu Côn Đảo, Thành phố Hồ Chí Minh, 790000, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.5,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 5.0,
        "date": "2025-12-12T17:48:59.688613",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:59.688623",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:48:59.688626",
        "images": []
      }
    ]
  },
  {
    "id": "49",
    "name": "Chợ nổi Cái Răng",
    "province": "Cần Thơ",
    "description": "Chợ nổi Cái Răng là một trong những điểm đến nổi tiếng nhất tại Cần Thơ, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 10.0023957,
      "longitude": 105.7443925,
      "address": "Chợ nổi Cái Răng, Nguyễn Trãi, Phường Cái Răng, Thành phố Cần Thơ, 94000, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 5.0,
    "reviewCount": 3,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:49:03.412024",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:49:03.412038",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 5.0,
        "date": "2025-12-12T17:49:03.412042",
        "images": []
      }
    ]
  },
  {
    "id": "50",
    "name": "Bến Ninh Kiều",
    "province": "Cần Thơ",
    "description": "Bến Ninh Kiều là một trong những điểm đến nổi tiếng nhất tại Cần Thơ, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 10.0315282,
      "longitude": 105.7875681,
      "address": "Khu ăn uống chợ đêm bến Ninh Kiều, Phan Chu Trinh, Phường Ninh Kiều, Thành phố Cần Thơ, 94111, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.9,
    "reviewCount": 6,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:49:06.861601",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:49:06.861621",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:49:06.861627",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:49:06.861633",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 5.0,
        "date": "2025-12-12T17:49:06.861639",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:49:06.861644",
        "images": []
      }
    ]
  },
  {
    "id": "51",
    "name": "Núi Bà Đen",
    "province": "Tây Ninh",
    "description": "Núi Bà Đen là một trong những điểm đến nổi tiếng nhất tại Tây Ninh, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 11.3823834,
      "longitude": 106.170221,
      "address": "Núi Bà Đen, Phường Bình Minh, Tỉnh Tây Ninh, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.8,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thảo Ly",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:49:10.383434",
        "images": []
      },
      {
        "user": "Minh Anh",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.5,
        "date": "2025-12-12T17:49:10.383449",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:49:10.383453",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:49:10.383457",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.0,
        "date": "2025-12-12T17:49:10.383461",
        "images": []
      }
    ]
  },
  {
    "id": "52",
    "name": "Tòa Thánh Tây Ninh",
    "province": "Tây Ninh",
    "description": "Tòa Thánh Tây Ninh là một trong những điểm đến nổi tiếng nhất tại Tây Ninh, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 11.3106962,
      "longitude": 106.0295137,
      "address": "Tòa án Nhân dân huyện Châu Thành, Đường tỉnh 781, Xã Châu Thành, Tỉnh Tây Ninh, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Hoàng Nam",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:49:14.550990",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:49:14.551010",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.5,
        "date": "2025-12-12T17:49:14.551017",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 4.5,
        "date": "2025-12-12T17:49:14.551023",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.5,
        "date": "2025-12-12T17:49:14.551028",
        "images": []
      }
    ]
  },
  {
    "id": "53",
    "name": "Rừng tràm Trà Sư",
    "province": "An Giang",
    "description": "Rừng tràm Trà Sư là một trong những điểm đến nổi tiếng nhất tại An Giang, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 10.5859015,
      "longitude": 105.058267,
      "address": "Rừng tràm Trà Sư, Xã An Cư, Tỉnh An Giang, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.6,
    "reviewCount": 4,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 4.0,
        "date": "2025-12-12T17:49:17.999786",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
        "rating": 5.0,
        "date": "2025-12-12T17:49:17.999804",
        "images": []
      },
      {
        "user": "Hoàng Nam",
        "comment": "Không khí trong lành, đồ ăn ngon.",
        "rating": 4.0,
        "date": "2025-12-12T17:49:17.999810",
        "images": []
      },
      {
        "user": "Thảo Ly",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:49:17.999815",
        "images": []
      }
    ]
  },
  {
    "id": "54",
    "name": "Miếu Bà Chúa Xứ",
    "province": "An Giang",
    "description": "Miếu Bà Chúa Xứ là một trong những điểm đến nổi tiếng nhất tại An Giang, thuộc vùng Miền Nam. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo.",
    "location": {
      "latitude": 10.6821665,
      "longitude": 105.0800863,
      "address": "Miếu Bà Chúa Xứ, Phường Vĩnh Tế, Tỉnh An Giang, Việt Nam"
    },
    "images": [
      "https://via.placeholder.com/600x400?text=No+Image"
    ],
    "category": "travel",
    "rating": 4.3,
    "reviewCount": 5,
    "openHours": "07:00 - 22:00",
    "comments": [
      {
        "user": "Thu Hà",
        "comment": "Dịch vụ tốt, giá cả hợp lý.",
        "rating": 5.0,
        "date": "2025-12-12T17:49:20.939483",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:49:20.939497",
        "images": []
      },
      {
        "user": "Đức Thắng",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.0,
        "date": "2025-12-12T17:49:20.939501",
        "images": []
      },
      {
        "user": "Thu Hà",
        "comment": "Hơi đông vào cuối tuần nhưng vẫn rất vui.",
        "rating": 4.5,
        "date": "2025-12-12T17:49:20.939504",
        "images": []
      },
      {
        "user": "Quốc Bảo",
        "comment": "Trải nghiệm đáng nhớ cùng gia đình.",
        "rating": 4.0,
        "date": "2025-12-12T17:49:20.939508",
        "images": []
      }
    ]
  }
];
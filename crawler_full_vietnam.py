import json
import random
import time
from datetime import datetime
from geopy.geocoders import Nominatim
from duckduckgo_search import DDGS

# --- CẤU HÌNH DỮ LIỆU ĐẦU VÀO ---
# Danh sách địa điểm nổi tiếng phân theo Vùng -> Tỉnh -> Địa điểm
VIETNAM_TOURIST_SPOTS = {
    "Miền Bắc": {
        "Hà Nội": ["Hồ Gươm", "Lăng Chủ tịch Hồ Chí Minh", "Văn Miếu Quốc Tử Giám"],
        "Quảng Ninh": ["Vịnh Hạ Long", "Yên Tử", "Đảo Tuần Châu"],
        "Lào Cai": ["Fansipan", "Bản Cát Cát", "Nhà thờ đá Sapa"],
        "Hà Giang": ["Cột cờ Lũng Cú", "Đèo Mã Pí Lèng", "Sông Nho Quế"],
        "Ninh Bình": ["Khu du lịch Tràng An", "Chùa Bái Đính", "Hang Múa"],
        "Cao Bằng": ["Thác Bản Giốc", "Hang Pác Bó"]
    },
    "Miền Trung": {
        "Đà Nẵng": ["Bà Nà Hills", "Cầu Rồng", "Ngũ Hành Sơn"],
        "Quảng Nam": ["Phố cổ Hội An", "Thánh địa Mỹ Sơn", "Cù Lao Chàm"],
        "Thừa Thiên Huế": ["Đại Nội Huế", "Chùa Thiên Mụ", "Lăng Khải Định"],
        "Khánh Hòa": ["VinWonders Nha Trang", "Đảo Hòn Mun", "Tháp Bà Ponagar"],
        "Quảng Bình": ["Động Phong Nha", "Hang Sơn Đoòng"],
        "Bình Thuận": ["Đồi Cát Bay Mũi Né", "Đảo Phú Quý"],
        "Phú Yên": ["Gành Đá Đĩa", "Bãi Xép"]
    },
    "Tây Nguyên": {
        "Lâm Đồng": ["Hồ Xuân Hương Đà Lạt", "Thung lũng Tình Yêu", "Langbiang"],
        "Đắk Lắk": ["Bảo tàng Thế giới Cà phê", "Buôn Đôn"],
        "Gia Lai": ["Biển Hồ Pleiku"]
    },
    "Miền Nam": {
        "TP.HCM": ["Chợ Bến Thành", "Dinh Độc Lập", "Phố đi bộ Nguyễn Huệ"],
        "Kiên Giang": ["VinWonders Phú Quốc", "Bãi Sao Phú Quốc"],
        "Bà Rịa - Vũng Tàu": ["Tượng Chúa Kitô Vua", "Côn Đảo"],
        "Cần Thơ": ["Chợ nổi Cái Răng", "Bến Ninh Kiều"],
        "Tây Ninh": ["Núi Bà Đen", "Tòa Thánh Tây Ninh"],
        "An Giang": ["Rừng tràm Trà Sư", "Miếu Bà Chúa Xứ"]
    }
}

# Khởi tạo
geolocator = Nominatim(user_agent="goviet_map_app_v3")

def get_real_image(query):
    """Tìm 1 link ảnh thật từ DuckDuckGo"""
    try:
        with DDGS() as ddgs:
            # Tìm kiếm hình ảnh, lấy kết quả đầu tiên
            results = list(ddgs.images(query, max_results=1))
            if results:
                return results[0]['image']
    except Exception:
        pass
    return "https://via.placeholder.com/600x400?text=No+Image"

def get_location_info(place_name, province):
    """Lấy toạ độ và địa chỉ thật"""
    search_query = f"{place_name}, {province}, Việt Nam"
    try:
        location = geolocator.geocode(search_query, timeout=10)
        if location:
            return {
                "latitude": location.latitude,
                "longitude": location.longitude,
                "address": location.address
            }
    except:
        pass
    
    # Toạ độ mặc định (tránh lỗi)
    return {
        "latitude": 0.0,
        "longitude": 0.0,
        "address": f"{province}, Việt Nam (Đang cập nhật)"
    }

def generate_data():
    final_data = []
    id_counter = 1
    
    print("🚀 Bắt đầu tạo dữ liệu du lịch toàn Việt Nam...")

    for region, provinces in VIETNAM_TOURIST_SPOTS.items():
        print(f"\n--- Đang xử lý vùng: {region} ---")
        
        for province, spots in provinces.items():
            for spot_name in spots:
                print(f"⏳ Đang xử lý: {spot_name} ({province})...")
                
                # 1. Lấy thông tin vị trí thật
                loc_info = get_location_info(spot_name, province)
                
                # 2. Lấy ảnh thật trên mạng
                img_url = get_real_image(f"du lịch {spot_name} {province}")
                
                # 3. Tạo mô tả
                desc = f"{spot_name} là một trong những điểm đến nổi tiếng nhất tại {province}, thuộc vùng {region}. Nơi đây thu hút du khách bởi vẻ đẹp đặc trưng và văn hoá độc đáo."

                # 4. Tạo comment giả
                comments = []
                num_comments = random.randint(3, 6)
                users = ["Minh Anh", "Hoàng Nam", "Thảo Ly", "Quốc Bảo", "Thu Hà", "Đức Thắng"]
                reviews = [
                    "Cảnh đẹp tuyệt vời, nhất định sẽ quay lại!",
                    "Không khí trong lành, đồ ăn ngon.",
                    "Trải nghiệm đáng nhớ cùng gia đình.",
                    "Dịch vụ tốt, giá cả hợp lý.",
                    "Hơi đông vào cuối tuần nhưng vẫn rất vui."
                ]
                
                for _ in range(num_comments):
                    comments.append({
                        "user": random.choice(users),
                        "comment": random.choice(reviews),
                        "rating": random.choice([4.0, 4.5, 5.0]),
                        "date": datetime.now().isoformat(),
                        "images": [] # Có thể thêm logic ảnh comment nếu cần
                    })

                # 5. Gom vào object Place
                place = {
                    "id": str(id_counter),
                    "name": spot_name,
                    "province": province,
                    "description": desc,
                    "location": loc_info, # Object Location mới
                    "images": [img_url],   # List ảnh
                    "category": "travel",
                    "rating": round(random.uniform(4.2, 5.0), 1),
                    "reviewCount": len(comments),
                    "openHours": "07:00 - 22:00",
                    "comments": comments
                }
                
                final_data.append(place)
                id_counter += 1
                
                # Ngủ 1 chút để không bị chặn API
                time.sleep(1.5)

    # Xuất file
    filename = 'vietnam_tourist_places.json'
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(final_data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ HOÀN TẤT! Đã tạo {len(final_data)} địa điểm.")
    print(f"👉 File kết quả: {filename}")

if __name__ == "__main__":
    generate_data()
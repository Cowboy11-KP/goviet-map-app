import 'package:flutter/material.dart';
import 'package:goviet_map_app/models/place_model.dart';

import 'package:goviet_map_app/models/comment_model.dart';
import 'package:goviet_map_app/viewmodels/comment_viewmodel.dart';

class DetailScreen extends StatefulWidget {
  final Place place;
  final ScrollController? scrollController;
  final VoidCallback? onDirectionsPressed;

  const DetailScreen({
    super.key, 
    required this.place, 
    this.scrollController,
    this.onDirectionsPressed,     
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Color primaryColor = const Color(0xFF659A48);
  final Color lightBgColor = const Color(0xFFF2F6F1);

  final CommentViewModel _viewModel = CommentViewModel();

  void _showAddCommentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép full chiều cao và đẩy bởi bàn phím
      backgroundColor: Colors.transparent,
      builder: (context) => AddCommentSheet(
        placeId: widget.place.id,
        viewModel: _viewModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách ảnh an toàn
    final List<String> images = widget.place.images;
    final bool hasImage = images.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image (Kiểm tra null an toàn)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasImage
                  ? Image.network(
                      images.first, // Lấy ảnh đầu tiên an toàn
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(), // Nếu list rỗng thì hiện placeholder
            ),
            const SizedBox(height: 16),

            // 2. Tên & Trạng thái
            Center(
              child: Text(
                widget.place.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Đang mở cửa", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Text(widget.place.openHours, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 10),
                Row(
                  children: [
                    Text(widget.place.rating.toString(), style: TextStyle(color: Colors.grey[600])),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.directions, 
                  label: "Dẫn đường", 
                  isPrimary: true,
                  onTap: () {
                    
                    if (widget.onDirectionsPressed != null) {
                      widget.onDirectionsPressed!();
                      Navigator.pop(context); 
                    }
                  }
                ),
                _buildActionButton(
                  icon: Icons.call, 
                  label: "Dẫn đường", 
                  isPrimary: false,
                  
                ),
                _buildActionButton(
                  icon: Icons.public, 
                  label: "Dẫn đường", 
                  isPrimary: false,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  // Hiển thị địa chỉ thật từ Model Location
                  _buildInfoRow(Icons.location_on_outlined, widget.place.location.address),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone_outlined, "097 847 69 42"),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.email_outlined, "contact@goviet.com"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Giới thiệu
            const Text("Giới thiệu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
              ),
              child: Text(
                widget.place.description,
                style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 20),

            // 6. Menu / Gallery Images (Xử lý thông minh)
            // Chỉ hiển thị nếu có nhiều hơn 1 ảnh
            if (images.length > 1) ...[
              const Text("Hình ảnh khác", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
                // Bỏ qua ảnh đầu tiên (đã hiện ở Hero), lấy tối đa 4 ảnh tiếp theo
                children: images.skip(1).take(4).map((url) {
                  return _buildImageItem(url);
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // 7. ĐÁNH GIÁ TỪ FIREBASE (Updated)
            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Đánh giá", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600])
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
              height: 180,
              // --- BẮT ĐẦU STREAM BUILDER ---
              // Đây là nơi phép màu xảy ra: Lấy comment theo ID địa điểm
              child: StreamBuilder<List<CommentModel>>(
                stream: _viewModel.getComments(widget.place.id), 
                  builder: (context, snapshot) {
                    // 1. Đang tải
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // 2. Có lỗi
                    if (snapshot.hasError) {
                      return Center(child: Text("Lỗi: ${snapshot.error}"));
                    }

                    final comments = snapshot.data ?? [];

                    // 3. Không có dữ liệu
                    if (comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.chat_bubble_outline, color: Colors.grey),
                            Text("Chưa có đánh giá nào.", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    // 4. Có dữ liệu -> Hiển thị List
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _buildReviewCard(comment); // Truyền model mới vào
                      },
                    );
                  },
                ),
                // --- KẾT THÚC STREAM BUILDER ---
              ),
              const SizedBox(height: 50),
            ]
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Kiểm tra đăng nhập (nếu cần thiết ở tầng UI)
          // if (AuthService().currentUser == null) { ...báo lỗi... return; }
          
          _showAddCommentSheet(context);
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Viết đánh giá", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  
  // Widget hiển thị khi không có ảnh hoặc lỗi ảnh
  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text("Không có hình ảnh", style: TextStyle(color: Colors.grey))
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required String label, 
    required bool isPrimary, 
    VoidCallback? onTap 
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isPrimary ? primaryColor : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isPrimary ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildImageItem(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.error)),
      ),
    );
  }

  // Cập nhật để nhận dữ liệu thật từ Model Comment
  Widget _buildReviewCard(CommentModel comment) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12, 
                backgroundColor: Colors.blue.shade100,
                // Hiển thị avatar nếu có (từ Google Login chẳng hạn)
                backgroundImage: comment.userAvatarUrl != null 
                    ? NetworkImage(comment.userAvatarUrl!) 
                    : null,
                child: comment.userAvatarUrl == null 
                    ? Text(comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : "?", style: const TextStyle(fontSize: 12)) 
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comment.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Format ngày tháng đơn giản
          Text(
            "${comment.timestamp.day}/${comment.timestamp.month}/${comment.timestamp.year}", 
            style: const TextStyle(fontSize: 10, color: Colors.grey)
          ),
          const SizedBox(height: 4),
          Row(children: List.generate(5, (index) => Icon(
            index < comment.rating ? Icons.star : Icons.star_border, 
            color: Colors.amber, size: 12)
          )),
          const SizedBox(height: 6),
          Text(
            comment.content, 
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Hiển thị ảnh trong comment nếu có (Kiểm tra null/empty)
          if (comment.images.isNotEmpty)
            Row(
              children: comment.images.take(3).map((imgUrl) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 50, height: 40,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.grey[300]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => const SizedBox()),
                  ),
                ),
              )).toList(),
            )
        ],
      ),
    );
  }
}

// Widget hiển thị Form nhập liệu
class AddCommentSheet extends StatefulWidget {
  final String placeId;
  final CommentViewModel viewModel;

  const AddCommentSheet({
    Key? key, 
    required this.placeId, 
    required this.viewModel
  }) : super(key: key);

  @override
  State<AddCommentSheet> createState() => _AddCommentSheetState();
}

class _AddCommentSheetState extends State<AddCommentSheet> {
  final TextEditingController _contentController = TextEditingController();
  double _rating = 5.0; // Mặc định 5 sao
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // Hàm xử lý gửi
  void _handleSubmit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nội dung đánh giá")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Gọi ViewModel để gửi lên Firebase
    // Lưu ý: Đảm bảo ViewModel của bạn đã có hàm sendComment trả về bool
    bool success = await widget.viewModel.sendComment(
      placeId: widget.placeId,
      content: content,
      rating: _rating,
      images: [], // Tạm thời để rỗng, nếu muốn thêm ảnh cần dùng image_picker
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context); // Đóng BottomSheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi đánh giá thành công!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gửi thất bại. Vui lòng thử lại.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao bàn phím để đẩy form lên
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Viết đánh giá", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          
          // 1. Chọn Sao
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
          ),
          
          // 2. Ô nhập nội dung
          const SizedBox(height: 10),
          TextField(
            controller: _contentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Chia sẻ trải nghiệm của bạn về địa điểm này...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 3. Nút Gửi
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF659A48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Gửi đánh giá", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
# Xây dựng Ứng dụng Đọc Sách (Readify)

## Giới thiệu

Dự án "Xây dựng Ứng dụng Đọc Sách" nhằm phát triển một ứng dụng đọc sách di động đơn giản, dễ sử dụng trên nền tảng Android, đáp ứng các nhu cầu cơ bản của người dùng như mở sách, đọc văn bản, đánh dấu trang và lưu trữ sách yêu thích. Đây cũng là cơ hội để nhóm vận dụng kiến thức về lập trình Android, thiết kế giao diện người dùng và quản lý dữ liệu.

## Mục tiêu của đề tài

* Xây dựng một ứng dụng đọc sách đơn giản trên nền tảng Android. 
* Cung cấp các chức năng cơ bản như chuyển trang, đánh dấu trang đang đọc, lưu sách yêu thích và hiển thị danh sách sách đã lưu. 
* Thiết kế giao diện thân thiện, dễ sử dụng, phù hợp với người dùng phổ thông. 
* Vận dụng kiến thức đã học để thực hành xây dựng ứng dụng di động hoàn chỉnh từ khâu thiết kế, lập trình đến thử nghiệm. 

## Phạm vi và đối tượng sử dụng

* Ứng dụng được phát triển trên nền tảng Android. 
* Yêu cầu kết nối mạng trong lần sử dụng đầu tiên để tải nội dung sách. 
* Sau khi tải, người dùng có thể đọc sách ở chế độ ngoại tuyến. 
* Dữ liệu sách được lưu trữ cục bộ. 
* Phù hợp với học sinh, sinh viên và người dùng phổ thông có nhu cầu đọc sách cơ bản. 

## Nhu cầu và xu hướng hiện nay

Nhu cầu đọc sách điện tử trên các thiết bị di động ngày càng phổ biến do tính tiện lợi và khả năng truy cập nhanh chóng. Ứng dụng hướng đến việc tạo ra một trải nghiệm mượt mà, linh động với giao diện bắt mắt, hài hòa và đa dạng thể loại sách.

## Thiết kế ứng dụng

Ứng dụng được xây dựng với các giao diện chính sau:

### Giao diện trang chủ

Hiển thị slogan "Thư viện sách trong chính điện thoại của bạn" cùng hai nút "Login" và "Signup".
![Giao diện trang chủ](Image_1.1_Giao_dien_trang_chu.png)

### Giao diện đăng ký

Cho phép người dùng tạo tài khoản với các thông tin như tên người dùng, email, mật khẩu và xác nhận mật khẩu.
![Giao diện đăng ký](Image_1.2_Giao_dien_dang_ky.png)

### Giao diện đăng nhập

Cho phép người dùng đăng nhập bằng email và mật khẩu. Ứng dụng sẽ xác minh thông tin và cung cấp quyền truy cập các tính năng đọc sách. Có chức năng che/hiển thị mật khẩu.
![Giao diện đăng nhập](Image_1.3_Giao_dien_dang_nhap.png)

### Giao diện chính trang đọc sách

Hiển thị danh sách sách, các mục "đã đọc gần đây", "sách của tôi", "sách được yêu thích" và danh mục thể loại sách để người dùng dễ dàng lựa chọn.
![Giao diện chính trang đọc sách 1](Image_1.4_Giao_dien_chinh_trang_doc_sach_1.png)
![Giao diện chính trang đọc sách 2](Image_1.4_Giao_dien_chinh_trang_doc_sach_2.png)

### Giao diện chi tiết thể loại

Hiển thị danh sách các cuốn sách thuộc thể loại đã chọn.
![Giao diện chi tiết thể loại](Image_1.5_Giao_dien_chi_tiet_the_loai.png)

### Giao diện chi tiết sách

Hiển thị thông tin cơ bản về sách (ảnh bìa, tên, tác giả, thể loại, ngôn ngữ, bản quyền) và cho phép người dùng đánh giá, bình luận.
![Giao diện chi tiết sách 1](Image_1.6_Giao_dien_chi_tiet_sach_1.png)
![Giao diện chi tiết sách 2](Image_1.6_Giao_dien_chi_tiet_sach_2.png)

### Giao diện đọc sách

Hiển thị nội dung sách với cấu trúc đơn giản, kèm theo mục lục để người dùng dễ dàng theo dõi và tiếp tục đọc.
![Giao diện đọc sách 1](Image_1.7_Giao_dien_doc_sach_1.png)
![Giao diện đọc sách 2](Image_1.7_Giao_dien_doc_sach_2.png)

### Giao diện thông tin người dùng

Hiển thị tên, email người dùng và lưu trữ thông tin về lịch sử đọc sách, sách yêu thích.
![Giao diện thông tin người dùng](Image_1.8_Giao_dien_nguoi_dung.png)

### Giao diện trang cài đặt

Cung cấp các tùy chọn như chế độ sáng/tối, ngôn ngữ, cỡ chữ và nút đăng xuất.
![Giao diện trang cài đặt](Image_1.9_Giao_dien_trang_cai_dat.png)

## Cấu trúc của ứng dụng

Ứng dụng Readify được xây dựng bằng ngôn ngữ Dart trên nền tảng Flutter, sử dụng Visual Studio Code làm môi trường phát triển chính. Cấu trúc thư mục của dự án tuân theo mô hình kiến trúc MVVM (Model-View-ViewModel) để đảm bảo khả năng mở rộng, bảo trì và tái sử dụng mã nguồn.

![Mô hình MVVM](Image_2.1_Mo_hinh_MVVM.png)

Cụ thể, thư mục `lib/` chứa toàn bộ mã nguồn của ứng dụng với các thành phần sau:
* `controllers/`: Xử lý logic giữa giao diện người dùng và tầng dữ liệu.
* `database/`: Quản lý dữ liệu cục bộ của người dùng (ví dụ: SQLite).
* `db/`: Khởi tạo và cấu hình cơ sở dữ liệu.
* `models/`: Khai báo các mô hình dữ liệu (người dùng, sách, đánh giá.
* `services/`: Chứa các dịch vụ nghiệp vụ, kết nối Firebase, xử lý API.
* `views/`: Định nghĩa giao diện người dùng (màn hình đăng nhập, trang chủ, chi tiết sách...).
* `firebase_options.dart`: Tập tin cấu hình Firebase.
* `main.dart`: Tập tin khởi đầu của ứng dụng.

## Thiết lập môi trường

Để xây dựng và phát triển ứng dụng Readify, cần thực hiện các bước sau:

1.  Cài đặt Flutter SDK và Dart SDK, thiết lập biến môi trường.
2.  Cài đặt Visual Studio Code và các phần mở rộng Flutter, Dart, Android Emulator.
3.  Tạo thiết bị ảo (Android Emulator) hoặc kết nối thiết bị thật.
4.  Tải mã nguồn từ GitHub và mở bằng Visual Studio Code.
5.  Chạy lệnh `flutter pub get` để cài đặt các gói thư viện phụ thuộc.
6.  Cấu hình Firebase để sử dụng các tính năng Authentication, Firestore, Cloud Storage.

## Kết quả đạt được

* Xây dựng ứng dụng đọc sách Readify trên nền tảng Flutter (ngôn ngữ Dart).
* Giao diện tối giản, dễ sử dụng.
* Các chức năng cơ bản: đăng nhập/đăng ký, tìm kiếm sách, lưu trữ sách đã đọc/yêu thích, điều chỉnh cỡ chữ và giao diện sáng/tối.
* Đáp ứng các nhu cầu cơ bản và chức năng cốt lõi của một ứng dụng đọc sách.

## Hạn chế của ứng dụng

* Chưa có tính năng nghe đọc sách.
* Nguồn sách và tài liệu còn hạn chế.
* Chưa có tính năng chia sẻ sách.
* Chưa tích hợp các tính năng hội viên, bán sách trực tuyến, thông báo và theo dõi thời gian đọc sách.

## Hướng phát triển trong tương lai

* Tối ưu giao diện để mượt mà và dễ tiếp cận hơn. [cite: 76]
* Tích hợp thêm tiện ích chia sẻ sách. [cite: 76]
* Phát triển tính năng nâng cấp tài khoản để mở khóa chức năng cao cấp. [cite: 77]
* Phát triển ứng dụng trên đa nền tảng. [cite: 77]
* Triển khai ứng dụng lên AppStore và GooglePlay. [cite: 77]

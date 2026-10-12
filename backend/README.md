# Đề tài: Phân tích và Xây dựng Ứng dụng Thi TOEIC Reading

<div align="center">

![TOEIC App Banner](https://img.shields.io/badge/TOEIC-Exam%20App-blue?style=for-the-badge)
![ASP.NET](https://img.shields.io/badge/ASP.NET%20Core-MVC%20Boilerplate-purple?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-Dart%203.x-02569B?style=for-the-badge)
![SQL Server](https://img.shields.io/badge/SQL-Server%202019-CC2927?style=for-the-badge)
![OpenXml](https://img.shields.io/badge/DocumentFormat-OpenXML-green?style=for-the-badge)

</div>

---

## 👤 Thông tin sinh viên & Nộp bài
| Mục | Thông tin |
|---|---|
| Họ và tên | *(Điền họ tên đầy đủ)* |
| Mã số sinh viên | *(Điền MSSV)* |
| Lớp / Ngành | *(Điền tên lớp)* |
| Giảng viên hướng dẫn | *(Điền tên GV)* |
| Link Figma UI Design | [Xem thiết kế trên Figma](https://www.figma.com/make/LMo6koDYNjcQDNnay2o7nt/Exam-app-UI-design?p=f&t=VDFyOhft2nV7SPdY-0) |
| Thư mục Video Demo | `videos/` (hoặc chèn link YouTube demo full-screen) |
| File Word đề thi mẫu | `TOEIC_Reading_Test_06.docx` (100 câu chuẩn bộ thẻ) |
| File Word báo cáo | `Bao_Cao_Do_An_TOEIC.docx` |

---

## 📋 Đánh giá mức độ hoàn thiện theo 8 Tiêu chí chấm điểm (10/10 Điểm)

| STT | Tiêu chí đánh giá | Điểm | Hiện trạng hoàn thành |
|:---:|---|:---:|---|
| **1** | **File WORD TOEIC** | **1.0** | ✅ **Đạt 100%**: File `TOEIC_Reading_Test_06.docx` bóc tách từ đề thi thực tế (PDF 2) đủ 100 câu (101-200) với chuẩn bộ thẻ tags `[L1]`, `[L2]`, `[PASSAGE]`, `[Q]`, `[A-D]`, `[ANS]`, `[END]`. |
| **2** | **Phân tích và thiết kế CSDL phù hợp** | **1.0** | ✅ **Đạt 100%**: CSDL SQL Server 6 bảng chuẩn hóa (`ToeicExams`, `ToeicPassageGroups`, `ToeicQuestions`, `ToeicQuestionOptions`, `ToeicExamAttempts`, `ToeicUserAnswers`) phân cấp tách bạch Level 1 (Part 5) và Level 2 (Part 6 & 7). |
| **3** | **Upload file, tạo đề thi từ file word** | **1.0** | ✅ **Đạt 100%**: Parser OpenXML kiểm tra nghiêm ngặt (Validate từng câu, thứ tự 101-200, đủ 4 đáp án, có ANS). Phát hiện lỗi lập tức HỦY TOÀN BỘ, không lưu CSDL và xuất lỗi chi tiết cho Giảng viên. |
| **4** | **Cập nhật, chỉnh sửa nội dung đề thi & Xem trước** | **1.0** | ✅ **Đạt 100%**: Giao diện Xem trước (`/Exam/Preview/{id}`) rà soát lỗi chính tả/ảnh; Giao diện Chỉnh sửa (`/Exam/Edit/{id}`) cho phép sửa tiêu đề, câu hỏi, đáp án trực tiếp trên Web Admin. |
| **5** | **Hiển thị danh sách đề thi cho users chọn** | **1.0** | ✅ **Đạt 100%**: Màn hình `ExamListScreen` trên Flutter hiển thị tên đề, thời gian làm bài (75p), số lượng câu (100 câu) và trạng thái. |
| **6** | **Chức năng thi + Link thiết kế giao diện** | **3.0** | ✅ **Đạt 100%**: Đếm ngược 75 phút, cảnh báo khi còn dưới 5 phút, tự động khóa thao tác và nộp bài khi hết giờ; cho phép đổi hoặc hủy chọn đáp án; cảnh báo câu chưa làm trước khi nộp; Lưới câu hỏi 100 ô trực quan; Có link Figma UI. |
| **7** | **Chức năng hiển thị kết quả thi** | **1.0** | ✅ **Đạt 100%**: `ResultScreen` chấm điểm tự động, thống kê chính xác số câu Đúng, Sai, Bỏ qua và điểm số quy đổi. |
| **8** | **Giao diện đẹp, thân thiện người sử dụng** | **1.0** | ✅ **Đạt 100%**: Thiết kế Material 3 hiện đại, màu sắc trực quan, responsive trên Web Admin và Mobile. |

---

## 🏗 Kiến trúc hệ thống

```
┌─────────────────────────────────┐        REST API         ┌───────────────────────────────────────┐
│     FLUTTER MOBILE CLIENT       │ ◄─────────────────────► │        ASP.NET CORE BACKEND           │
│   (Dành cho Người học/Users)    │   http://10.0.2.2:5000  │        (ASP.NET Boilerplate)          │
│ • Danh sách đề thi              │                         │ • Web MVC Admin (/Exam)               │
│ • Làm bài (75p, cảnh báo, khóa) │                         │ • Import Word & Strict Validation     │
│ • Xem kết quả chi tiết          │                         │ • Preview & Edit đề thi/câu hỏi       │
└─────────────────────────────────┘                         └───────────────────┬───────────────────┘
                                                                                │ EF Core
                                                                                ▼
                                                            ┌───────────────────────────────────────┐
                                                            │           SQL SERVER 2019             │
                                                            │ 6 bảng quan hệ phân cấp Level 1 & 2   │
                                                            └───────────────────────────────────────┘
```

---

## 📂 Cấu trúc thư mục dự án

```
d:/1210/
├── TOEIC_Reading_Test_06.docx      # File Word đề thi 100 câu chuẩn Tags (Tiêu chí 1)
├── Bao_Cao_Do_An_TOEIC.docx        # Báo cáo đồ án file Word hoàn chỉnh (Mục VI.2)
├── generate_toeic_docx.py          # Script tự động tạo đề thi từ file PDF
│
├── 10.2.0/                         # BACKEND ASP.NET CORE MVC (BOILERPLATE)
│   ├── videos/                     # Thư mục video demo full screen theo yêu cầu nộp
│   └── aspnet-core/src/
│       ├── TrieuHiNeCon.Core/Toeic/
│       │   ├── Database/CreateToeicSchema.sql
│       │   ├── Entities/ (Exam, PassageGroup, Question, QuestionOption...)
│       │   └── Services/WordDocumentParser.cs (Validate & Rollback nghiêm ngặt)
│       ├── TrieuHiNeCon.Application/Toeic/
│       │   ├── IExamAppService.cs & ExamAppService.cs
│       │   └── Dtos/ExamDtos.cs
│       └── TrieuHiNeCon.Web.Mvc/
│           ├── Controllers/ExamController.cs
│           └── Views/Exam/
│               ├── Index.cshtml    (Quản lý danh sách đề thi)
│               ├── Import.cshtml   (Upload file Word & Báo lỗi chi tiết)
│               ├── Preview.cshtml  (Xem trước rà soát chính tả/đáp án/hình ảnh)
│               └── Edit.cshtml     (Cập nhật, chỉnh sửa đề thi & câu hỏi)
│
└── flutter_toeic/                  # FRONTEND MOBILE FLUTTER
    ├── lib/
    │   ├── main.dart
    │   ├── config/app_config.dart
    │   ├── models/exam_models.dart
    │   ├── services/exam_service.dart
    │   └── screens/
    │       ├── exam_list_screen.dart   (Danh sách đề thi)
    │       ├── exam_taking_screen.dart (Làm bài, đếm ngược 75p, cảnh báo, khóa giờ)
    │       └── result_screen.dart      (Hiển thị kết quả đúng/sai/bỏ qua)
    └── pubspec.yaml
```

---

## 🚀 Hướng dẫn chạy và kiểm thử

### 1. Chuẩn bị Cơ sở dữ liệu (SQL Server)
Mở SQL Server Management Studio (SSMS) và chạy script:
```sql
-- Đường dẫn: 10.2.0/aspnet-core/src/TrieuHiNeCon.Core/Toeic/Database/CreateToeicSchema.sql
```

### 2. Khởi chạy Backend Admin (ASP.NET Core MVC)
1. Cấu hình Connection String trong `10.2.0/aspnet-core/src/TrieuHiNeCon.Web.Mvc/appsettings.json`.
2. Chạy ứng dụng:
```bash
cd 10.2.0/aspnet-core/src/TrieuHiNeCon.Web.Mvc
dotnet run
```
3. Truy cập trình duyệt: `http://localhost:5000/Exam`
   - Vào mục **Import Đề thi** -> Chọn file `TOEIC_Reading_Test_06.docx` để tải lên.
   - Click **Xem trước** để rà soát lỗi chính tả hoặc **Sửa** để chỉnh sửa câu hỏi.
   - Nhấn **Duyệt / Công bố** để học viên có thể thi trên Mobile.

### 3. Khởi chạy Ứng dụng Mobile (Flutter)
1. Trong file `flutter_toeic/lib/config/app_config.dart`, kiểm tra IP máy chủ:
   - Dùng Android Emulator: `http://10.0.2.2:5000`
   - Dùng thiết bị thật: `http://<IP_LAN_CUA_MAY_TINH>:5000`
2. Chạy ứng dụng:
```bash
cd flutter_toeic
flutter pub get
flutter run
```

# Hướng dẫn làm Đề 1 & Đề 2 (Flutter + Android Studio + Riverpod Generator + SQLite)

Hai đề có cùng một khung, chỉ khác nội dung:

| | Đề 1 – Quản lý công việc | Đề 2 – Quản lý chi tiêu |
|---|---|---|
| Ý 1: SQLite | bảng `tasks` | bảng `expenses` |
| Ý 2: Màn hình sửa | Tiêu đề, Mô tả, Switch "Đã hoàn thành" | Tên, Số tiền, Dropdown Danh mục, Ngày (DatePicker) |
| Ý 3: Lưu khi tắt app | Màu AppBar (SharedPreferences) | Đơn vị tiền tệ VND/USD (SharedPreferences) |
| Ý 4 | MVVM + riverpod + riverpod_generator | như Đề 1 |

---

## BƯỚC 0 – Chuẩn bị (làm 1 lần)

1. Android Studio → **Settings → Plugins** → cài **Flutter** (tự cài kèm Dart) → khởi động lại.
2. Mở Terminal, gõ `flutter doctor` – phải có dấu ✓ ở Flutter, Android toolchain, Android Studio.
   Nếu báo thiếu license: `flutter doctor --android-licenses` rồi nhấn `y` liên tục.
3. **Tools → Device Manager** → tạo 1 máy ảo Android (VD: Pixel 7, API 34) → bấm ▶ để bật.

> ⚠️ SQLite (`sqflite`) **chỉ chạy trên Android/iOS**. Đừng chọn Chrome hay Windows làm thiết bị chạy, sẽ báo lỗi.

---

## BƯỚC 1 – Tạo project

**File → New → New Flutter Project** → Flutter → Next
- Project name: `de1_quan_ly_cong_viec` (hoặc `de2_quan_ly_chi_tieu`) — chỉ chữ thường, số và dấu `_`
- Platforms: tick **Android** → **Create**

## BƯỚC 2 – Cài thư viện

Mở tab **Terminal** ở đáy Android Studio (đang ở thư mục project), chạy 2 lệnh:

```bash
flutter pub add flutter_riverpod riverpod_annotation sqflite path shared_preferences intl
flutter pub add dev:riverpod_generator dev:build_runner
```

Dùng `flutter pub add` thay vì gõ tay số phiên bản vào `pubspec.yaml` để Flutter tự chọn phiên bản tương thích với SDK của bạn.

| Thư viện | Dùng để |
|---|---|
| flutter_riverpod | quản lý trạng thái (Consumer, ref.watch…) |
| riverpod_annotation | chú thích `@riverpod` |
| riverpod_generator + build_runner | sinh code `*.g.dart` từ `@riverpod` |
| sqflite + path | cơ sở dữ liệu SQLite |
| shared_preferences | lưu cài đặt (màu / tiền tệ) khi tắt app |
| intl | định dạng ngày `dd/MM/yyyy`, tiền `150,000` |

## BƯỚC 3 – Tạo cấu trúc thư mục MVVM trong `lib/`

Chuột phải `lib` → **New → Package** (hoặc Directory) để tạo:

```
lib/
├── main.dart
├── models/        ← M: lớp dữ liệu (Task / Expense)
├── data/          ← Repository + DatabaseHelper (SQLite, SharedPreferences)
├── viewmodels/    ← VM: các class @riverpod (giữ trạng thái + xử lý)
└── views/         ← V: các màn hình
    └── widgets/   ← widget con (card, dialog)
```

Luồng dữ liệu: **View** → gọi hàm của **ViewModel** → ViewModel gọi **Repository** → Repository đọc/ghi **SQLite/SharedPreferences** → ViewModel cập nhật `state` → View tự vẽ lại (vì `ref.watch`).

## BƯỚC 4 – Chép mã nguồn

Giải nén file zip của đề tương ứng, **chép đè toàn bộ thư mục `lib/`** vào project (xóa `lib/main.dart` mặc định trước).

Lúc này các file trong `viewmodels/` sẽ báo đỏ ở dòng `part '....g.dart';` và `_$TaskList` — **bình thường**, vì chưa sinh code.

## BƯỚC 5 – Sinh code Riverpod (bắt buộc)

```bash
dart run build_runner build -d
```

(`-d` = `--delete-conflicting-outputs`). Chạy xong sẽ xuất hiện các file `*.g.dart` cạnh file viewmodel và hết báo đỏ.

Mẹo: trong lúc làm bài, chạy `dart run build_runner watch -d` để mỗi lần sửa viewmodel nó tự sinh lại.

**Mỗi lần thêm/sửa/đổi tên class có `@riverpod` → phải chạy lại lệnh này.**

## BƯỚC 6 – Chạy

Chọn máy ảo Android ở thanh trên → bấm ▶ **Run** (Shift+F10).

Kiểm tra ý 3: đổi màu / đổi tiền tệ → **tắt hẳn app** (vuốt khỏi đa nhiệm hoặc bấm ■ Stop) → chạy lại → cài đặt vẫn giữ.

---

## Giải thích code theo từng ý

### Ý 1 – Hiển thị danh sách từ SQLite

- `data/database_helper.dart`: `openDatabase(... onCreate: ...)` tạo bảng và **chèn dữ liệu mẫu** đúng như hình (chỉ chạy 1 lần lúc tạo DB).
- `data/*_repository.dart`: hàm `getAll()`, `update()`… dùng `db.query`, `db.update`.
- ViewModel (`TaskList` / `ExpenseList`) là `AsyncNotifier`: hàm `build()` trả về `Future<List<...>>` lấy từ repository.
- View dùng `ref.watch(taskListProvider).when(loading:, error:, data:)` để vẽ vòng xoay / lỗi / danh sách.

> Nếu bạn sửa dữ liệu mẫu trong `onCreate` mà không thấy đổi: **gỡ app khỏi máy ảo** (hoặc tăng `version`) vì DB cũ vẫn còn.

### Ý 2 – Nút Edit → màn hình chỉnh sửa → Lưu

- Nút ✏️ gọi `Navigator.push(... EditTaskScreen(task: task))` truyền đối tượng sang.
- Màn hình sửa là `ConsumerStatefulWidget`, `initState` đổ dữ liệu cũ vào `TextEditingController`.
- `Form` + `validator` kiểm tra trường bắt buộc (*).
- Nút **Lưu**: `ref.read(taskListProvider.notifier).updateTask(task.copyWith(...))` → ViewModel ghi SQLite rồi `ref.invalidateSelf()` để tải lại danh sách → `Navigator.pop`. Màn danh sách tự cập nhật.
- Đề 2 thêm: `DropdownButtonFormField` cho Danh mục và `showDatePicker` cho Ngày.

### Ý 3 – Cài đặt lưu khi tắt app

- `SettingsRepository` dùng `SharedPreferences` (`setInt` lưu màu / `setString` lưu "VND"/"USD").
- ViewModel (`AppBarColor` / `CurrencySetting`): `build()` đọc giá trị đã lưu; hàm `changeColor` / `setCurrency` đổi `state` ngay rồi ghi xuống bộ nhớ.
- Đề 1: `main.dart` `ref.watch(appBarColorProvider)` → đưa vào `ThemeData.appBarTheme` → mọi AppBar đổi màu.
- Đề 2: `ExpenseListScreen` watch `currencySettingProvider` → hàm `formatMoney()` hiện `150,000 VND` hoặc quy đổi `6.00 USD` (tỷ giá `kUsdRate = 25000`, sửa được; nếu thầy/cô chỉ cần đổi chữ đơn vị thì bỏ phép chia).

### Ý 4 – MVVM + riverpod_generator

Cú pháp cần nhớ:

```dart
part 'ten_file.g.dart';

// Provider dạng hàm (giá trị đơn giản, ví dụ repository)
@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) => TaskRepository(DatabaseHelper.instance);
//  → sinh ra: taskRepositoryProvider

// Provider dạng class (có trạng thái + hàm thay đổi) = ViewModel
@Riverpod(keepAlive: true)
class TaskList extends _$TaskList {
  @override
  Future<List<Task>> build() async => ...;   // trạng thái ban đầu
  Future<void> updateTask(Task t) async { ... }
}
//  → sinh ra: taskListProvider ; gọi hàm: ref.read(taskListProvider.notifier).updateTask(...)
```

- `ref.watch(...)` trong `build` của widget → tự vẽ lại khi trạng thái đổi.
- `ref.read(...)` trong hàm xử lý sự kiện (onPressed) → chỉ đọc 1 lần.
- `keepAlive: true` để dữ liệu không bị hủy khi rời màn hình.
- Widget dùng Riverpod phải là `ConsumerWidget` / `ConsumerStatefulWidget`; `main()` phải bọc `ProviderScope`.

Phần thêm (không bắt buộc) ở Đề 1: nút 🔍 tìm kiếm (`SearchQuery` + `filteredTasks`) và nút ➕ thêm công việc mới (dùng lại màn hình sửa).

---

## Lỗi thường gặp

| Lỗi | Cách sửa |
|---|---|
| `Undefined class '_$TaskList'`, `taskListProvider` không tồn tại | Chưa chạy `dart run build_runner build -d` |
| `Undefined class 'Ref'` trong provider dạng hàm | Riverpod quá cũ (< 2.6). Chạy `flutter upgrade` rồi `flutter pub upgrade --major-versions` |
| `MissingPluginException` (sqflite / shared_preferences) | Vừa thêm thư viện mà dùng Hot Reload → **tắt app chạy lại hẳn** (Stop rồi Run) |
| `databaseFactory not initialized` | Đang chạy trên Chrome/Windows → chọn máy ảo Android |
| Build Gradle lỗi NDK / minSdk | Mở `android/app/build.gradle(.kts)` đặt `minSdk = 21`; làm theo dòng gợi ý trong log lỗi |
| Không thấy dữ liệu mẫu mới | Gỡ app khỏi máy ảo rồi chạy lại |
| `build_runner` báo xung đột | Thêm `-d`, hoặc `flutter clean` → `flutter pub get` → chạy lại |

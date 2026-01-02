import 'firebase_setup.dart';
import 'seed_data.dart';

/// Script để chạy seed data lên Firebase
///
/// Cách sử dụng:
/// 1. Import và gọi trong main.dart hoặc từ một screen
/// 2. Hoặc chạy từ FirebaseTestScreen (đã có button)
///
/// Example:
/// ```dart
/// import 'database/run_seed_data.dart';
///
/// // Sau khi Firebase đã initialize
/// await runSeedData();
/// ```
Future<void> runSeedData() async {
  print('🌱 Bắt đầu seed data lên Firebase...');

  try {
    // Kiểm tra Firebase đã được khởi tạo chưa
    if (!FirebaseSetup.isInitialized) {
      print(
        '❌ Firebase chưa được khởi tạo. Vui lòng gọi FirebaseSetup.initialize() trước.',
      );
      return;
    }

    final seedData = SeedData();
    await seedData.seedAll();

    print('✅ Seed data hoàn tất!');
    print('📊 Đã thêm:');
    print('   - Artists');
    print('   - Albums');
    print('   - Songs');
    print('   - Playlists');
    print('   - Genres');
    print('   - Concerts');
    print('   - Podcasts & Episodes');
  } catch (e) {
    print('❌ Lỗi khi seed data: $e');
    rethrow;
  }
}

/// Chỉ seed concerts và podcasts (nếu đã có artists)
Future<void> runSeedConcertsAndPodcasts() async {
  print('🌱 Bắt đầu seed concerts và podcasts...');

  try {
    if (!FirebaseSetup.isInitialized) {
      print('❌ Firebase chưa được khởi tạo.');
      return;
    }

    final seedData = SeedData();
    await seedData.seedConcerts();
    await seedData.seedPodcasts();

    print('✅ Đã seed concerts và podcasts!');
  } catch (e) {
    print('❌ Lỗi: $e');
    rethrow;
  }
}

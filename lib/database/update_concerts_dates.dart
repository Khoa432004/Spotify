import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';

/// Script để update dateTime của các concerts hiện có để đảm bảo chúng ở tương lai
/// 
/// Cách sử dụng:
/// ```dart
/// import 'database/update_concerts_dates.dart';
/// await updateConcertsDates();
/// ```
Future<void> updateConcertsDates() async {
  print('🔄 Đang update dates cho concerts...');
  
  try {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    
    // Lấy tất cả concerts
    final snapshot = await firestore
        .collection(FirestoreCollections.concerts)
        .get();
    
    print('📊 Found ${snapshot.docs.length} concerts');
    
    int updatedCount = 0;
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final currentDateTime = (data['dateTime'] as Timestamp?)?.toDate();
      
      if (currentDateTime == null) {
        print('⚠️ Skipping ${doc.id}: no dateTime');
        continue;
      }
      
      // Nếu dateTime ở quá khứ, update nó
      if (currentDateTime.isBefore(now)) {
        // Set dateTime thành 30 ngày từ bây giờ (mỗi concert cách nhau 1 ngày)
        final newDateTime = now.add(Duration(days: 30 + updatedCount));
        
        await doc.reference.update({
          'dateTime': Timestamp.fromDate(newDateTime),
        });
        
        print('   ✅ Updated ${data['title']}: ${currentDateTime} -> ${newDateTime}');
        updatedCount++;
      } else {
        print('   ✓ ${data['title']}: dateTime OK (${currentDateTime})');
      }
    }
    
    print('✅ Updated $updatedCount concerts');
  } catch (e) {
    print('❌ Error updating concerts dates: $e');
    rethrow;
  }
}


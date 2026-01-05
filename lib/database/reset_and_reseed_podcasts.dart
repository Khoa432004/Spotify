import 'firebase_setup.dart';
import 'constants.dart';
import 'seed_data.dart';

/// Script để xóa tất cả podcast data cũ và seed lại với tên mới
Future<void> resetAndReseedPodcasts() async {
  try {
    final firestore = FirebaseSetup.firestore;

    final episodesSnapshot = await firestore
        .collection(FirestoreCollections.podcastEpisodes)
        .get();

    for (var doc in episodesSnapshot.docs) {
      await doc.reference.delete();
    }

    final podcastsSnapshot = await firestore
        .collection(FirestoreCollections.podcasts)
        .get();

    for (var doc in podcastsSnapshot.docs) {
      await doc.reference.delete();
    }

    final seedData = SeedData();
    await seedData.seedPodcasts();
  } catch (e) {
    rethrow;
  }
}


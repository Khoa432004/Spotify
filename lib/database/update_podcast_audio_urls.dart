import 'firebase_setup.dart';
import 'constants.dart';

/// Script để update audio URLs của tất cả podcast episodes
/// Thay thế URLs giả (example.com) bằng URLs thật từ SoundHelix
Future<void> updatePodcastAudioUrls() async {
  try {
    final firestore = FirebaseSetup.firestore;

    const List<String> soundHelixUrls = [
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-17.mp3',
    ];

    final episodesSnapshot = await firestore
        .collection(FirestoreCollections.podcastEpisodes)
        .get();

    int updatedCount = 0;
    int index = 0;

    for (var doc in episodesSnapshot.docs) {
      final data = doc.data();
      final currentUrl = data['audioUrl'] as String? ?? '';

      if (currentUrl.contains('example.com') ||
          currentUrl.isEmpty ||
          !currentUrl.startsWith('http')) {
        final newUrl = soundHelixUrls[index % soundHelixUrls.length];

        await doc.reference.update({'audioUrl': newUrl});

        updatedCount++;
        index++;
      }
    }
  } catch (e) {
    rethrow;
  }
}

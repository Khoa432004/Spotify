// lib/database/custom_song_data.dart

/// Dữ liệu songs với URLs từ Firebase Storage
class CustomSongData {
  static Map<String, Map<String, dynamic>> get songs {
    return {
      'cong_ty_4': {
        'title': 'Công Ty 4',
        'artistName': 'Andree Right Hand',
        'audioUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FAndree%20Right%20Hand%20-%20C%C3%B4ng%20Ty%204%20ft.%20Dangrangto%2C%20TeuYungBoy%2C%20WOKEUP%20_%20Official%20MV%20%5BXGuPrOY8ieI%5D.mp3?alt=media&token=d8850084-2315-42dd-ba3c-e5c3ccc82e00',
        'albumName': 'Công Ty 4',
        'duration': 240, // 4 minutes
        'genre': 'Hip-Hop',
        'genres': ['Hip-Hop', 'Rap', 'V-Pop'],
      },
      
      'cho_mot_nguoi': {
        'title': 'Chờ Một Người',
        'artistName': 'Unknown Artist ft. Gill',
        'audioUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FCH%E1%BB%9C%20M%E1%BB%98T%20NG%C6%AF%E1%BB%9CI%20(Feat.%20Gill)%20%5BvTjA-C0bwDA%5D.mp3?alt=media&token=d0333085-c41f-46f7-b04e-f8f7a55b5986',
        'albumName': 'Chờ Một Người',
        'duration': 220, // ~3.5 minutes
        'genre': 'Pop',
        'genres': ['Pop', 'V-Pop', 'Ballad'],
      },
      
      'in_love': {
        'title': 'In Love',
        'artistName': 'Low G ft. JustaTee',
        'audioUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20In%20Love%20(ft.%20JustaTee)%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5BT7ksmtaVeOk%5D.mp3?alt=media&token=be58b4b1-3248-4530-b43b-091926d966d7',
        'albumName': 'L2K The Album',
        'duration': 200, // ~3.3 minutes
        'genre': 'R&B',
        'genres': ['R&B', 'Hip-Hop', 'V-Pop'],
      },
      
      'mua_he_nam_do': {
        'title': 'Mùa Hè Năm Đó',
        'artistName': 'The Underdogs',
        'audioUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FM%C3%B9a%20H%C3%A8%20N%C4%83m%20%C4%90%C3%B3%20-%20The%20Underdogs%20_%20Official%20MV%20%5BjpPa1-EOxcc%5D.mp3?alt=media&token=3b8dff32-1448-43d2-acc9-04c1a770da8d',
        'albumName': 'Mùa Hè Năm Đó',
        'duration': 210, // ~3.5 minutes
        'genre': 'Pop',
        'genres': ['Pop', 'V-Pop', 'Ballad'],
      },
      
      'tung_ngay_yeu_em': {
        'title': 'Từng Ngày Yêu Em',
        'artistName': 'buitruonglinh',
        'audioUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FT%E1%BB%ABng%20Ng%C3%A0y%20Y%C3%AAu%20Em%20_%20buitruonglinh%20%5Bf-VsoLm4i5c%5D.mp3?alt=media&token=5b522ff3-7a21-46b2-908c-b99e270cc7a9',
        'albumName': 'Từng Ngày Yêu Em',
        'duration': 230, // ~3.8 minutes
        'genre': 'Pop',
        'genres': ['Pop', 'V-Pop', 'Ballad'],
      },
    };
  }
}


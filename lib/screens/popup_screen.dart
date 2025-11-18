import 'package:flutter/material.dart';
import 'album_detail_screen.dart';

/// Màn hình Popup - Hiển thị sponsored recommendation modal
class PopupScreen extends StatelessWidget {
  const PopupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.85)),
          ),
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://www.figma.com/api/mcp/asset/a0c7082a-da66-4752-a015-b9c97a28b857',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black);
              },
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 143),
                // Logo
                Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1DB954),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://www.figma.com/api/mcp/asset/717b23be-01e1-46a3-97e4-0deab2dcd663',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: const Color(0xFF1DB954));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Card
                Container(
                  width: 315,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F232B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 33),
                      // Title
                      const Text(
                        'Brand new music for you!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 21),
                      // Album artwork
                      Container(
                        width: 224,
                        height: 227,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            'https://www.figma.com/api/mcp/asset/0eafff26-df86-49b2-a7b7-3f8156f18c88',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.grey[800]!);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Album name
                      const Text(
                        'THE LASERS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Artist name
                      Text(
                        'Gareth Emery',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Go to Album button
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AlbumDetailScreen(
                                albumName: 'THE LASERS',
                                artistName: 'Gareth Emery',
                                albumArt:
                                    'https://www.figma.com/api/mcp/asset/0eafff26-df86-49b2-a7b7-3f8156f18c88',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 194,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(58),
                          ),
                          child: const Center(
                            child: Text(
                              'GO TO ALBUM',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sponsored text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sponsored recommendation. ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Show info about sponsored recommendations
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF282828),
                                  title: const Text(
                                    'Sponsored Recommendations',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: Text(
                                    'Sponsored recommendations help us provide free access to Spotify.',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Color(0xFF1DB954),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              'What\'s this?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                const Spacer(),
                // Dismiss button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'DISMISS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.32,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

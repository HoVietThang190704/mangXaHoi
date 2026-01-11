import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostMediaViewer extends StatefulWidget {
  final List<String> images;
  final List<String> videos;
  final VoidCallback? onTap;

  const PostMediaViewer({
    super.key,
    required this.images,
    required this.videos,
    this.onTap,
  });

  @override
  State<PostMediaViewer> createState() => _PostMediaViewerState();
}

class _PostMediaViewerState extends State<PostMediaViewer> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PostMediaViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final total = _mediaItems(widget).length;
    if (_currentPage >= total && total > 0 && _pageController.hasClients) {
      _currentPage = total - 1;
      _pageController.jumpToPage(_currentPage);
    }
  }

  List<_MediaItem> _mediaItems(PostMediaViewer view) {
    final items = <_MediaItem>[];
    for (final url in view.images) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) {
        items.add(_MediaItem(url: trimmed, type: _MediaType.image));
      }
    }
    for (final url in view.videos) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) {
        items.add(_MediaItem(url: trimmed, type: _MediaType.video));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _mediaItems(widget);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final coreViewer = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: PageView.builder(
          controller: _pageController,
          itemCount: items.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final item = items[index];
            if (item.type == _MediaType.video) {
              return _PostVideoPlayer(url: item.url);
            }
            return _ImageSlide(url: item.url);
          },
        ),
      ),
    );

    final viewer = widget.onTap != null
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onTap,
            child: coreViewer,
          )
        : coreViewer;

    return Column(
      children: [
        viewer,
        if (items.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: isActive ? 18 : 6,
                  decoration: BoxDecoration(
                    color: isActive ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _ImageSlide extends StatelessWidget {
  final String url;

  const _ImageSlide({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.05),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stack) {
          return const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.white70));
        },
      ),
    );
  }
}

class _PostVideoPlayer extends StatefulWidget {
  final String url;

  const _PostVideoPlayer({required this.url});

  @override
  State<_PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<_PostVideoPlayer> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..setLooping(true)
      ..setVolume(0);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _initialized = true);
      _controller.play();
    }).catchError((error) {
      debugPrint('Video init failed: $error');
      if (!mounted) return;
      setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (!_initialized || _failed) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(
        color: Colors.black26,
        child: const Center(child: Icon(Icons.error_outline, color: Colors.white, size: 48)),
      );
    }

    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.volume_off, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('Muted', style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: AnimatedOpacity(
            opacity: _controller.value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: InkWell(
              onTap: _togglePlayback,
              customBorder: const CircleBorder(),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaItem {
  final String url;
  final _MediaType type;

  _MediaItem({required this.url, required this.type});
}

enum _MediaType { image, video }

import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class ProfilePhotosView extends StatelessWidget {
  final List<String> photoUrls;

  const ProfilePhotosView({super.key, required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.profile_section_photos)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: photoUrls.isEmpty
            ? Center(child: Text(loc.profile_photos_empty))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: photoUrls.length,
                itemBuilder: (context, index) {
                  final url = photoUrls[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _PhotoViewer(photoUrls: photoUrls, initialIndex: index),
                      ));
                    },
                    child: Hero(
                      tag: 'photo_$index',
                      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, fit: BoxFit.cover)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _PhotoViewer extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;

  const _PhotoViewer({required this.photoUrls, required this.initialIndex});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photoUrls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, index) {
          final url = widget.photoUrls[index];
          return Center(
            child: Hero(
              tag: 'photo_$index',
              child: InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}

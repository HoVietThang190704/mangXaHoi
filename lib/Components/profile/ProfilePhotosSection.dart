import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Views/Profile/ProfilePhotosView.dart';

class ProfilePhotosSection extends StatelessWidget {
  final List<String> photoUrls;
  final Color accentColor;
  final void Function(int index, String url)? onPhotoTap;

  const ProfilePhotosSection({super.key, required this.photoUrls, required this.accentColor, this.onPhotoTap});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(
              loc.profile_section_photos,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          if (photoUrls.isNotEmpty)
            TextButton(onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfilePhotosView(photoUrls: photoUrls)));
            }, child: Text(loc.profile_view_all, style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 12),
        photoUrls.isEmpty
            ? Text(loc.profile_photos_empty)
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: photoUrls.length,
                itemBuilder: (context, index) {
                  final url = photoUrls[index];
                  return InkWell(
                    onTap: () {
                      if (onPhotoTap != null) {
                        onPhotoTap!(index, url);
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfilePhotosView(photoUrls: photoUrls, initialIndex: index)));
                      }
                    },
                    child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, fit: BoxFit.cover)),
                  );
                },
              ),
      ]),
    );
  }
}

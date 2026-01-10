import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Components/profile/ProfileHighlightsSection.dart';

class ProfileFriendsSection extends StatelessWidget {
  final List<FriendPreview> friends;
  final Color accentColor;

  const ProfileFriendsSection({super.key, required this.friends, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(loc.profile_section_friends, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        friends.isEmpty
            ? Text(loc.profile_friends_empty)
            : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: friends.map((friend) {
                  return SizedBox(
                    width: 92,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: friend.photoUrl != null && friend.photoUrl!.isNotEmpty
                              ? Image.network(friend.photoUrl!, fit: BoxFit.cover)
                              : Container(color: accentColor.withOpacity(0.1), child: const Icon(Icons.person, size: 32)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(friend.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  );
                }).toList(),
              ),
      ]),
    );
  }
}

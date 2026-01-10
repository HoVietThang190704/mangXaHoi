import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/profile/ProfileTabs.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';
import 'package:mangxahoi/Components/profile/ProfileFriendsSection.dart';
import 'package:mangxahoi/Components/profile/ProfileHighlightsSection.dart';

class ProfileDetail {
  final IconData icon;
  final String text;

  const ProfileDetail({required this.icon, required this.text});
}

class ProfileHeaderSection extends StatelessWidget {
  final Color accentColor;
  final String displayName;
  final String initials;
  final String? avatarUrl;
  final String? coverUrl;
  final int? friendCount;
  final List<String> highlights;
  final List<ProfileDetail> introDetails;
  final List<FriendPreview> friends;
  final int activeIndex;
  final ValueChanged<int>? onTabChanged;
  final VoidCallback? onAvatarTap;
  final bool isUploadingAvatar;
  final Widget? actionArea;
  final bool showAvatarAction;

  const ProfileHeaderSection({
    super.key,
    required this.accentColor,
    required this.displayName,
    required this.initials,
    required this.avatarUrl,
    required this.coverUrl,
    required this.friendCount,
    required this.highlights,
    required this.introDetails,
    required this.friends,
    this.activeIndex = 0,
    this.onTabChanged,
    this.onAvatarTap,
    this.isUploadingAvatar = false,
    this.actionArea,
    this.showAvatarAction = true,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final friendLabel = friendCount != null
        ? loc.profile_friend_count(friendCount!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CoverSection(
          color: accentColor,
          coverUrl: coverUrl,
          avatarUrl: avatarUrl,
          initials: initials,
          onAvatarTap: onAvatarTap,
          isUploading: isUploadingAvatar,
          showCameraButton: showAvatarAction,
        ),
        const SizedBox(height: 16),
        _ProfileStats(
          color: accentColor,
          displayName: displayName,
          friendLabel: friendLabel,
          highlights: highlights,
        ),
        if (actionArea != null) ...[
          const SizedBox(height: 12),
          actionArea!,
        ],
        const SizedBox(height: 16),
        _ProfileIntroCard(details: introDetails),
        const SizedBox(height: 12),
        ProfileFriendsSection(friends: friends, accentColor: accentColor),
        const SizedBox(height: 16),
        ProfileTabs(
          tabs: [
            loc.profile_tab_posts,
            loc.profile_tab_photos,
            loc.profile_tab_reels,
          ],
          accentColor: accentColor,
          activeIndex: activeIndex,
          onChanged: onTabChanged,
        ),
      ],
    );
  }
}

class _ProfileIntroCard extends StatelessWidget {
  final List<ProfileDetail> details;

  const _ProfileIntroCard({required this.details});

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
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.profile_section_about,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (details.isEmpty)
            Text(loc.profile_about_empty)
          else
            Column(
              children: details
                  .map((detail) => _InfoTile(detail: detail))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final ProfileDetail detail;

  const _InfoTile({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(detail.icon, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              detail.text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverSection extends StatelessWidget {
  final Color color;
  final String? coverUrl;
  final String? avatarUrl;
  final String initials;
  final VoidCallback? onAvatarTap;
  final bool isUploading;
  final bool showCameraButton;

  const _CoverSection({
    required this.color,
    required this.coverUrl,
    required this.avatarUrl,
    required this.initials,
    this.onAvatarTap,
    this.isUploading = false,
    this.showCameraButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: coverUrl != null
                    ? DecorationImage(
                        image: NetworkImage(coverUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: coverUrl == null
                    ? LinearGradient(
                        colors: [
                          color.withOpacity(0.6),
                          color.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 24,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFE0E0E0),
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                ),
                if (showCameraButton)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _AvatarCameraButton(
                      color: color,
                      isUploading: isUploading,
                      onTap: onAvatarTap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarCameraButton extends StatelessWidget {
  final Color color;
  final bool isUploading;
  final VoidCallback? onTap;

  const _AvatarCameraButton({
    required this.color,
    required this.isUploading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = !isUploading && onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: canTap ? onTap : null,
      child: SizedBox(
        width: 44,
        height: 44,
        child: DecoratedBox(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: canTap ? color : color.withOpacity(0.6),
            child: isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final Color color;
  final String displayName;
  final String? friendLabel;
  final List<String> highlights;

  const _ProfileStats({
    required this.color,
    required this.displayName,
    required this.friendLabel,
    required this.highlights,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (friendLabel != null) ...[
          const SizedBox(height: 6),
          Text(
            friendLabel!,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
        if (highlights.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: highlights
                .map(
                  (chip) => Chip(
                    label: Text(chip),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black12),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

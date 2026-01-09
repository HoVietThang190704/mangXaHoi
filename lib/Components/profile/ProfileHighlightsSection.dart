import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class ProfileDetail {
	final IconData icon;
	final String text;

	const ProfileDetail({required this.icon, required this.text});
}

class FriendPreview {
	final String name;
	final String? photoUrl;

	const FriendPreview({required this.name, this.photoUrl});
}

class ProfileHighlightsSection extends StatelessWidget {
	final List<ProfileDetail> details;
	final List<String> photoUrls;
	final List<FriendPreview> friends;
	final Color accentColor;

	const ProfileHighlightsSection({
		super.key,
		required this.details,
		required this.photoUrls,
		required this.friends,
		required this.accentColor,
	});

	@override
	Widget build(BuildContext context) {
		final loc = AppLocalizations.of(context)!;
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_SectionCard(
					title: loc.profile_section_about,
					child: details.isEmpty
							? Text(loc.profile_about_empty)
							: Column(children: details.map((detail) => _InfoTile(detail: detail)).toList()),
				),
				const SizedBox(height: 20),
				_SectionCard(
					title: loc.profile_section_photos,
					actionText: photoUrls.isNotEmpty ? loc.profile_view_all : null,
					onAction: photoUrls.isNotEmpty ? () {} : null,
					child: photoUrls.isEmpty
							? Text(loc.profile_photos_empty)
							: GridView.builder(
								shrinkWrap: true,
								physics: const NeverScrollableScrollPhysics(),
								gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: 3,
									mainAxisSpacing: 8,
									crossAxisSpacing: 8,
								),
								itemCount: photoUrls.length,
								itemBuilder: (context, index) {
									final url = photoUrls[index];
									return ClipRRect(
										borderRadius: BorderRadius.circular(12),
										child: Image.network(url, fit: BoxFit.cover),
									);
								},
							),
				),
				const SizedBox(height: 20),
				_SectionCard(
					title: loc.profile_section_friends,
					child: friends.isEmpty
							? Text(loc.profile_friends_empty)
							: Wrap(
								spacing: 12,
								runSpacing: 12,
								children: friends
										.map((friend) => _FriendTile(friend: friend, accentColor: accentColor))
										.toList(),
							),
				),
				],
			);
	}
}

class _SectionCard extends StatelessWidget {
	final String title;
	final Widget child;
	final String? actionText;
	final VoidCallback? onAction;

	const _SectionCard({required this.title, required this.child, this.actionText, this.onAction});

	@override
	Widget build(BuildContext context) {
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
					Row(
						children: [
							Expanded(
								child: Text(
									title,
									style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
								),
							),
							if (actionText != null)
								TextButton(onPressed: onAction, child: Text(actionText!, style: const TextStyle(fontWeight: FontWeight.w600))),
						],
					),
					const SizedBox(height: 12),
					child,
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
							style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
						),
					),
				],
			),
		);
	}
}

class _FriendTile extends StatelessWidget {
	final FriendPreview friend;
	final Color accentColor;

	const _FriendTile({required this.friend, required this.accentColor});

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: 92,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Stack(
						children: [
							ClipRRect(
								borderRadius: BorderRadius.circular(16),
								child: AspectRatio(
									aspectRatio: 1,
									child: friend.photoUrl != null && friend.photoUrl!.isNotEmpty
											? Image.network(friend.photoUrl!, fit: BoxFit.cover)
											: Container(color: accentColor.withOpacity(0.1), child: const Icon(Icons.person, size: 32)),
								),
							),
							Positioned(
								bottom: 8,
								right: 8,
								child: CircleAvatar(
									radius: 12,
									backgroundColor: Colors.white,
									child: CircleAvatar(
										radius: 9,
										backgroundColor: accentColor,
										child: const Icon(Icons.person, size: 12, color: Colors.white),
									),
								),
							),
						],
					),
					const SizedBox(height: 8),
					Text(
						friend.name,
						style: const TextStyle(fontWeight: FontWeight.w600),
						maxLines: 2,
						overflow: TextOverflow.ellipsis,
					),
				],
			),
		);
	}
}

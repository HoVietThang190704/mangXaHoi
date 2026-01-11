import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class FriendPreview {
  final String? id;
	final String name;
	final String? photoUrl;

	const FriendPreview({this.id, required this.name, this.photoUrl});
}

class ProfileHighlightsSection extends StatelessWidget {
	final List<String> photoUrls;
	final List<FriendPreview> friends;
	final Color accentColor;
	final bool showPhotos;

	const ProfileHighlightsSection({
		super.key,
		required this.photoUrls,
		required this.friends,
		required this.accentColor,
		this.showPhotos = true,
	});

	@override
	Widget build(BuildContext context) {
		final loc = AppLocalizations.of(context)!;
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
			if (showPhotos)
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
				if (showPhotos) const SizedBox(height: 20),

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

class _FriendTile extends StatelessWidget {
	final FriendPreview friend;
	final Color accentColor;
	final ValueChanged<String?>? onTap;

	const _FriendTile({required this.friend, required this.accentColor, this.onTap});

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => onTap?.call(friend.id),
			child: SizedBox(
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
			),
		);
	}
}

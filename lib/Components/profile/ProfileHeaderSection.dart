import 'package:flutter/material.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

class ProfileHeaderSection extends StatelessWidget {
	final Color accentColor;
	final String displayName;
	final String initials;
	final String? avatarUrl;
	final String? coverUrl;
	final int? friendCount;
	final List<String> highlights;

	const ProfileHeaderSection({
		super.key,
		required this.accentColor,
		required this.displayName,
		required this.initials,
		required this.avatarUrl,
		required this.coverUrl,
		required this.friendCount,
		required this.highlights,
	});

	@override
	Widget build(BuildContext context) {
		final loc = AppLocalizations.of(context)!;
		final friendLabel = friendCount != null ? loc.profile_friend_count(friendCount!) : null;

		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				_CoverSection(
					color: accentColor,
					coverUrl: coverUrl,
					avatarUrl: avatarUrl,
					initials: initials,
					editCoverLabel: loc.profile_edit_cover,
				),
				const SizedBox(height: 16),
				_ProfileStats(
					color: accentColor,
					displayName: displayName,
					friendLabel: friendLabel,
					highlights: highlights,
				),
				const SizedBox(height: 16),
				_ActionButtonsRow(
					color: accentColor,
					addToStoryLabel: loc.profile_add_to_story,
					editProfileLabel: loc.profile_edit_profile,
				),
				const SizedBox(height: 16),
				_ProfileTabs(
					color: accentColor,
					tabs: [
						loc.profile_tab_posts,
						loc.profile_tab_photos,
						loc.profile_tab_reels,
					],
				),
			],
		);
	}
}

class _CoverSection extends StatelessWidget {
	final Color color;
	final String? coverUrl;
	final String? avatarUrl;
	final String initials;
  final String editCoverLabel;

	const _CoverSection({required this.color, required this.coverUrl, required this.avatarUrl, required this.initials, required this.editCoverLabel});

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Stack(
					clipBehavior: Clip.none,
					children: [
						Container(
							height: 200,
							decoration: BoxDecoration(
								borderRadius: BorderRadius.circular(20),
								image: coverUrl != null ? DecorationImage(image: NetworkImage(coverUrl!), fit: BoxFit.cover) : null,
								gradient: coverUrl == null
									? LinearGradient(
										colors: [color.withOpacity(0.6), color.withOpacity(0.2)],
										begin: Alignment.topLeft,
										end: Alignment.bottomRight,
									)
								: null,
							),
						),
						Positioned(
							bottom: -48,
							left: 24,
							child: Stack(
								children: [
									CircleAvatar(
										radius: 64,
										backgroundColor: Colors.white,
										child: CircleAvatar(
											radius: 60,
											backgroundColor: const Color(0xFFE0E0E0),
											backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
											child: avatarUrl == null
												? Text(
													initials,
													style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
												)
												: null,
										),
									),
									Positioned(
										bottom: 6,
										right: 6,
										child: CircleAvatar(
											radius: 16,
											backgroundColor: color,
											child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
										),
									),
							],
							),
						),
						Positioned(
							bottom: 16,
							right: 16,
							child: ElevatedButton.icon(
								onPressed: () {},
								icon: const Icon(Icons.camera_alt_outlined, size: 18),
								label: Text(editCoverLabel),
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.white,
									foregroundColor: Colors.black87,
									elevation: 2,
								),
							),
						),
					],
				),
				const SizedBox(height: 64),
			],
		);
	}
}

class _ProfileStats extends StatelessWidget {
	final Color color;
	final String displayName;
	final String? friendLabel;
	final List<String> highlights;

	const _ProfileStats({required this.color, required this.displayName, required this.friendLabel, required this.highlights});

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					displayName,
					style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
				),
				if (friendLabel != null) ...[
					const SizedBox(height: 6),
					Text(friendLabel!, style: const TextStyle(color: Colors.black54, fontSize: 16)),
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

class _ActionButtonsRow extends StatelessWidget {
	final Color color;
  final String addToStoryLabel;
  final String editProfileLabel;

	const _ActionButtonsRow({required this.color, required this.addToStoryLabel, required this.editProfileLabel});

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Expanded(
					child: ElevatedButton.icon(
						onPressed: () {},
						icon: const Icon(Icons.add_circle_outline),
						label: Text(addToStoryLabel),
						style: ElevatedButton.styleFrom(
							backgroundColor: color,
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
						),
					),
				),
				const SizedBox(width: 12),
				Expanded(
					child: OutlinedButton.icon(
						onPressed: () {},
						icon: const Icon(Icons.edit_outlined),
						label: Text(editProfileLabel),
						style: OutlinedButton.styleFrom(
							foregroundColor: Colors.black87,
							side: const BorderSide(color: Colors.black12),
							shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
						),
					),
				),
			],
		);
	}
}

class _ProfileTabs extends StatelessWidget {
	final Color color;
  final List<String> tabs;

	const _ProfileTabs({required this.color, required this.tabs});

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: Colors.black12),
			),
			child: Row(
				children: List.generate(tabs.length, (index) {
					final tab = tabs[index];
					final isActive = index == 0;
					return Expanded(
						child: Container(
							padding: const EdgeInsets.symmetric(vertical: 12),
							decoration: BoxDecoration(
								color: isActive ? color.withOpacity(0.08) : Colors.transparent,
								borderRadius: BorderRadius.circular(16),
							),
							child: Text(
								tab,
								textAlign: TextAlign.center,
								style: TextStyle(
									fontWeight: FontWeight.w600,
									color: isActive ? color : Colors.black87,
								),
							),
						),
					);
				}),
			),
		);
	}
}

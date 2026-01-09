import 'package:flutter/material.dart';
import 'package:mangxahoi/Components/PostCardComponent.dart';
import 'package:mangxahoi/Model/PostModel.dart';
import 'package:mangxahoi/l10n/app_localizations.dart';

typedef ProfileLikeCallback = Future<void> Function(PostModel post);

class ProfileFeedSection extends StatelessWidget {
	final List<PostModel> posts;
	final bool isLoading;
	final String? errorMessage;
	final Future<void> Function() onRetry;
	final ProfileLikeCallback onLike;

	const ProfileFeedSection({
		super.key,
		required this.posts,
		required this.isLoading,
		required this.errorMessage,
		required this.onRetry,
		required this.onLike,
	});

	@override
	Widget build(BuildContext context) {
		final loc = AppLocalizations.of(context)!;
		return Column(
			children: [
				if (isLoading)
					const Center(
						child: Padding(
							padding: EdgeInsets.symmetric(vertical: 32),
							child: CircularProgressIndicator(),
						),
					),
				if (errorMessage != null && !isLoading)
					ProfileErrorCard(message: errorMessage!, onRetry: onRetry),
				if (!isLoading && errorMessage == null && posts.isEmpty)
					Container(
						width: double.infinity,
						margin: const EdgeInsets.only(bottom: 16),
						padding: const EdgeInsets.all(16),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(16),
							border: Border.all(color: Colors.black12),
						),
						child: Text(loc.profile_feed_empty),
					),
				if (posts.isNotEmpty)
					...posts.map(
						(post) => Padding(
							padding: const EdgeInsets.only(bottom: 16),
							child: PostCardComponent(
								post: post,
								onLike: () => onLike(post),
							),
						),
					),
			],
		);
	}
}

class ProfileEmptyState extends StatelessWidget {
	final Future<void> Function() onRetry;

	const ProfileEmptyState({super.key, required this.onRetry});

	@override
	Widget build(BuildContext context) {
		final loc = AppLocalizations.of(context)!;
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.all(24),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: Colors.black12),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						loc.profile_login_required_title,
						style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
					),
					const SizedBox(height: 8),
					Text(loc.profile_login_required_body),
					const SizedBox(height: 12),
					FilledButton(
						onPressed: () => onRetry(),
						child: Text(loc.profile_retry),
					),
				],
			),
		);
	}
}

class ProfileErrorCard extends StatelessWidget {
	final String message;
	final Future<void> Function() onRetry;

	const ProfileErrorCard({super.key, required this.message, required this.onRetry});

	@override
	Widget build(BuildContext context) {
		final loc = AppLocalizations.of(context)!;
		return Container(
			width: double.infinity,
			margin: const EdgeInsets.only(bottom: 16),
			padding: const EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						loc.profile_error_title,
						style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w600),
					),
					const SizedBox(height: 8),
					Text(message),
					Align(
						alignment: Alignment.centerRight,
						child: TextButton(onPressed: () => onRetry(), child: Text(loc.profile_retry)),
					),
				],
			),
		);
	}
}

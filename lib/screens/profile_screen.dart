import 'package:flutter/material.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final AppData appData;
  final User targetUser;
  const ProfileScreen({
    required this.appData,
    required this.targetUser,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedRating = 0;
  final reviewController = TextEditingController();
  String? selectedTag;

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a rating',
            style: TextStyle(fontFamily: AppDesignTokens.fontFamily),
          ),
          backgroundColor: AppDesignTokens.destructive,
        ),
      );
      return;
    }
    if (reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please write a review',
            style: TextStyle(fontFamily: AppDesignTokens.fontFamily),
          ),
          backgroundColor: AppDesignTokens.destructive,
        ),
      );
      return;
    }
    await widget.appData.addReview(
      widget.appData.currentUser!.id,
      widget.targetUser.id,
      selectedRating,
      reviewController.text.trim(),
      selectedTag,
    );
    reviewController.clear();
    setState(() {
      selectedRating = 0;
      selectedTag = null;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Review submitted!',
          style: TextStyle(fontFamily: AppDesignTokens.fontFamily),
        ),
        backgroundColor: AppDesignTokens.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.appData.currentUser!;
    final reviews = widget.appData.getReviewsFor(widget.targetUser.id);
    final avgRating = widget.appData.averageRating(widget.targetUser.id);
    final isFollowing = widget.appData.isFollowing(
      current.id,
      widget.targetUser.id,
    );

    return Scaffold(
      backgroundColor: AppDesignTokens.background,
      appBar: AppBar(
        title: Text(
          widget.targetUser.name,
          style: const TextStyle(
            fontFamily: AppDesignTokens.fontFamily,
            color: Colors.black,
          ),
        ),
        backgroundColor: AppDesignTokens.primary,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppDesignTokens.primary.withOpacity(0.1),
              AppDesignTokens.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppDesignTokens.card,
                  // 16px border radius
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppDesignTokens.foreground.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppDesignTokens.getAvatarGradient(
                          widget.appData.users.indexOf(widget.targetUser),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          widget.targetUser.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontFamily: AppDesignTokens.fontFamily,
                            fontSize: 32,
                            fontWeight: AppDesignTokens.fontWeightMedium,
                            color: AppDesignTokens.primaryForeground,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.targetUser.name,
                      style: const TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        fontSize: 24,
                        fontWeight: AppDesignTokens.fontWeightMedium,
                        color: AppDesignTokens.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppDesignTokens.accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.appData.getUserTag(widget.targetUser.id),
                        style: const TextStyle(
                          fontFamily: AppDesignTokens.fontFamily,
                          fontSize: 14,
                          color: AppDesignTokens.accentForeground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Gold/Gray star rating display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < avgRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 28,
                            color: i < avgRating.round()
                                ? AppDesignTokens
                                      .starFilled // Gold #FBBF24
                                : AppDesignTokens.starEmpty, // Gray #E5E7EB
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${avgRating.toStringAsFixed(1)} (${reviews.length})',
                          style: const TextStyle(
                            fontFamily: AppDesignTokens.fontFamily,
                            fontSize: 18,
                            fontWeight: AppDesignTokens.fontWeightMedium,
                            color: AppDesignTokens.foreground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.targetUser.id != current.id)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (isFollowing) {
                              await widget.appData.unfollowUser(
                                current.id,
                                widget.targetUser.id,
                              );
                            } else {
                              await widget.appData.followUser(
                                current.id,
                                widget.targetUser.id,
                              );
                            }
                          },
                          icon: Icon(
                            isFollowing
                                ? Icons.person_remove
                                : Icons.person_add,
                          ),
                          label: Text(isFollowing ? 'Unfollow' : 'Follow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? AppDesignTokens.destructive
                                : AppDesignTokens.primary,
                            foregroundColor: isFollowing
                                ? AppDesignTokens.destructiveForeground
                                : AppDesignTokens.primaryForeground,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (widget.targetUser.id != current.id) ...[
                const Text(
                  'Write a Review',
                  style: TextStyle(
                    fontFamily: AppDesignTokens.fontFamily,
                    fontSize: 18,
                    fontWeight: AppDesignTokens.fontWeightMedium,
                    color: AppDesignTokens.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.card,
                    // 16px border radius
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppDesignTokens.foreground.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (i) => IconButton(
                            icon: Icon(
                              i < selectedRating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 36,
                              color: i < selectedRating
                                  ? AppDesignTokens
                                        .starFilled // Gold #FBBF24
                                  : AppDesignTokens.starEmpty, // Gray #E5E7EB
                            ),
                            onPressed: () =>
                                setState(() => selectedRating = i + 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppDesignTokens.inputBackground,
                          // 16px border radius
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: reviewController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontFamily: AppDesignTokens.fontFamily,
                            color: AppDesignTokens.foreground,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Share your experience...',
                            hintStyle: const TextStyle(
                              fontFamily: AppDesignTokens.fontFamily,
                              color: AppDesignTokens.mutedForeground,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppDesignTokens.ring,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppDesignTokens.inputBackground,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tag selector
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.targetUser.tags.map((tag) {
                          final isSelected = selectedTag == tag;
                          return ChoiceChip(
                            label: Text(
                              tag,
                              style: TextStyle(
                                fontFamily: AppDesignTokens.fontFamily,
                                fontSize: 13,
                                color: isSelected
                                    ? AppDesignTokens.primaryForeground
                                    : AppDesignTokens.foreground,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppDesignTokens.primary,
                            backgroundColor: AppDesignTokens.secondary,
                            onSelected: (selected) {
                              setState(() {
                                selectedTag = selected ? tag : null;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: submitReview,
                          child: const Text(
                            'Submit Review',
                            style: TextStyle(
                              fontFamily: AppDesignTokens.fontFamily,
                              fontWeight: AppDesignTokens.fontWeightMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                'Reviews (${reviews.length})',
                style: const TextStyle(
                  fontFamily: AppDesignTokens.fontFamily,
                  fontSize: 18,
                  fontWeight: AppDesignTokens.fontWeightMedium,
                  color: AppDesignTokens.foreground,
                ),
              ),
              const SizedBox(height: 12),
              if (reviews.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppDesignTokens.card,
                    // 16px border radius
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'No reviews yet.',
                      style: TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        color: AppDesignTokens.mutedForeground,
                      ),
                    ),
                  ),
                )
              else
                ...reviews.map((review) {
                  final reviewer = widget.appData.users.firstWhere(
                    (u) => u.id == review.submitterUserId,
                    orElse: () => User(
                      id: '',
                      name: 'Unknown',
                      email: '',
                      password: '',
                      tags: [],
                      following: [],
                      isAdmin: false,
                    ),
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppDesignTokens.card,
                      // 16px border radius
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppDesignTokens.foreground.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: AppDesignTokens.getAvatarGradient(
                                  widget.appData.users.indexOf(reviewer),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  reviewer.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: AppDesignTokens.fontFamily,
                                    fontSize: 14,
                                    fontWeight:
                                        AppDesignTokens.fontWeightMedium,
                                    color: AppDesignTokens.primaryForeground,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reviewer.name,
                                    style: const TextStyle(
                                      fontFamily: AppDesignTokens.fontFamily,
                                      fontWeight:
                                          AppDesignTokens.fontWeightMedium,
                                      color: AppDesignTokens.foreground,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      ...List.generate(
                                        5,
                                        (i) => Icon(
                                          i < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 12,
                                          color: i < review.rating
                                              ? AppDesignTokens
                                                    .starFilled // Gold #FBBF24
                                              : AppDesignTokens
                                                    .starEmpty, // Gray #E5E7EB
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (review.tag != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppDesignTokens.accent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  review.tag!,
                                  style: const TextStyle(
                                    fontFamily: AppDesignTokens.fontFamily,
                                    fontSize: 11,
                                    color: AppDesignTokens.accentForeground,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.comment,
                          style: const TextStyle(
                            fontFamily: AppDesignTokens.fontFamily,
                            color: AppDesignTokens.foreground,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

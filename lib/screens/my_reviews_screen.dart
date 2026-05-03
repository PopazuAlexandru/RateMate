import 'package:flutter/material.dart';
import '../main.dart';

// ============================================================================
// MY REVIEWS SCREEN - Rate Mate
// ============================================================================
// Shows reviews received by the current user (Anonymized)
// Uses Pacifico for header, Quicksand for text, 16px border radius
// ============================================================================

class MyReviewsScreen extends StatefulWidget {
  final AppData appData;
  const MyReviewsScreen({required this.appData, super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final current = widget.appData.currentUser!;
    // Logic Update: Only reviews where targetUserId matches currentUser.id
    final allReviews =
        widget.appData.reviews
            .where((r) => r.targetUserId == current.id)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      backgroundColor: AppDesignTokens.background,
      appBar: AppBar(
        title: const Text(
          'My Reviews',
          style: TextStyle(
            fontFamily: AppDesignTokens.handwritingFont, // Pacifico for header
            fontSize: 24,
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
              AppDesignTokens.primary.withOpacity(0.05),
              AppDesignTokens.background,
            ],
          ),
        ),
        child: allReviews.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 64,
                      color: AppDesignTokens.mutedForeground.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You haven\'t received any reviews yet.',
                      style: TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        fontSize: 16,
                        color: AppDesignTokens.mutedForeground,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: allReviews.length,
                itemBuilder: (context, index) {
                  final review = allReviews[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppDesignTokens.card,
                      // Wrap reviews in Cards with a 16px border radius
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppDesignTokens.foreground.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppDesignTokens.getAvatarGradient(
                                    index,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_outline,
                                    color: AppDesignTokens.primaryForeground,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Anonymity: Hardcode the reviewer name as 'Secret Admirer'
                                    const Text(
                                      'Secret Admirer',
                                      style: TextStyle(
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
                                            size: 14,
                                            color: i < review.rating
                                                ? AppDesignTokens.starFilled
                                                : AppDesignTokens.starEmpty,
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
                          const SizedBox(height: 12),
                          // Use Quicksand for the review text
                          Text(
                            review.comment,
                            style: const TextStyle(
                              fontFamily: AppDesignTokens.fontFamily,
                              color: AppDesignTokens.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(review.timestamp),
                            style: const TextStyle(
                              fontFamily: AppDesignTokens.fontFamily,
                              fontSize: 12,
                              color: AppDesignTokens.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import '../main.dart';
import 'profile_screen.dart';
import 'my_reviews_screen.dart';

// ============================================================================
// HOME SCREEN - Rate Mate
// ============================================================================
// User listing and search with Quicksand font, 16px border radius,
// and Gold/Gray star colors for ratings
// ============================================================================

class HomeScreen extends StatefulWidget {
  final AppData appData;
  const HomeScreen({required this.appData, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String query = '';
  double? minRating;
  double? maxRating;
  List<String> selectedTags = [];
  bool followingOnly = false;
  bool showFilters = false;


  void _toggleFilters() {
    setState(() {
      showFilters = !showFilters;
    });
  }

  List<String> _getAllTags() {
    final allTags = <String>{};
    for (final user in widget.appData.users) {
      allTags.addAll(user.tags);
    }
    return allTags.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.appData.currentUser!;
    final candidates = widget.appData.searchUsers(
      query,
      minRating: minRating,
      maxRating: maxRating,
      tags: selectedTags.isNotEmpty ? selectedTags : null,
      followingOnly: followingOnly,
    );

    return Scaffold(
      backgroundColor: AppDesignTokens.background,
      appBar: AppBar(
        title: const Text(
          'RateMate',
          style: TextStyle(
            fontFamily: AppDesignTokens.handwritingFont,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: AppDesignTokens.primary,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            tooltip: 'Advanced Filters',
            onPressed: _toggleFilters,
          ),
          IconButton(
            icon: const Icon(
              Icons.reviews,
              color: AppDesignTokens.primaryForeground,
            ),
            tooltip: 'My Reviews',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyReviewsScreen(appData: widget.appData),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: AppDesignTokens.primaryForeground,
            ),
            tooltip: 'Logout',
            onPressed: () {
              widget.appData.logout();
            },
          ),
        ],
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppDesignTokens.primary,
                      AppDesignTokens.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  // 16px border radius
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppDesignTokens.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        fontSize: 14,
                        color: AppDesignTokens.primaryForeground.withOpacity(
                          0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      current.name,
                      style: const TextStyle(
                        fontFamily: AppDesignTokens.fontFamily,
                        fontSize: 24,
                        fontWeight: AppDesignTokens.fontWeightMedium,
                        color: AppDesignTokens.primaryForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppDesignTokens.starFilled,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.appData.getReviewsFor(current.id).length} reviews received',
                          style: TextStyle(
                            fontFamily: AppDesignTokens.fontFamily,
                            fontSize: 13,
                            color: AppDesignTokens.primaryForeground
                                .withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.people,
                          color: AppDesignTokens.primaryForeground.withOpacity(
                            0.8,
                          ),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${current.following.length} following',
                          style: TextStyle(
                            fontFamily: AppDesignTokens.fontFamily,
                            fontSize: 13,
                            color: AppDesignTokens.primaryForeground
                                .withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Search Field
              Container(
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
                child: TextField(
                  onChanged: (value) => setState(() => query = value),
                  style: const TextStyle(
                    fontFamily: AppDesignTokens.fontFamily,
                    color: AppDesignTokens.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: const TextStyle(
                      fontFamily: AppDesignTokens.fontFamily,
                      color: AppDesignTokens.mutedForeground,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppDesignTokens.mutedForeground,
                    ),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppDesignTokens.mutedForeground,
                            ),
                            onPressed: () => setState(() => query = ''),
                          )
                        : null,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Filters
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: showFilters
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
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
                      const Text(
                        'Advanced Filters',
                        style: TextStyle(
                          fontFamily: AppDesignTokens.fontFamily,
                          fontWeight: AppDesignTokens.fontWeightMedium,
                          fontSize: 16,
                          color: AppDesignTokens.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_half,
                            color: AppDesignTokens.starFilled,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Rating: ',
                            style: TextStyle(
                              fontFamily: AppDesignTokens.fontFamily,
                              color: AppDesignTokens.mutedForeground,
                            ),
                          ),
                          Expanded(
                            child: RangeSlider(
                              values: RangeValues(
                                minRating ?? 0,
                                maxRating ?? 5,
                              ),
                              min: 0,
                              max: 5,
                              divisions: 10,
                              activeColor: AppDesignTokens.primary,
                              inactiveColor: AppDesignTokens.starEmpty,
                              labels: RangeLabels(
                                (minRating ?? 0).toStringAsFixed(1),
                                (maxRating ?? 5).toStringAsFixed(1),
                              ),
                              onChanged: (values) {
                                setState(() {
                                  minRating = values.start == 0
                                      ? null
                                      : values.start;
                                  maxRating = values.end == 5
                                      ? null
                                      : values.end;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getAllTags().map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          return FilterChip(
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
                                if (selected) {
                                  selectedTags.add(tag);
                                } else {
                                  selectedTags.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Following only: ',
                            style: TextStyle(
                              fontFamily: AppDesignTokens.fontFamily,
                              color: AppDesignTokens.mutedForeground,
                            ),
                          ),
                          Switch(
                            value: followingOnly,
                            activeColor: AppDesignTokens.primary,
                            onChanged: (value) =>
                                setState(() => followingOnly = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Find friends to review',
                style: TextStyle(
                  fontFamily: AppDesignTokens.fontFamily,
                  fontSize: 18,
                  fontWeight: AppDesignTokens.fontWeightMedium,
                  color: AppDesignTokens.foreground,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: candidates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppDesignTokens.mutedForeground
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No users found.',
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
                        itemCount: candidates.length,
                        itemBuilder: (context, index) {
                          final user = candidates[index];
                          final avgRating = widget.appData.averageRating(
                            user.id,
                          );
                          final tag = widget.appData.getUserTag(user.id);
                          final isFollowing = widget.appData.isFollowing(
                            current.id,
                            user.id,
                          );

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppDesignTokens.card,
                                // 16px border radius
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppDesignTokens.foreground
                                        .withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: AppDesignTokens.getAvatarGradient(
                                      index,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: AppDesignTokens.fontFamily,
                                        fontSize: 20,
                                        fontWeight:
                                            AppDesignTokens.fontWeightMedium,
                                        color:
                                            AppDesignTokens.primaryForeground,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontFamily: AppDesignTokens.fontFamily,
                                    fontWeight:
                                        AppDesignTokens.fontWeightMedium,
                                    fontSize: 16,
                                    color: AppDesignTokens.foreground,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    // Gold/Gray star colors for ratings
                                    Row(
                                      children: [
                                        ...List.generate(
                                          5,
                                          (i) => Icon(
                                            i < avgRating.round()
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 14,
                                            color: i < avgRating.round()
                                                ? AppDesignTokens
                                                      .starFilled // Gold #FBBF24
                                                : AppDesignTokens
                                                      .starEmpty, // Gray #E5E7EB
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          avgRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontFamily:
                                                AppDesignTokens.fontFamily,
                                            fontSize: 12,
                                            color:
                                                AppDesignTokens.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
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
                                        tag,
                                        style: const TextStyle(
                                          fontFamily:
                                              AppDesignTokens.fontFamily,
                                          fontSize: 11,
                                          color:
                                              AppDesignTokens.accentForeground,
                                        ),
                                      ),
                                    ),
                                    if (user.tags.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tags: ${user.tags.join(", ")}',
                                        style: const TextStyle(
                                          fontFamily:
                                              AppDesignTokens.fontFamily,
                                          fontSize: 11,
                                          color:
                                              AppDesignTokens.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isFollowing
                                            ? Icons.person_remove
                                            : Icons.person_add,
                                        color: isFollowing
                                            ? AppDesignTokens.destructive
                                            : AppDesignTokens.primary,
                                      ),
                                      onPressed: () async {
                                        if (isFollowing) {
                                          await widget.appData.unfollowUser(
                                            current.id,
                                            user.id,
                                          );
                                        } else {
                                          await widget.appData.followUser(
                                            current.id,
                                            user.id,
                                          );
                                        }
                                      },
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppDesignTokens.mutedForeground,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(
                                        appData: widget.appData,
                                        targetUser: user,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

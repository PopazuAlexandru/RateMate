import 'package:flutter/material.dart';
import '../main.dart';

// ============================================================================
// ADMIN SCREEN - Rate Mate
// ============================================================================
// Admin panel for user moderation and review oversight
// Uses Quicksand font, 16px border radius
// ============================================================================

class AdminPanelScreen extends StatefulWidget {
  final AppData appData;
  const AdminPanelScreen({required this.appData, super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.appData.currentUser!;
    if (!current.isAdmin) {
      return Scaffold(
        backgroundColor: AppDesignTokens.background,
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: AppDesignTokens.primary,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const Center(child: Text('Access denied. Admin only.')),
      );
    }

    return Scaffold(
      backgroundColor: AppDesignTokens.background,
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(
            fontFamily: AppDesignTokens.fontFamily,
            color: Colors.black,
          ),
        ),
        backgroundColor: AppDesignTokens.primary,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppDesignTokens.primaryForeground,
          labelStyle: const TextStyle(
            fontFamily: AppDesignTokens.fontFamily,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Moderation', icon: Icon(Icons.gavel)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUsersTab(), _buildModerationTab()],
      ),
    );
  }

  Widget _buildUsersTab() {
    final filteredUsers = widget.appData.users
        .where(
          (u) =>
              u.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              u.email.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppDesignTokens.primary,
                      child: Text(
                        user.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Switch(
                      value: user.isBlocked,
                      activeColor: AppDesignTokens.destructive,
                      onChanged: (value) =>
                          widget.appData.blockUser(user.id, value),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationTab() {
    final allReviews = widget.appData.reviews;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allReviews.length,
      itemBuilder: (context, index) {
        final review = allReviews[index];
        final targetUser = widget.appData.users.firstWhere(
          (u) => u.id == review.targetUserId,
          orElse: () => User(id: '', name: 'Unknown', email: '', password: ''),
        );
        final submitter = widget.appData.users.firstWhere(
          (u) => u.id == review.submitterUserId,
          orElse: () =>
              User(id: '', name: 'Deleted User', email: '', password: ''),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To: ${targetUser.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: AppDesignTokens.fontFamily,
                            ),
                          ),
                          // Admin Oversight: Full details including submitterUserId
                          Text(
                            'From: ${submitter.name} (${review.submitterUserId ?? "Anonymous"})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppDesignTokens.mutedForeground,
                              fontFamily: AppDesignTokens.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 16,
                          color: AppDesignTokens.starFilled,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontFamily: AppDesignTokens.fontFamily,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Admin Actions: Block User
                    TextButton.icon(
                      onPressed: () => widget.appData.blockUser(
                        submitter.id,
                        !submitter.isBlocked,
                      ),
                      icon: Icon(
                        submitter.isBlocked ? Icons.check_circle : Icons.block,
                        color: AppDesignTokens.destructive,
                      ),
                      label: Text(
                        submitter.isBlocked ? 'Unblock' : 'Block Submitter',
                        style: const TextStyle(
                          color: AppDesignTokens.destructive,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Admin Actions: Delete Review
                    ElevatedButton.icon(
                      onPressed: () => widget.appData.deleteReview(review.id),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete Review'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppDesignTokens.destructive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

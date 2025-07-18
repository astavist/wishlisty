import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wish_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/home/friend_activity_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final wishProvider = Provider.of<WishProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final currentUser = authProvider.currentUser!;
      
      // Reload user relationships
      await userProvider.loadUserRelationships(currentUser);
      
      // Reload friends' wishes with updated friend list
      wishProvider.loadFriendsWishes(userProvider.getFriendIds());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'WishLink',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Navigate to notifications
                        // This will be handled by the bottom navigation
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (userProvider.unreadNotificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${userProvider.unreadNotificationCount > 9 ? '9+' : userProvider.unreadNotificationCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer3<AuthProvider, WishProvider, UserProvider>(
        builder: (context, authProvider, wishProvider, userProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final currentUser = authProvider.currentUser!;
          final friendsWishes = wishProvider.friendsWishes;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Welcome header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${currentUser.displayName.split(' ').first}! 👋',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'See what your friends are wishing for',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Friend Activity section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          'Friend Activity',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (userProvider.friends.isEmpty)
                          TextButton(
                            onPressed: () {
                              // Navigate to friends screen to add friends
                              // This will be handled by the bottom navigation
                            },
                            child: Text(
                              'Add Friends',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Friend Activity List
                if (userProvider.friends.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Friends Yet',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add friends to see their wishlists and discover gift ideas!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Find Friends',
                            onPressed: () {
                              // Navigate to friends screen
                            },
                            width: 140,
                            height: 44,
                          ),
                        ],
                      ),
                    ),
                  )
                else if (friendsWishes.isEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 64,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Activity Yet',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your friends haven\'t shared any wishes yet. Be the first to create a wishlist!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Create Wish',
                            onPressed: () {
                              AppRoutes.pushNamed(context, AppRoutes.addWish);
                            },
                            width: 140,
                            height: 44,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final wish = friendsWishes[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 24,
                            right: 24,
                            bottom: index == friendsWishes.length - 1 ? 100 : 16,
                          ),
                          child: FriendActivityCard(
                            wish: wish,
                            currentUserId: currentUser.id,
                          ),
                        );
                      },
                      childCount: friendsWishes.length,
                    ),
                  ),

                // Bottom spacing for FAB
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.pushNamed(context, AppRoutes.addWish);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
} 
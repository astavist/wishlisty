import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/wish_model.dart';
import '../../models/user_model.dart';
import '../../providers/wish_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';

class FriendActivityCard extends StatefulWidget {
  final WishModel wish;
  final String currentUserId;

  const FriendActivityCard({
    super.key,
    required this.wish,
    required this.currentUserId,
  });

  @override
  State<FriendActivityCard> createState() => _FriendActivityCardState();
}

class _FriendActivityCardState extends State<FriendActivityCard> {
  UserModel? _wishOwner;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWishOwner();
  }

  void _loadWishOwner() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final owner = await userProvider.getUser(widget.wish.userId);
    if (mounted) {
      setState(() {
        _wishOwner = owner;
      });
    }
  }

  void _handleLike() async {
    setState(() {
      _isLoading = true;
    });

    final wishProvider = Provider.of<WishProvider>(context, listen: false);
    await wishProvider.toggleWishLike(widget.wish.id, widget.currentUserId);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handlePin() async {
    if (widget.wish.userId == widget.currentUserId) return; // Can't pin own wishes

    setState(() {
      _isLoading = true;
    });

    final wishProvider = Provider.of<WishProvider>(context, listen: false);
    await wishProvider.toggleWishPin(widget.wish.id, widget.currentUserId);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show feedback to user
      final isPinned = widget.wish.isPinnedBy(widget.currentUserId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPinned ? 'Removed from your saved gifts' : 'Saved to your gift ideas',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: isPinned ? AppColors.textGray : AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleBuyNow() async {
    if (widget.wish.productUrl != null && widget.wish.productUrl!.isNotEmpty) {
      final Uri url = Uri.parse(widget.wish.productUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open product link'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _navigateToWishDetail() {
    final wishProvider = Provider.of<WishProvider>(context, listen: false);
    wishProvider.setSelectedWish(widget.wish);
    AppRoutes.pushNamed(context, AppRoutes.wishDetail);
  }

  String _formatPrice(double? price, String? currency) {
    if (price == null) return '';
    return '${currency ?? 'USD'} ${price.toStringAsFixed(2)}';
  }

  String _getTimeSinceCreated() {
    final now = DateTime.now();
    final difference = now.difference(widget.wish.createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.wish.likes.contains(widget.currentUserId);
    final isPinned = widget.wish.isPinnedBy(widget.currentUserId);
    final canPin = widget.wish.userId != widget.currentUserId;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: _wishOwner?.photoURL != null
                      ? CachedNetworkImageProvider(_wishOwner!.photoURL!)
                      : null,
                  child: _wishOwner?.photoURL == null
                      ? Text(
                          _wishOwner?.displayName.isNotEmpty == true
                              ? _wishOwner!.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _wishOwner?.displayName ?? 'Loading...',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Just added this amazing ${widget.wish.category.toLowerCase()} to their wishlist',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _getTimeSinceCreated(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          // Wish Image
          GestureDetector(
            onTap: _navigateToWishDetail,
            child: Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surfaceVariant,
              ),
              child: widget.wish.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: widget.wish.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppColors.textLight,
                            size: 48,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: AppColors.textLight,
                        size: 48,
                      ),
                    ),
            ),
          ),

          // Wish Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.wish.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.wish.price != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatPrice(widget.wish.price, widget.wish.currency),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (widget.wish.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.wish.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Like button
                InkWell(
                  onTap: _isLoading ? null : _handleLike,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? AppColors.error : AppColors.textGray,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.wish.likeCount}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Comment button
                InkWell(
                  onTap: _navigateToWishDetail,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.textGray,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.wish.commentCount}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pin button (only for other users' wishes)
                if (canPin)
                  InkWell(
                    onTap: _isLoading ? null : _handlePin,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Icon(
                        isPinned ? Icons.bookmark : Icons.bookmark_border,
                        color: isPinned ? AppColors.accent : AppColors.textGray,
                        size: 20,
                      ),
                    ),
                  ),

                const Spacer(),

                // Buy Now button
                if (widget.wish.productUrl != null && widget.wish.productUrl!.isNotEmpty)
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ElevatedButton(
                      onPressed: _handleBuyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'Buy Now',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        'Visit Store',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
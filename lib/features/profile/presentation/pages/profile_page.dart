import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appmanga/core/theme/app_colors.dart';
import 'package:appmanga/core/utils/format_helper.dart';
import 'package:appmanga/features/profile/domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật hồ sơ thành công'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.red,
              ),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red),
                    onPressed: () => context
                        .read<ProfileBloc>()
                        .add(ProfileLoadRequested(userId)),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          if (state is ProfileLoaded) {
            return _ProfileContent(profile: state.profile, state: state);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final ProfileEntity profile;
  final ProfileLoaded state;
  const _ProfileContent({required this.profile, required this.state});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent>
    with SingleTickerProviderStateMixin {
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
    final profile = widget.profile;
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // Header gradient
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.red, Color(0xFF6C3483)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),

        // Avatar + info + stats + buttons
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildAvatarSection(context, profile),
              const SizedBox(height: 16),
              _buildStats(context, profile),
              const SizedBox(height: 16),
              _buildActionButtons(context, widget.state),
              const SizedBox(height: 8),
            ],
          ),
        ),

        // Tab bar (chỉ khi creator)
        if (profile.role == 'creator' || profile.role == 'admin')
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.red,
                labelColor: AppColors.red,
                unselectedLabelColor: AppColors.darkText3,
                tabs: const [
                  Tab(text: 'Truyện đã đăng'),
                  Tab(text: 'Trạng thái'),
                ],
              ),
            ),
          ),
      ],
      body: (profile.role == 'creator' || profile.role == 'admin')
          ? TabBarView(
        controller: _tabController,
        children: [
          _MangaGridTab(userId: profile.id),
          _StatusTab(userId: profile.id),
        ],
      )
          : const Center(
        child: Text(
          'Chưa có hoạt động nào',
          style: TextStyle(color: AppColors.darkText3),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, ProfileEntity profile) {
    return Transform.translate(
      offset: const Offset(0, -36),
      child: Column(
        children: [
          GestureDetector(
            onTap: profile.isOwnProfile
                ? () => _pickAvatar(context)
                : null,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.darkBg3,
                  backgroundImage: profile.avatarUrl != null
                      ? CachedNetworkImageProvider(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? const Icon(Icons.person,
                      size: 48, color: AppColors.darkText3)
                      : null,
                ),
                if (profile.isOwnProfile)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 13, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.username,
            style: GoogleFonts.bebasNeue(
              fontSize: 24,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            children: [
              if (profile.role == 'creator')
                _badge('CREATOR', AppColors.red),
              if (profile.role == 'admin')
                _badge('ADMIN', const Color(0xFF6C3483)),
              if (profile.isPremium) _premiumBadge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Tham gia ${FormatHelper.timeAgo(profile.createdAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkText3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _premiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AC0D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 11, color: Colors.white),
          SizedBox(width: 3),
          Text('PREMIUM',
              style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, ProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkBg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            _StatColumn(
              value: profile.role == 'creator'
                  ? '${profile.mangaCount ?? 0}'
                  : FormatHelper.compactNumber(profile.pointBalance),
              label: profile.role == 'creator' ? 'Truyện' : 'Điểm',
            ),
            Container(width: 1, height: 36, color: Colors.white.withOpacity(0.07)),
            GestureDetector(
              onTap: () => context.push('/profile/${profile.id}/followers'),
              child: _StatColumn(
                value: FormatHelper.compactNumber(profile.followerCount),
                label: 'Người theo dõi',
              ),
            ),
            Container(width: 1, height: 36, color: Colors.white.withOpacity(0.07)),
            GestureDetector(
              onTap: () => context.push('/profile/${profile.id}/following'),
              child: _StatColumn(
                value: FormatHelper.compactNumber(profile.followingCount),
                label: 'Đang theo dõi',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ProfileLoaded state) {
    final profile = state.profile;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: profile.isOwnProfile
          ? Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showEditSheet(context, profile),
              icon: const Icon(Icons.edit, size: 15),
              label: const Text('Chỉnh sửa hồ sơ',
                  style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.red),
                foregroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => context.push('/settings'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
              foregroundColor: AppColors.darkText3,
              padding: const EdgeInsets.all(10),
            ),
            child: const Icon(Icons.settings, size: 20),
          ),
        ],
      )
          : SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: state.isFollowLoading
              ? null
              : () => context
              .read<ProfileBloc>()
              .add(ProfileFollowToggled()),
          icon: Icon(
            profile.isFollowed
                ? Icons.person_remove
                : Icons.person_add,
            size: 16,
          ),
          label: state.isFollowLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            profile.isFollowed ? 'Đang follow' : 'Follow',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: profile.isFollowed
                ? AppColors.red
                : AppColors.darkBg3,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  // ── Avatar picker ──────────────────────────────────
  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      imageQuality: 85,
    );
    if (file == null || !context.mounted) return;

    // TODO: upload file lên R2 rồi lấy URL
    // Tạm thời dùng path local để demo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang upload ảnh...')),
    );
  }

  // ── Edit profile bottom sheet ──────────────────────
  void _showEditSheet(BuildContext context, ProfileEntity profile) {
    final usernameCtrl =
    TextEditingController(text: profile.username);
    final bloc = context.read<ProfileBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkBg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkText3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chỉnh sửa hồ sơ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 20),
                // Username field
                TextField(
                  controller: usernameCtrl,
                  style: const TextStyle(color: AppColors.darkText),
                  decoration: InputDecoration(
                    labelText: 'Tên hiển thị',
                    labelStyle:
                    const TextStyle(color: AppColors.darkText3),
                    hintText: 'Chỉ a-z, 0-9, dấu gạch dưới',
                    hintStyle:
                    const TextStyle(color: AppColors.darkText3),
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppColors.darkText3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: AppColors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Nút lưu
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (ctx, state) {
                    final isLoading = state is ProfileLoaded &&
                        state.isUpdateLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          padding:
                          const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                          final newUsername =
                          usernameCtrl.text.trim();
                          if (newUsername.isEmpty) return;
                          context.read<ProfileBloc>().add(
                            ProfileUpdateRequested(
                              username: newUsername,
                            ),
                          );
                          Navigator.pop(sheetContext);
                        },
                        child: isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Tab: Manga Grid ────────────────────────────────────
class _MangaGridTab extends StatelessWidget {
  final String userId;
  const _MangaGridTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    // TODO: kết nối API GET /api/users/:id/manga
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined,
              size: 56, color: AppColors.darkText3),
          SizedBox(height: 12),
          Text('Chưa có truyện nào',
              style: TextStyle(color: AppColors.darkText3, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Tab: Status Posts ──────────────────────────────────
class _StatusTab extends StatelessWidget {
  final String userId;
  const _StatusTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    // TODO: kết nối API GET /api/users/:id/status
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dynamic_feed_outlined,
              size: 56, color: AppColors.darkText3),
          SizedBox(height: 12),
          Text('Chưa có trạng thái nào',
              style: TextStyle(color: AppColors.darkText3, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Sticky TabBar delegate ─────────────────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) => false;
}

// ── Stat Column ────────────────────────────────────────
class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.darkText3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
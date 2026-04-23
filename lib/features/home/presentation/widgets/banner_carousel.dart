import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:appmanga/core/theme/app_colors.dart';
import 'package:appmanga/core/utils/format_helper.dart';
import 'package:appmanga/features/manga/domain/entities/manga_entity.dart';

class BannerCarousel extends StatefulWidget {
  final List<MangaEntity> banners;

  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox();

    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.banners.length,
        itemBuilder: (context, index) {
          final banner = widget.banners[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildBannerCard(banner),
          );
        },
      ),
    );
  }

  Widget _buildBannerCard(MangaEntity banner) {
    final String imageUrl = (banner.coverUrl != null && banner.coverUrl!.isNotEmpty) 
        ? banner.coverUrl! 
        : 'https://via.placeholder.com/300x160.png?text=MangaX';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceVariant,
              highlightColor: Theme.of(context).colorScheme.surface,
              child: Container(color: Colors.white),
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Icon(Icons.broken_image, color: Colors.white, size: 40),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (banner.badgeType != null) _buildBadge(banner.badgeType!),
                const SizedBox(height: 6),
                Text(
                  banner.title,
                  style: GoogleFonts.bebasNeue(
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Chapter ${banner.latestChapter ?? 0} • ${FormatHelper.compactNumber(banner.viewCount)} lượt xem',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String type) {
    Color color;
    String text;
    switch (type.toLowerCase()) {
      case 'new': color = const Color(0xFF1A7FE8); text = 'MỚI'; break;
      case 'trending': color = const Color(0xFFD4530E); text = 'TRENDING'; break;
      case 'hot':
      default: color = AppColors.red; text = 'HOT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}

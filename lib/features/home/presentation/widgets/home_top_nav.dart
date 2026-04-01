import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class HomeTopNav extends StatelessWidget {
  const HomeTopNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              children: const [
                TextSpan(text: 'MANGA'),
                TextSpan(
                  text: 'X',
                  style: TextStyle(color: AppColors.red),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildIconButton(context, Icons.search, () {}),
          const SizedBox(width: 12),
          _buildNotificationButton(context),
          const SizedBox(width: 12),
          _buildAvatarButton(context),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      children: [
        _buildIconButton(context, Icons.notifications_none, () {}),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarButton(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
    );
  }
}

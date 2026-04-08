import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/explore_bloc.dart';
import '../bloc/explore_event.dart';
import '../bloc/explore_state.dart';
import '../widgets/explore_banner_widget.dart';
import '../widgets/explore_category_grid.dart';
import '../widgets/explore_featured_list.dart';
import 'package:google_fonts/google_fonts.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExploreBloc>()..add(ExploreLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              _buildTabItem(context, 'Forum', true),
              const SizedBox(width: 20),
              _buildTabItem(context, 'Trò chơi', false),
              const SizedBox(width: 20),
              _buildTabItem(context, 'Truyện Ngắn', false),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.mail_outline)),
          ],
        ),
        body: BlocBuilder<ExploreBloc, ExploreState>(
          builder: (context, state) {
            if (state is ExploreLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExploreError) {
              return Center(child: Text(state.message));
            }
            if (state is ExploreLoaded) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ExploreBannerWidget(banners: state.data.banners),
                    const SizedBox(height: 24),
                    ExploreCategoryGrid(categories: state.data.categories),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Truyện nổi bật',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExploreFeaturedList(mangas: state.data.featuredMangas),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String title, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isActive 
              ? Theme.of(context).colorScheme.onSurface 
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 15,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

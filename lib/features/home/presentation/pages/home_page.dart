import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/format_helper.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/genre_chip_list.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_skeleton_widget.dart';
import '../widgets/home_top_nav.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/manga_horizontal_list.dart';
import '../widgets/rank_item.dart';
import '../widgets/section_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(HomeLoadRequested()),
      child: Scaffold(
        bottomNavigationBar: MainBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeInitial || state is HomeLoading) {
                return const HomeSkeletonWidget();
              }

              if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<HomeBloc>().add(HomeLoadRequested()),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (state is HomeLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(HomeRefreshRequested());
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeTopNav(),
                        const HomeSearchBar(),
                        const SizedBox(height: 16),
                        const GenreChipList(),
                        const SizedBox(height: 20),
                        
                        // Banner Section
                        BannerCarousel(banners: state.data.banners),
                        
                        const SizedBox(height: 24),
                        
                        // Recently Updated
                        SectionHeader(title: 'MỚI CẬP NHẬT', onSeeAllTap: () {}),
                        const SizedBox(height: 12),
                        MangaHorizontalList(
                          mangas: state.data.recentlyUpdated,
                          subtitleBuilder: (m) => 'Ch.${m.latestChapter} • ${FormatHelper.timeAgo(m.lastUpdated ?? DateTime.now())}',
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recommended
                        SectionHeader(title: 'ĐỀ XUẤT CHO BẠN', onSeeAllTap: () {}),
                        const SizedBox(height: 12),
                        MangaHorizontalList(
                          mangas: state.data.recommended,
                          subtitleBuilder: (m) => 'Ch.${m.latestChapter} • ${m.genre ?? ""}',
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Rankings
                        SectionHeader(title: 'BẢNG XẾP HẠNG', onSeeAllTap: () {}),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: state.data.rankings
                                .map((rank) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: RankItem(manga: rank),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

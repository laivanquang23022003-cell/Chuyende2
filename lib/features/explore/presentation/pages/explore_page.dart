import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appmanga/core/di/injection.dart';
import '../bloc/explore_bloc.dart';
import '../bloc/explore_event.dart';
import '../bloc/explore_state.dart';
import '../widgets/explore_featured_list.dart';
import 'package:google_fonts/google_fonts.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ExploreBloc>().add(ExploreLoadMore());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
              _buildTabItem(context, 'Khám phá', true),
              const SizedBox(width: 20),
              _buildTabItem(context, 'Mới nhất', false),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          ],
        ),
        body: BlocBuilder<ExploreBloc, ExploreState>(
          builder: (context, state) {
            if (state is ExploreLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExploreError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    ElevatedButton(
                      onPressed: () => context.read<ExploreBloc>().add(ExploreLoadRequested()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            if (state is ExploreLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ExploreBloc>().add(ExploreRefreshRequested());
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Tất cả truyện tranh',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ExploreFeaturedList(mangas: state.mangas),
                      if (state.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
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
    );
  }

  Widget _buildTabItem(BuildContext context, String title, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/manga_card.dart';
import 'manga_card_item.dart';

class MangaHorizontalList extends StatelessWidget {
  final List<MangaCard> mangas;
  final String Function(MangaCard)? subtitleBuilder;

  const MangaHorizontalList({
    super.key,
    required this.mangas,
    this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // Adjusted height to fit image + text
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: mangas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final manga = mangas[index];
          return MangaCardItem(
            manga: manga,
            subtitle: subtitleBuilder?.call(manga),
          );
        },
      ),
    );
  }
}

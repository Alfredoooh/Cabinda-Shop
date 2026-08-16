import 'package:flutter/material.dart';
import '../main.dart' show AppColors;

class GamesScreen extends StatelessWidget {
  final AppColors colors;

  const GamesScreen({super.key, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: colors.c1Bg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.videogame_asset_rounded,
              color: colors.c1Fg,
              size: 44,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Jogos em breve',
            style: TextStyle(
              fontFamily: 'ComicSansMS',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: colors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
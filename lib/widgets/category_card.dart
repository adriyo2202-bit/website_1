import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String subtitlePart1;
  final String highlightedWord1;
  final String subtitlePart2;
  final String highlightedWord2;
  final String dataKey;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.subtitlePart1,
    required this.highlightedWord1,
    required this.subtitlePart2,
    required this.highlightedWord2,
    required this.dataKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'card_hero_$dataKey',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(20),
            ),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      children: [
                        TextSpan(text: subtitlePart1),
                        TextSpan(
                          text: highlightedWord1,
                          style: const TextStyle(color: Color(0xFF7B52F4)),
                        ),
                        TextSpan(text: subtitlePart2),
                        TextSpan(
                          text: highlightedWord2,
                          style: const TextStyle(color: Color(0xFF7B52F4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

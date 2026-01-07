import 'package:flutter/material.dart';
import 'package:resq/core/theme/app_theme.dart';

class GuideWidgets extends StatelessWidget {
  const GuideWidgets({super.key});

  // List of disaster guides with image paths and labels
  final List<Map<String, String>> disasterGuides = const [
    {'image': 'assets/pics/earth_quack.png', 'label': 'Earthquake'},
    {'image': 'assets/pics/fire.png', 'label': 'Fire'},
    {'image': 'assets/pics/flood.png', 'label': 'Flood'},
    {'image': 'assets/pics/tsunami.png', 'label': 'Tsunami'},
    {'image': 'assets/pics/volcano.png', 'label': 'Volcano'},
    {'image': 'assets/pics/wind.png', 'label': 'Storm'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderLight.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secendory],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.book_rounded,
                  color: AppTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Disaster Guides',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.85,
            ),
            itemCount: disasterGuides.length,
            itemBuilder: (context, index) {
              final guide = disasterGuides[index];
              return _GuideItem(
                imagePath: guide['image']!,
                label: guide['label']!,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String imagePath;
  final String label;

  const _GuideItem({
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to guide details page
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppTheme.borderLight.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.backgroundLight,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppTheme.textLight,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  color: AppTheme.backgroundWhite,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
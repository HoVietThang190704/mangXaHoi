import 'package:flutter/material.dart';

class ProfileTabs extends StatelessWidget {
  final List<String> tabs;
  final Color accentColor;
  final int activeIndex;
  final ValueChanged<int>? onChanged;

  const ProfileTabs({
    super.key,
    required this.tabs,
    required this.accentColor,
    this.activeIndex = 0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = index == activeIndex;
          final tab = tabs[index];
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged?.call(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? accentColor.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive ? accentColor : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

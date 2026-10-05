import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CatalogFilterBar extends StatelessWidget {
  const CatalogFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSortTap,
    required this.sortActive,
    required this.categoriesFuture,
    required this.selectedCategory,
    required this.availableOnly,
    required this.onCategoryChanged,
    required this.onAvailableToggle,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSortTap;
  final bool sortActive;
  final Future<List<String>> categoriesFuture;
  final String selectedCategory;
  final bool availableOnly;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onAvailableToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search potato, batata, dhaniya…',
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onSortTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: sortActive
                        ? AppColors.emeraldLight
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sortActive
                          ? AppColors.emeraldPrimary
                          : AppColors.outline,
                    ),
                  ),
                  child: Icon(
                    Icons.sort_rounded,
                    color: sortActive
                        ? AppColors.emeraldPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FilterChip(
                label: const Text('In stock'),
                selected: availableOnly,
                onSelected: onAvailableToggle,
              ),
              const SizedBox(width: 8),
              FutureBuilder<List<String>>(
                future: categoriesFuture,
                builder: (_, snap) {
                  final cats = snap.data ?? [];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: cats.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: selectedCategory == cat,
                          onSelected: (_) => onCategoryChanged(
                            selectedCategory == cat ? '' : cat,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

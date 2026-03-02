import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PaginatedListWidget<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChanged;
  final Widget? emptyWidget;

  const PaginatedListWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyWidget ?? const Center(
        child: Padding(padding: EdgeInsets.all(32), child: Text('No items found', style: TextStyle(color: AppColors.gray400))),
      );
    }
    return Column(children: [
      ...items.map(itemBuilder),
      if (totalPages > 1)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Page $currentPage of $totalPages', style: const TextStyle(color: AppColors.gray600, fontSize: 13)),
            IconButton(
              onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ]),
        ),
    ]);
  }
}

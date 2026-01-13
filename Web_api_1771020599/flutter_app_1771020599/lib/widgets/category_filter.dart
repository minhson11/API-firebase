import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CategoryFilter extends StatelessWidget {
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ApiService.getCategories();
    final categoriesVietnamese = ApiService.getCategoriesVietnamese();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Tất cả danh mục
          _buildCategoryChip(
            label: 'Tất cả',
            isSelected: selectedCategory == null,
            onTap: () => onCategoryChanged(null),
          ),
          
          const SizedBox(width: 8),
          
          // Các danh mục cụ thể
          ...List.generate(categories.length, (index) {
            final category = categories[index];
            final vietnameseLabel = categoriesVietnamese[index];
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(
                label: vietnameseLabel,
                isSelected: selectedCategory == category,
                onTap: () => onCategoryChanged(category),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
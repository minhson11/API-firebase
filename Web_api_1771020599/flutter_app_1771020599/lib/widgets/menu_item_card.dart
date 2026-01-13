import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/dish.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;
  final VoidCallback onTap;

  const MenuItemCard({
    super.key,
    required this.menuItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh món ăn
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: menuItem.imageUrl != null && menuItem.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: menuItem.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant, color: Colors.grey),
                        ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Thông tin món ăn
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên món và danh mục
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            menuItem.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            menuItem.categoryDisplayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Mô tả
                    if (menuItem.description != null && menuItem.description!.isNotEmpty)
                      Text(
                        menuItem.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Thông tin bổ sung (chay, cay, thời gian)
                    Row(
                      children: [
                        if (menuItem.isVegetarian)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.eco, size: 12, color: Colors.green[700]),
                                const SizedBox(width: 2),
                                Text(
                                  'Chay',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (menuItem.isVegetarian && menuItem.isSpicy)
                          const SizedBox(width: 4),
                        
                        if (menuItem.isSpicy)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_fire_department, size: 12, color: Colors.red[700]),
                                const SizedBox(width: 2),
                                Text(
                                  'Cay',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const Spacer(),
                        
                        // Thời gian chế biến
                        if (menuItem.preparationTime != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 2),
                              Text(
                                '${menuItem.preparationTime}p',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Giá và trạng thái
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Giá và đánh giá
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menuItem.formattedPrice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  menuItem.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        // Trạng thái có sẵn
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: menuItem.isAvailable ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            menuItem.isAvailable ? 'Còn món' : 'Hết món',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
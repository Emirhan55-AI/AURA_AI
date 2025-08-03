import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Product Card - Displays AI-suggested products in chat messages
/// 
/// This widget shows product recommendations with image, name, price,
/// and purchase action button.
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final double? width;
  final double? height;

  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width ?? 150,
      height: height ?? 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                ),
                child: product['imageUrl'] != null
                    ? Image.network(
                        product['imageUrl'].toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(context, theme, colorScheme),
                      )
                    : _buildPlaceholder(context, theme, colorScheme),
              ),
            ),
            
            // Product info and actions
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      (product['name'] ?? 'Product').toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Price and seller
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatPrice(product['price'], product['currency']?.toString()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (product['greenScore'] != null)
                          _buildEcoScore(context, theme, colorScheme),
                      ],
                    ),
                    
                    if (product['seller'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'by ${product['seller']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Buy button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () => _openProductLink(context),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          minimumSize: const Size(0, 28),
                        ),
                        child: Text(
                          'Buy',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: colorScheme.onTertiaryContainer,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildEcoScore(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final greenScore = product['greenScore'] as int? ?? 0;
    final color = greenScore >= 80
        ? Colors.green
        : greenScore >= 60
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '$greenScore',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price, String? currency) {
    if (price == null) return 'Price unavailable';
    
    final priceValue = price is num ? price : double.tryParse(price.toString()) ?? 0;
    final currencySymbol = _getCurrencySymbol(currency ?? 'USD');
    
    return '$currencySymbol${priceValue.toStringAsFixed(2)}';
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'TRY':
        return '₺';
      default:
        return '\$';
    }
  }

  void _openProductLink(BuildContext context) async {
    final url = product['externalUrl'] as String?;
    
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product link not available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open product link'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid product link'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

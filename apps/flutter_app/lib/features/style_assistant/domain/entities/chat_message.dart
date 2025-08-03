/// Chat Message entities for Style Assistant feature
/// 
/// Represents different types of messages in the style assistant chat interface.
/// This follows the domain layer principles with immutable entities.

abstract class ChatMessage {
  final String id;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && 
           other.id == id && 
           other.timestamp == timestamp;
  }

  @override
  int get hashCode => id.hashCode ^ timestamp.hashCode;
}

/// User message in the chat conversation
class UserMessage extends ChatMessage {
  final String text;
  final String? imageUrl;

  const UserMessage({
    required super.id,
    required super.timestamp,
    required this.text,
    this.imageUrl,
  });

  UserMessage copyWith({
    String? id,
    DateTime? timestamp,
    String? text,
    String? imageUrl,
  }) {
    return UserMessage(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserMessage &&
           other.id == id &&
           other.timestamp == timestamp &&
           other.text == text &&
           other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => super.hashCode ^ text.hashCode ^ imageUrl.hashCode;

  @override
  String toString() => 'UserMessage(id: $id, text: $text, imageUrl: $imageUrl, timestamp: $timestamp)';
}

/// AI assistant message in the chat conversation
class AiMessage extends ChatMessage {
  final String? text;
  final List<Outfit>? outfits;
  final List<Product>? products;
  final bool isGenerating;

  const AiMessage({
    required super.id,
    required super.timestamp,
    this.text,
    this.outfits,
    this.products,
    this.isGenerating = false,
  });

  AiMessage copyWith({
    String? id,
    DateTime? timestamp,
    String? text,
    List<Outfit>? outfits,
    List<Product>? products,
    bool? isGenerating,
  }) {
    return AiMessage(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      text: text ?? this.text,
      outfits: outfits ?? this.outfits,
      products: products ?? this.products,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiMessage &&
           other.id == id &&
           other.timestamp == timestamp &&
           other.text == text &&
           _listEquals(other.outfits, outfits) &&
           _listEquals(other.products, products) &&
           other.isGenerating == isGenerating;
  }

  @override
  int get hashCode => super.hashCode ^ 
                     text.hashCode ^ 
                     outfits.hashCode ^ 
                     products.hashCode ^ 
                     isGenerating.hashCode;

  @override
  String toString() => 'AiMessage(id: $id, text: $text, outfits: ${outfits?.length}, products: ${products?.length}, isGenerating: $isGenerating, timestamp: $timestamp)';

  // Helper method for list comparison
  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Outfit entity for AI recommendations
class Outfit {
  final String id;
  final String name;
  final String? coverImageUrl;
  final List<String> clothingItemIds;
  final DateTime createdAt;
  final bool isFavorite;

  const Outfit({
    required this.id,
    required this.name,
    this.coverImageUrl,
    required this.clothingItemIds,
    required this.createdAt,
    this.isFavorite = false,
  });

  Outfit copyWith({
    String? id,
    String? name,
    String? coverImageUrl,
    List<String>? clothingItemIds,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      clothingItemIds: clothingItemIds ?? this.clothingItemIds,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Outfit &&
           other.id == id &&
           other.name == name &&
           other.coverImageUrl == coverImageUrl &&
           AiMessage._listEquals(other.clothingItemIds, clothingItemIds) &&
           other.createdAt == createdAt &&
           other.isFavorite == isFavorite;
  }

  @override
  int get hashCode => id.hashCode ^ 
                     name.hashCode ^ 
                     coverImageUrl.hashCode ^ 
                     clothingItemIds.hashCode ^ 
                     createdAt.hashCode ^ 
                     isFavorite.hashCode;

  @override
  String toString() => 'Outfit(id: $id, name: $name, clothingItemIds: ${clothingItemIds.length}, isFavorite: $isFavorite)';
}

/// Product entity for AI recommendations
class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String currency;
  final String seller;
  final String externalUrl;
  final double? carbonFootprintKg;
  final int greenScore;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.seller,
    required this.externalUrl,
    this.carbonFootprintKg,
    this.greenScore = 0,
  });

  Product copyWith({
    String? id,
    String? name,
    String? imageUrl,
    double? price,
    String? currency,
    String? seller,
    String? externalUrl,
    double? carbonFootprintKg,
    int? greenScore,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      seller: seller ?? this.seller,
      externalUrl: externalUrl ?? this.externalUrl,
      carbonFootprintKg: carbonFootprintKg ?? this.carbonFootprintKg,
      greenScore: greenScore ?? this.greenScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
           other.id == id &&
           other.name == name &&
           other.imageUrl == imageUrl &&
           other.price == price &&
           other.currency == currency &&
           other.seller == seller &&
           other.externalUrl == externalUrl &&
           other.carbonFootprintKg == carbonFootprintKg &&
           other.greenScore == greenScore;
  }

  @override
  int get hashCode => id.hashCode ^ 
                     name.hashCode ^ 
                     imageUrl.hashCode ^ 
                     price.hashCode ^ 
                     currency.hashCode ^ 
                     seller.hashCode ^ 
                     externalUrl.hashCode ^ 
                     carbonFootprintKg.hashCode ^ 
                     greenScore.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price $currency, greenScore: $greenScore)';
}

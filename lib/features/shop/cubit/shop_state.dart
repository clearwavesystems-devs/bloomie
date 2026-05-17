import 'package:equatable/equatable.dart';
import '../../../core/database/app_database.dart';

abstract class ShopState extends Equatable {
  const ShopState();

  @override
  List<Object?> get props => [];
}

class ShopInitial extends ShopState {}

class ShopLoading extends ShopState {}

class ShopLoaded extends ShopState {
  final List<ShopItem> items;
  final String activeCategory; // 'all' | 'pet_accessory' | 'plant_skin' | 'adventure_key'

  const ShopLoaded({
    required this.items,
    this.activeCategory = 'all',
  });

  ShopLoaded copyWith({
    List<ShopItem>? items,
    String? activeCategory,
  }) {
    return ShopLoaded(
      items: items ?? this.items,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }

  @override
  List<Object?> get props => [items, activeCategory];
}

class ShopError extends ShopState {
  final String message;

  const ShopError(this.message);

  @override
  List<Object?> get props => [message];
}

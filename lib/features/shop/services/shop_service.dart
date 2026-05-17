import '../../../core/database/app_database.dart';

class ShopService {
  final AppDatabase _db;

  ShopService(this._db);

  Future<List<ShopItem>> getAllShopItems() => _db.getAllShopItems();

  Future<List<ShopItem>> getShopItemsByCategory(String category) =>
      _db.getShopItemsByCategory(category);

  Future<void> purchaseShopItem(ShopItem item) async {
    final updated = item.copyWith(owned: true);
    await _db.updateShopItem(updated);
  }

  Future<void> equipShopItem(String id, String category) =>
      _db.equipShopItem(id, category);

  Future<void> unequipShopItem(String id) => _db.unequipShopItem(id);
}

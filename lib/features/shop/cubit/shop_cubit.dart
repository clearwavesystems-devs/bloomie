import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/app_database.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../services/shop_service.dart';
import 'shop_state.dart';

class ShopCubit extends Cubit<ShopState> {
  final ShopService _shopService;
  final ProfileCubit _profileCubit;
  final AppDatabase _db; // Used to trigger adventure land unlocks directly

  ShopCubit(this._shopService, this._profileCubit, this._db) : super(ShopInitial()) {
    loadShop();
  }

  // ── Load ───────────────────────────────────

  Future<void> loadShop() async {
    emit(ShopLoading());
    try {
      final items = await _shopService.getAllShopItems();
      emit(ShopLoaded(items: items));
      
      // Update ProfileCubit's equipped list!
      final equippedIds = items
          .where((i) => i.equipped)
          .map((i) => i.id)
          .toList();
      _profileCubit.updateEquippedAccessories(equippedIds);
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }

  // ── Category Change ────────────────────────

  void changeCategory(String category) {
    if (state is! ShopLoaded) return;
    final current = state as ShopLoaded;
    emit(current.copyWith(activeCategory: category));
  }

  // ── Buy Item ───────────────────────────────

  Future<bool> buyItem(ShopItem item) async {
    if (state is! ShopLoaded) return false;
    if (item.owned) return false;

    // Trigger deduction in ProfileCubit
    final success = await _profileCubit.deductBlooms(item.price);
    if (!success) return false;

    try {
      // Purchase item
      await _shopService.purchaseShopItem(item);

      // Special Case: Adventure Keys trigger instant Land Unlocks
      if (item.category == 'adventure_key') {
        // Map keys to land IDs
        final lands = await _db.getAllLands();
        String? targetLandId;

        if (item.id.contains('meadow')) {
          targetLandId = 'land_meadow';
        } else if (item.id.contains('cave')) {
          targetLandId = 'land_cave';
        } else if (item.id.contains('sky') || item.id.contains('cloud')) {
          targetLandId = 'land_sky';
        } else if (item.id.contains('marsh')) {
          targetLandId = 'land_marsh';
        } else if (item.id.contains('forest')) {
          targetLandId = 'land_forest';
        } else if (item.id.contains('cosmos')) {
          targetLandId = 'land_cosmos';
        }

        if (targetLandId != null) {
          final land = lands.firstWhere(
            (l) => l.id == targetLandId,
            orElse: () => lands.first,
          );
          await _db.updateLand(land.copyWith(unlocked: true));
        }
      }

      await loadShop();
      return true;
    } catch (e) {
      emit(ShopError(e.toString()));
      return false;
    }
  }

  // ── Toggle Equip ───────────────────────────

  Future<void> toggleEquip(ShopItem item) async {
    if (state is! ShopLoaded) return;
    if (!item.owned) return;

    try {
      if (item.equipped) {
        await _shopService.unequipShopItem(item.id);
      } else {
        await _shopService.equipShopItem(item.id, item.category);
      }
      await loadShop();
    } catch (e) {
      emit(ShopError(e.toString()));
    }
  }
}

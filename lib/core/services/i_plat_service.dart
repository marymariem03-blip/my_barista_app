// lib/core/services/i_plat_service.dart

import '../models/plat.dart';

abstract class IPlatService {
  List<Plat> getAll();
  Plat? getById(String id);

  Plat add({
    required String name,
    required double price,
    required String category,
    required String image,
    String description  = '',  // ✅
    bool   isBestSeller = false,
  });

  Plat update({
    required String id,
    required String name,
    required double price,
    required String category,
    required String image,
    String description  = '',  // ✅
    bool   isBestSeller = false,
  });

  void delete(String id);

  int    get totalPlats;
  int    get totalFakeOrders;
  String get mostOrderedPlat;
  double get totalFakeSales;

  // Analytics
  Map<int, int> getOrdersPerHour();
  int getMostActiveHour();

  // Manager profile
  String get managerName;
  String get managerEmail;
  String get managerAvatarAsset;
  void updateManagerProfile({
    required String name,
    required String email,
    required String avatarAsset,
  });
}
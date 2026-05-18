// lib/core/services/service_locator.dart

import 'i_plat_service.dart';
import 'firebase_plat_service.dart';

class ServiceLocator {
  ServiceLocator._();

  //  NOW USING FIREBASE
  // To switch back to fake: replace FirebasePlatService() with FakePlatService()
  static final IPlatService platService = FirebasePlatService();
}
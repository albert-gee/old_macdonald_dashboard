import 'package:dashboard/src/core/errors/result.dart';
import 'package:dashboard/src/features/wifi/domain/entities/wifi_sta_credentials.dart';

abstract interface class WifiCommandRepository {
  Future<Result<void>> connectSta(WifiStaCredentials credentials);
}

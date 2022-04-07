/// If you don't need to implement all the services use [ServicesRepositoryBase]
abstract class ServicesRepository {
  Stream<bool> get onPositionChanges;

  Stream<bool> get onBluetoothChanges;
}

class ServicesRepositoryBase implements ServicesRepository {
  @override
  Stream<bool> get onPositionChanges {
    throw UnimplementedError('ServicesRepository.onPositionChanges');
  }

  @override
  Stream<bool> get onBluetoothChanges {
    throw UnimplementedError('ServicesRepository.onBluetoothChanges');
  }
}

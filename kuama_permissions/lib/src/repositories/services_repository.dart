abstract class ServicesRepository {
  const ServicesRepository();

  Stream<bool> get onPositionChanges {
    throw UnimplementedError('ServicesRepository.onPositionChanges');
  }

  Stream<bool> get onBluetoothChanges {
    throw UnimplementedError('ServicesRepository.onBluetoothChanges');
  }
}

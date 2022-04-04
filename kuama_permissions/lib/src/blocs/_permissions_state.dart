part of 'permissions_bloc.b.dart';

enum PermissionPlace { checking, asking, requesting }

extension on PermissionPlace {
  bool get isChecking => this == PermissionPlace.checking;
  bool get isAsking => this == PermissionPlace.asking;
  bool get isRequesting => this == PermissionPlace.requesting;
}

@DataClass(copyable: true, changeable: false)
class PermissionsBlocState with _$PermissionsBlocState {
  final Map<Permission, PermissionPlace> places;

  /// Resolved
  final Map<Permission, PermissionStatus> status;

  PermissionsBlocState({
    required this.places,
    required this.status,
  });

  late final List<Permission> asking = places.entries.where((e) => e.value.isAsking).keys.toList();

  bool get isAsking => places.any((_, place) => place.isAsking);

  bool get isAskingOrRequesting => places.any((_, place) => place.isAsking || place.isRequesting);

  bool canRequest(Set<Permission> permissions) {
    return !permissions.any(places.containsKey);
  }

  bool checkEveryGranted(Set<Permission> permissions) {
    return permissions.every((permission) => status[permission]?.isGranted ?? false);
  }

  bool checkAnyGranted(Set<Permission> permissions) {
    return permissions.any((permission) => status[permission]?.isGranted ?? false);
  }

  /// Return only the permissions that can be check
  Iterable<Permission> _whereCheck(Iterable<Permission> permissions) {
    return permissions.whereNotContains(places.keys).whereNotContains(status.keys);
  }

  /// Return only the permissions that can be requested
  /// If another ask/request already perform returns a empty list
  Iterable<Permission> _whereRequest(Iterable<Permission> permissions, bool force) {
    if (isAskingOrRequesting) return [];
    return force ? permissions : permissions.where((p) => status[p] == null);
  }

  /// Return only the permissions that can be check in request method
  Iterable<Permission> _whereRequestCheck(Iterable<Permission> permissions) {
    return permissions
        .whereNotContains(places.where((_, place) => !place.isChecking).keys)
        .whereNotContains(status.keys);
  }
}

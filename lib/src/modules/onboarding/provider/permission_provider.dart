import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../utils/logger/logger_helper.dart';
import '../model/permission_type.dart';

// Permission states
final permissionProvider =
    NotifierProvider<PermissionNotifier, Map<PermissionType, bool>>(
      PermissionNotifier.new,
    );

class PermissionNotifier extends Notifier<Map<PermissionType, bool>> {
  @override
  Map<PermissionType, bool> build() {
    _loadPermissionStates();
    return {
      PermissionType.notifications: false,
      PermissionType.camera: false,
      PermissionType.contacts: false,
    };
  }

  Future<void> _loadPermissionStates() async {
    final newState = <PermissionType, bool>{};

    newState[PermissionType.notifications] =
        await Permission.notification.isGranted;
    newState[PermissionType.camera] = await Permission.camera.isGranted;
    newState[PermissionType.contacts] = await Permission.contacts.isGranted;

    state = newState;
  }

  Future<void> requestPermission(PermissionType type) async {
    Permission permission;

    switch (type) {
      case PermissionType.notifications:
        permission = Permission.notification;
        break;
      case PermissionType.camera:
        permission = Permission.camera;
        break;
      case PermissionType.contacts:
        permission = Permission.contacts;
        break;
    }

    final status = await permission.request();
    final isGranted = status.isGranted;

    state = {...state, type: isGranted};

    log.i('Permission ${type.name}: ${isGranted ? "granted" : "denied"}');
  }

  Future<void> requestAllRequired() async {
    await requestPermission(PermissionType.notifications);
    await requestPermission(PermissionType.camera);
  }

  bool get hasRequiredPermissions {
    return state[PermissionType.notifications] == true &&
        state[PermissionType.camera] == true;
  }

  bool isGranted(PermissionType type) {
    return state[type] ?? false;
  }
}

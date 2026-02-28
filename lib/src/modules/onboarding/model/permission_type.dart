enum PermissionType {
  notifications,
  camera,
  contacts;

  String get icon {
    switch (this) {
      case PermissionType.notifications:
        return '🔔';
      case PermissionType.camera:
        return '📸';
      case PermissionType.contacts:
        return '👥';
    }
  }

  String get title {
    switch (this) {
      case PermissionType.notifications:
        return 'Notifications';
      case PermissionType.camera:
        return 'Camera Access';
      case PermissionType.contacts:
        return 'Contacts';
    }
  }

  String get description {
    switch (this) {
      case PermissionType.notifications:
        return "We'll alert you once daily when it's HabitStack Time!";
      case PermissionType.camera:
        return 'To take photos of your habit progress';
      case PermissionType.contacts:
        return 'Find friends already on HabitStack';
    }
  }

  String get additionalInfo {
    switch (this) {
      case PermissionType.notifications:
        return "This is the core feature - you'll miss out without it! 😊";
      case PermissionType.camera:
        return 'You can also upload from gallery!';
      case PermissionType.contacts:
        return 'More fun with friends you know!';
    }
  }

  bool get isOptional {
    return this == PermissionType.contacts;
  }

  bool get isRequired {
    return this == PermissionType.notifications;
  }
}
enum UserType {
  client,
  hospital,
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.client:
        return 'Client';
      case UserType.hospital:
        return 'Hospital';
    }
  }

  String get description {
    switch (this) {
      case UserType.client:
        return 'Individual seeking healthcare services';
      case UserType.hospital:
        return 'Healthcare provider or institution';
    }
  }
}

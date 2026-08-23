class UpdateStatus {
  const UpdateStatus({
    required this.version,
    required this.lastUpdatedUtc,
    required this.updateAvailableVersion,
  });

  final String version;
  final DateTime? lastUpdatedUtc;
  final String? updateAvailableVersion;
}

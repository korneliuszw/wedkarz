class MigrationRecording {
  const MigrationRecording({
    required this.id,
    required this.recordedAt,
    required this.durationSeconds,
    this.mediaUrl,
    this.site,
  });
  final String id;
  final DateTime recordedAt;
  final int durationSeconds;
  final Uri? mediaUrl;
  final String? site;
}

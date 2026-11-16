import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../application/providers.dart';
import '../../core/widgets.dart';

class MigrationScreen extends ConsumerWidget {
  const MigrationScreen({super.key});
  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final recordings = ref.watch(migrationRecordingsProvider);
    return AsyncBody(
      value: recordings,
      retry: () => ref.invalidate(migrationRecordingsProvider),
      data: (items) {
        final available = items.where(
          (item) => item.mediaUrl?.scheme == 'https',
        );
        if (available.isEmpty) {
          return PageBody(child: Text(c.l.noRecordings));
        }
        return SingleChildScrollView(
          child: PageBody(
            child: Column(
              children: [
                for (final recording in available)
                  _RecordingTile(
                    title:
                        '${recording.site ?? c.l.fishPass} · ${dayLabel(recording.recordedAt)}',
                    duration: recording.durationSeconds,
                    onTap: () => pushPage(
                      c,
                      RecordingScreen(
                        title: recording.site ?? c.l.fishPass,
                        mediaUrl: recording.mediaUrl!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _duration(int seconds) =>
    '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

class _RecordingTile extends StatelessWidget {
  const _RecordingTile({
    required this.title,
    required this.duration,
    required this.onTap,
  });

  final String title;
  final int duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: MenuPanel(title: title, subtitle: _duration(duration), onTap: onTap),
  );
}

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({
    super.key,
    required this.title,
    required this.mediaUrl,
  });

  final String title;
  final Uri mediaUrl;

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late final _controller = VideoPlayerController.networkUrl(widget.mediaUrl);
  late final _ready = _controller.initialize();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) => Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          FishingHeader(back: true, title: widget.title),
          PageBody(
            child: FutureBuilder<void>(
              future: _ready,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text(c.l.videoUnavailable);
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final controller = _controller;
                return ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    if (value.hasError) return Text(c.l.videoUnavailable);
                    return Column(
                      children: [
                        AspectRatio(
                          aspectRatio: value.aspectRatio,
                          child: VideoPlayer(controller),
                        ),
                        VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: value.isPlaying
                              ? controller.pause
                              : controller.play,
                          icon: Icon(
                            value.isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(value.isPlaying ? c.l.pause : c.l.play),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

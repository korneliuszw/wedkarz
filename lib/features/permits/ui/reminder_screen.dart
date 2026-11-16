import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nad_parseta/application/providers.dart';
import 'package:nad_parseta/core/widgets.dart';
import 'package:nad_parseta/domain/models.dart';
import 'package:nad_parseta/features/permits/ui/permit_labels.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key, required this.ownerId, this.initial});
  final String ownerId;
  final ReminderSettings? initial;
  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  late bool _seven;
  late bool _one;
  late bool _expiryDay;
  late int _hour;
  bool _busy = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final settings =
        widget.initial ??
        ref.read(fishingProvider(widget.ownerId)).valueOrNull?.reminders ??
        const ReminderSettings();
    _seven = settings.sevenDays;
    _one = settings.oneDay;
    _expiryDay = settings.expiryDay;
    _hour = settings.hour;
  }

  Future<void> _save(BuildContext c) async {
    setState(() => _busy = true);
    final saved = await runAction(
      c,
      () => ref
          .read(fishingProvider(widget.ownerId).notifier)
          .saveReminders(
            ReminderSettings(
              sevenDays: _seven,
              oneDay: _one,
              expiryDay: _expiryDay,
              hour: _hour,
            ),
          ),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _saved = saved;
    });
  }

  @override
  Widget build(BuildContext c) {
    if (widget.initial == null) {
      return OnlineGate(
        child: AsyncBody(
          value: ref.watch(remoteReminderProvider),
          retry: () => ref.invalidate(remoteReminderProvider),
          data: (settings) =>
              ReminderScreen(ownerId: widget.ownerId, initial: settings),
        ),
      );
    }
    final permits =
        ref.watch(permitsProvider(widget.ownerId)).valueOrNull ?? [];
    final permit = permits
        .where((p) => p.isValidAt(DateTime.now()))
        .firstOrNull;
    return OnlineGate(
      child: FishingScreenBody(
        title: c.l.reminders,
        subtitle: permit == null
            ? null
            : '${c.l.permit} · ${c.l.validUntil.toLowerCase()} ${dayLabel(lastPermitDay(permit))}',
        footer: _saved
            ? null
            : FilledButton(
                onPressed: _busy ? null : () => _save(c),
                child: Text(c.l.saveReminders),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SurfacePanel(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _toggle(c.l.sevenDaysBefore, _seven, (v) => _seven = v),
                  const Divider(height: 1),
                  _toggle(c.l.oneDayBefore, _one, (v) => _one = v),
                  const Divider(height: 1),
                  _toggle(c.l.expiryDay, _expiryDay, (v) => _expiryDay = v),
                  ListTile(
                    title: Text(c.l.reminderTime),
                    trailing: Text('${_hour.toString().padLeft(2, '0')}:00'),
                    onTap: _busy
                        ? null
                        : () async {
                            final time = await showDialog<int>(
                              context: c,
                              builder: (dialog) => SimpleDialog(
                                title: Text(c.l.reminderTime),
                                children: [
                                  for (var hour = 0; hour < 24; hour++)
                                    SimpleDialogOption(
                                      onPressed: () =>
                                          Navigator.pop(dialog, hour),
                                      child: Text(
                                        '${hour.toString().padLeft(2, '0')}:00',
                                      ),
                                    ),
                                ],
                              ),
                            );
                            if (time != null && mounted) {
                              setState(() {
                                _hour = time;
                                _saved = false;
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_saved)
              Semantics(
                liveRegion: true,
                child: SurfacePanel(child: Text(c.l.reminderSaved)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String title, bool value, ValueChanged<bool> change) =>
      SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: _busy
            ? null
            : (next) => setState(() {
                change(next);
                _saved = false;
              }),
      );
}

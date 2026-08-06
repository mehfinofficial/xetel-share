import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/persistence/receive_history_entry.dart';
import 'package:localsend_app/pages/receive_page.dart';
import 'package:localsend_app/provider/receive_history_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/native/directories.dart';
import 'package:localsend_app/util/native/open_file.dart';
import 'package:localsend_app/util/native/open_folder.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/widget/dialogs/file_info_dialog.dart';
import 'package:localsend_app/widget/dialogs/history_clear_dialog.dart';
import 'package:localsend_app/widget/file_thumbnail.dart';
import 'package:localsend_app/widget/glass_action_button.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/model/session_status.dart';
import 'package:localsend_isolates/util/file_size_helper.dart';
import 'package:path/path.dart' as path;
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';

enum _EntryOption {
  open,
  showInFolder,
  info,
  delete
  ;

  String get label {
    return switch (this) {
      _EntryOption.open => t.receiveHistoryPage.entryActions.open,
      _EntryOption.showInFolder => t.receiveHistoryPage.entryActions.showInFolder,
      _EntryOption.info => t.receiveHistoryPage.entryActions.info,
      _EntryOption.delete => t.receiveHistoryPage.entryActions.deleteFromHistory,
    };
  }
}

const _optionsAll = _EntryOption.values;
final _optionsWithoutOpen = [_EntryOption.info, _EntryOption.delete];

/// Formats a calendar day as a localized date label (e.g. "Aug 6, 2026").
/// Note: no "Today"/"Yesterday" special-casing — those strings don't exist
/// in the translation files yet, and adding them means touching all ~57
/// locale files, which is out of scope for a presentation-only pass.
String _dayLabel(DateTime day) {
  final languageTag = LocaleSettings.currentLocale.languageTag;
  return DateFormat.yMMMd(languageTag).format(day);
}

class ReceiveHistoryPage extends StatelessWidget {
  const ReceiveHistoryPage({super.key});

  Future<void> _openFile(
    BuildContext context,
    ReceiveHistoryEntry entry,
    Dispatcher<ReceiveHistoryService, List<ReceiveHistoryEntry>> dispatcher,
  ) async {
    if (entry.path != null) {
      await openFile(
        context,
        entry.fileType,
        entry.path!,
        onDeleteTap: () => dispatcher.dispatchAsync(RemoveHistoryEntryAction(entry.id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = context.watch(receiveHistoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Group entries by local calendar day. The provider already returns
    // entries newest-first, so both day order and within-day order fall
    // out naturally — no extra sort needed for the entries themselves.
    final groups = <DateTime, List<ReceiveHistoryEntry>>{};
    for (final entry in entries) {
      final local = entry.timestamp.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      groups.putIfAbsent(day, () => []).add(entry);
    }
    final sortedDays = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.receiveHistoryPage.title),
      ),
      body: ResponsiveListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 15),
                GlassActionButton(
                  label: t.receiveHistoryPage.openFolder,
                  icon: Icons.folder_open_rounded,
                  filled: false,
                  onTap: checkPlatform([TargetPlatform.iOS])
                      ? null
                      : () async {
                          // ignore: use_build_context_synchronously
                          final destination = context.read(settingsProvider).destination ?? await getDefaultDestinationDirectory();
                          await openFolder(folderPath: destination);
                        },
                ),
                const SizedBox(width: 12),
                GlassActionButton(
                  label: t.receiveHistoryPage.deleteHistory,
                  icon: Icons.delete_outline_rounded,
                  filled: false,
                  isWarning: true,
                  onTap: entries.isEmpty
                      ? null
                      : () async {
                          final result = await showDialog(
                            context: context,
                            builder: (_) => const HistoryClearDialog(),
                          );

                          if (context.mounted && result == true) {
                            await context.redux(receiveHistoryProvider).dispatchAsync(RemoveAllHistoryEntriesAction());
                          }
                        },
                ),
                const SizedBox(width: 15),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.onSurface.withValues(alpha: 0.06),
                      ),
                      child: Icon(Icons.inbox_outlined, size: 36, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text(t.receiveHistoryPage.empty, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            )
          else
            for (final day in sortedDays) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(19, 8, 15, 8),
                child: Text(
                  _dayLabel(day),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ...groups[day]!.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: Material(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: entry.path != null || entry.isMessage
                          ? () async {
                              if (entry.isMessage) {
                                final vm = ViewProvider((ref) {
                                  return ReceivePageVm(
                                    status: SessionStatus.waiting,
                                    sender: Device(
                                      signalingId: null,
                                      ip: '0.0.0.0',
                                      version: '1.0.0',
                                      port: 8080,
                                      https: false,
                                      fingerprint: 'fingerprint',
                                      alias: entry.senderAlias,
                                      deviceModel: 'deviceModel',
                                      deviceType: DeviceType.web,
                                      download: true,
                                      discoveryMethods: const {},
                                    ),
                                    showSenderInfo: false,
                                    files: [],
                                    message: entry.fileName,
                                    onAccept: () {},
                                    onDecline: () {},
                                    onClose: () {},
                                  );
                                });

                                // ignore: unawaited_futures
                                context.push(() => ReceivePage(vm));
                                return;
                              }

                              await _openFile(context, entry, context.redux(receiveHistoryProvider));
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FilePathThumbnail(
                              path: entry.path,
                              fileType: entry.fileType,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    entry.fileName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${DateFormat.jm(LocaleSettings.currentLocale.languageTag).format(entry.timestamp.toLocal())} · '
                                    '${entry.fileSize.asReadableFileSize} · ${entry.senderAlias}',
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<_EntryOption>(
                              onSelected: (_EntryOption item) async {
                                switch (item) {
                                  case _EntryOption.open:
                                    await _openFile(context, entry, context.redux(receiveHistoryProvider));
                                    break;
                                  case _EntryOption.showInFolder:
                                    if (entry.path != null) {
                                      await openFolder(
                                        folderPath: File(entry.path!).parent.path,
                                        fileName: path.basename(entry.path!),
                                      );
                                    }
                                    break;
                                  case _EntryOption.info:
                                    // ignore: use_build_context_synchronously
                                    await showDialog(
                                      context: context,
                                      builder: (_) => FileInfoDialog(entry: entry),
                                    );
                                    break;
                                  case _EntryOption.delete:
                                    // ignore: use_build_context_synchronously
                                    await context.redux(receiveHistoryProvider).dispatchAsync(RemoveHistoryEntryAction(entry.id));
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return (entry.path != null ? _optionsAll : _optionsWithoutOpen).map((e) {
                                  return PopupMenuItem<_EntryOption>(
                                    value: e,
                                    child: Text(e.label),
                                  );
                                }).toList();
                              },
                              icon: Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.onSurface.withValues(alpha: 0.06),
                                ),
                                child: Icon(Icons.more_vert_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
        ],
      ),
    );
  }
}
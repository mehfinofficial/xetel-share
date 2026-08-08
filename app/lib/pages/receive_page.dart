import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localsend_app/config/theme.dart';
import 'package:localsend_app/gen/strings.g.dart';
import 'package:localsend_app/model/persistence/color_mode.dart';
import 'package:localsend_app/pages/receive_options_page.dart';
import 'package:localsend_app/provider/favorites_provider.dart';
import 'package:localsend_app/provider/selection/selected_receiving_files_provider.dart';
import 'package:localsend_app/provider/settings_provider.dart';
import 'package:localsend_app/util/device_type_ext.dart';
import 'package:localsend_app/util/favorites.dart';
import 'package:localsend_app/util/ip_helper.dart';
import 'package:localsend_app/util/native/platform_check.dart';
import 'package:localsend_app/util/native/taskbar_helper.dart';
import 'package:localsend_app/util/ui/snackbar.dart';
import 'package:localsend_app/widget/device_bage.dart';
import 'package:localsend_app/widget/liquid_glass.dart';
import 'package:localsend_app/widget/responsive_list_view.dart';
import 'package:localsend_isolates/model/device.dart';
import 'package:localsend_isolates/model/dto/file_dto.dart';
import 'package:localsend_isolates/model/session_status.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:routerino/routerino.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceivePageVm {
  final SessionStatus? status;
  final Device sender;

  /// Show hashtag and device model.
  final bool showSenderInfo;
  final List<FileDto> files;
  final String? message;
  final bool isLink;
  final void Function() onAccept;
  final void Function() onDecline;
  final void Function() onClose;

  ReceivePageVm({
    required this.status,
    required this.sender,
    required this.showSenderInfo,
    required this.files,
    required this.message,
    required this.onAccept,
    required this.onDecline,
    required this.onClose,
  }) : isLink = message != null && !message.trim().contains(RegExp(r'\s')) && (Uri.tryParse(message.trim())?.isAbsolute ?? false);
}

class ReceivePage extends StatefulWidget {
  final ViewProvider<ReceivePageVm> vm;

  const ReceivePage(this.vm);

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> with Refena {
  bool _showFullIp = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch(
      widget.vm,
      listener: (prev, next) {
        if (prev.status != next.status) {
          // ignore: discarded_futures
          TaskbarHelper.visualizeStatus(next.status);
        }
      },
    );

    if (vm.status == null && vm.message == null) {
      return const Scaffold(
        body: SizedBox(),
      );
    }

    final senderFavoriteEntry = ref.watch(favoritesProvider.select((state) => state.findDevice(vm.sender)));

    return ViewModelBuilder(
      provider: (ref) => widget.vm,
      onFirstFrame: (context, vm) {
        ref.notifier(selectedReceivingFilesProvider).setFiles(vm.files);
      },
      dispose: (ref) {
        ref.dispose(widget.vm);
        unawaited(TaskbarHelper.clearProgressBar());
      },
      builder: (context, vm) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              vm.onDecline();
            }
          },
          canPop: true,
          child: Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: ResponsiveListView.defaultMaxWidth),
                  child: Builder(
                    builder: (context) {
                      final height = MediaQuery.of(context).size.height;
                      final smallUi = vm.message != null && height < 600;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: smallUi ? 20 : 30),
                        child: Column(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (vm.showSenderInfo && !smallUi)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _SenderAvatar(icon: vm.sender.deviceType.icon),
                                    ),
                                  Builder(
                                    builder: (context) {
                                      final alias = senderFavoriteEntry?.alias ?? vm.sender.alias;
                                      if (alias.isEmpty) {
                                        return Text('', style: TextStyle(fontSize: smallUi ? 32 : 48));
                                      }
                                      return FittedBox(
                                        child: Text(
                                          alias,
                                          style: TextStyle(fontSize: smallUi ? 32 : 48, fontWeight: FontWeight.w700),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ),
                                  if (vm.showSenderInfo) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () {
                                            setState(() {
                                              _showFullIp = !_showFullIp;
                                            });
                                          },
                                          child: DeviceBadge(
                                            backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                            foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
                                            label: switch (vm.sender.ip) {
                                              String ip => _showFullIp ? ip : '#${ip.visualId}',
                                              null => 'WebRTC',
                                            },
                                          ),
                                        ),
                                        if (vm.sender.deviceModel != null) ...[
                                          const SizedBox(width: 10),
                                          DeviceBadge(
                                            backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                            foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
                                            label: vm.sender.deviceModel!,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 40),
                                  Text(
                                    vm.message != null
                                        ? (vm.isLink ? t.receivePage.subTitleLink : t.receivePage.subTitleMessage)
                                        : t.receivePage.subTitle(n: vm.files.length),
                                    style: smallUi
                                        ? null
                                        : Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (vm.message != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 20),
                                          child: SizedBox(
                                            height: 100,
                                            child: LiquidGlassContainer(
                                              borderRadius: BorderRadius.circular(16),
                                              blurSigma: 18,
                                              child: SingleChildScrollView(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(14),
                                                  child: SelectableText(
                                                    vm.message!,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            _PillButton(
                                              icon: Icons.copy_rounded,
                                              label: t.general.copy,
                                              filled: !vm.isLink,
                                              onTap: () {
                                                unawaited(
                                                  Clipboard.setData(ClipboardData(text: vm.message!)),
                                                );
                                                if (checkPlatformIsDesktop()) {
                                                  context.showSnackBar(t.general.copiedToClipboard);
                                                }
                                                vm.onAccept();
                                                context.pop();
                                              },
                                            ),
                                            if (vm.isLink) ...[
                                              const SizedBox(width: 14),
                                              _PillButton(
                                                icon: Icons.open_in_new_rounded,
                                                label: t.general.open,
                                                filled: true,
                                                onTap: () {
                                                  // ignore: discarded_futures
                                                  launchUrl(Uri.parse(vm.message!), mode: LaunchMode.externalApplication);
                                                  vm.onAccept();
                                                  context.pop();
                                                },
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            _Actions(vm),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Circular "liquid glass" avatar surface behind the sender's device-type
/// icon. Same depth/gradient/sheen language as [LiquidGlassContainer]
/// elsewhere (progress ring backdrop, glass nav, settings panels), just
/// applied to a circle instead of a rounded rect.
class _SenderAvatar extends StatelessWidget {
  final IconData icon;

  const _SenderAvatar({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: LiquidGlassContainer(
        borderRadius: BorderRadius.circular(48),
        blurSigma: 18,
        child: Center(
          child: Icon(icon, size: 44, color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}

/// Horizontal icon+label pill button, matching the two visual treatments
/// used by [BigButton] elsewhere: a gradient-filled primary surface, or a
/// liquid glass secondary surface. Same interaction/callback shape as the
/// original [ElevatedButton.icon]s -- restyle only, no new behavior.
class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  final Color? accentColor;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(18);
    final disabled = onTap == null;
    final base = accentColor ?? colorScheme.primary;
    final fg = filled ? colorScheme.onPrimary : (accentColor != null ? base : colorScheme.onSurface);

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: disabled ? fg.withValues(alpha: 0.4) : fg),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: disabled ? fg.withValues(alpha: 0.4) : fg,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );

    if (!filled) {
      return Opacity(
        opacity: disabled ? 0.5 : 1,
        child: LiquidGlassContainer(
          borderRadius: borderRadius,
          blurSigma: 18,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onTap,
              child: content,
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base,
                Color.lerp(base, Colors.black, isDark ? 0.15 : 0.08)!,
              ],
            ),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: base.withValues(alpha: isDark ? 0.28 : 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final ReceivePageVm vm;

  const _Actions(this.vm);

  @override
  Widget build(BuildContext context) {
    final selectedFiles = context.watch(selectedReceivingFilesProvider);
    final colorMode = context.watch(settingsProvider.select((state) => state.colorMode));

    if (vm.message != null) {
      return Center(
        child: _PillButton(
          icon: Icons.close_rounded,
          label: t.general.close,
          filled: false,
          onTap: () {
            vm.onAccept();
            context.pop();
          },
        ),
      );
    }

    if (vm.status == SessionStatus.canceledBySender) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              t.receivePage.canceled,
              style: TextStyle(color: Theme.of(context).colorScheme.warning, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: _PillButton(
              icon: Icons.check_circle_rounded,
              label: t.general.close,
              filled: true,
              onTap: () {
                vm.onClose();
                context.pop();
              },
            ),
          ),
        ],
      );
    }

    final declineColor = colorMode == ColorMode.yaru ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.error;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _PillButton(
            icon: Icons.tune_rounded,
            label: t.receiveOptionsPage.title,
            filled: false,
            onTap: () async {
              await context.push(() => ReceiveOptionsPage(vm));
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PillButton(
              icon: Icons.close_rounded,
              label: t.general.decline,
              filled: colorMode != ColorMode.yaru,
              accentColor: declineColor,
              onTap: () {
                vm.onDecline();
                context.pop();
              },
            ),
            const SizedBox(width: 16),
            _PillButton(
              icon: Icons.check_circle_rounded,
              label: t.general.accept,
              filled: true,
              onTap: selectedFiles.isEmpty ? null : () => vm.onAccept(),
            ),
          ],
        ),
      ],
    );
  }
}
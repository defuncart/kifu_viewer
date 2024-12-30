import 'dart:io' show Platform;

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey, Clipboard;
import 'package:kifu_viewer/l10n/l10n_extension.dart';
import 'package:kifu_viewer/widgets/home_screen/kifu_viewer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:menubar/menubar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shogi/shogi.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Game? _game;

  bool get _hasGame => _game != null && _game!.gameBoards.isNotEmpty;

  bool get _useCustomFont => kIsWeb || Platform.isLinux;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      Future.microtask(() {
        // ignore: use_build_context_synchronously
        final l10n = context.l10n;
        setApplicationMenu([
          NativeSubmenu(
            label: 'Kifu',
            children: [
              NativeMenuItem(
                label: l10n.menuBarOpenFile,
                shortcut: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyO),
                onSelected: () async => await _selectFile(),
              ),
              NativeMenuItem(
                label: l10n.menuBarClipboard,
                shortcut: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyV),
                onSelected: () async => await _fromClipboard(),
              ),
            ],
          ),
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.fileOutline),
            tooltip: context.l10n.homeScreenOpenFileButtonTooltip,
            onPressed: () async => await _selectFile(),
          ),
          IconButton(
            icon: Icon(MdiIcons.clipboardFileOutline),
            tooltip: context.l10n.homeScreenClipboardButtonTooltip,
            onPressed: () async => await _fromClipboard(),
          ),
          IconButton(
            icon: Icon(Icons.info),
            tooltip: context.l10n.homeScreenInfoButtonTooltip,
            onPressed: _showAboutPage,
          ),
        ],
      ),
      body: Center(
        child: _hasGame
            ? DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText2!.apply(
                      fontFamily: _useCustomFont ? 'NotoSansJP' : null,
                    ),
                child: KifuViewer(game: _game!),
              )
            : Text(context.l10n.homeScreenNoKifu),
      ),
    );
  }

  Future<void> _selectFile() async {
    final file = await FileSelectorPlatform.instance.openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          extensions: ['kif'],
        ),
      ],
      confirmButtonText: context.l10n.generalOpen,
    );
    if (file != null) {
      try {
        final contents = await file.readAsString();
        _convertFile(contents);
      } on Exception catch (_) {
        _showInvalidContent();
      }
    }
  }

  Future<void> _fromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      _convertFile(data.text!);
    }
  }

  void _convertFile(String file) {
    try {
      final game = Game.fromKif(file);
      if (game != _game) {
        setState(() => _game = game);
      } else {
        _showCustomDialog(
          title: context.l10n.gameAlreadyOpenPopupTitle,
          description: context.l10n.gameAlreadyOpenPopupDescription,
        );
      }
      // ignore: avoid_catching_errors
    } on ArgumentError catch (_) {
      _showInvalidContent();
    }
  }

  void _showInvalidContent() => _showCustomDialog(
        title: context.l10n.invalidContentPopupTitle,
        description: context.l10n.invalidContentPopupDescription,
      );

  void _showCustomDialog({
    required String title,
    required String description,
  }) =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              child: Text(context.l10n.generalOk.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      );

  void _showAboutPage() async {
    final packageInfo = await PackageInfo.fromPlatform();
    showLicensePage(
      context: context,
      applicationName: 'Kifu Viewer',
      applicationVersion: packageInfo.version,
      applicationLegalese: 'defuncart',
    );
  }
}

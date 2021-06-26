import 'dart:io' show Platform;

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey, Clipboard;
import 'package:kifu_viewer/localizations.dart';
import 'package:kifu_viewer/widgets/home_screen/kifu_viewer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:menubar/menubar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shogi/shogi.dart';

class HomeScreen extends StatefulWidget {
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
      setApplicationMenu([
        Submenu(
          label: 'Kifu',
          children: [
            MenuItem(
              label: AppLocalizations.menuBarOpenFile,
              enabled: true,
              shortcut: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyO),
              onClicked: () async => await _selectFile(),
            ),
            MenuItem(
              label: AppLocalizations.menuBarClipboard,
              enabled: true,
              shortcut: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyV),
              onClicked: () async => await _fromClipboard(),
            ),
          ],
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.appTitle),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.fileOutline),
            tooltip: AppLocalizations.homeScreenOpenFileButtonTooltip,
            onPressed: () async => await _selectFile(),
          ),
          IconButton(
            icon: Icon(MdiIcons.clipboardFileOutline),
            tooltip: AppLocalizations.homeScreenClipboardButtonTooltip,
            onPressed: () async => await _fromClipboard(),
          ),
          IconButton(
            icon: Icon(MdiIcons.information),
            tooltip: AppLocalizations.homeScreenInfoButtonTooltip,
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
            : Text(AppLocalizations.homeScreenNoKifu),
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
      confirmButtonText: AppLocalizations.generalOpen,
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
          title: AppLocalizations.gameAlreadyOpenPopupTitle,
          description: AppLocalizations.gameAlreadyOpenPopupDescription,
        );
      }
      // ignore: avoid_catching_errors
    } on ArgumentError catch (_) {
      _showInvalidContent();
    }
  }

  void _showInvalidContent() => _showCustomDialog(
        title: AppLocalizations.invalidContentPopupTitle,
        description: AppLocalizations.invalidContentPopupDescription,
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
              child: Text(AppLocalizations.generalOk.toUpperCase()),
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                primary: Theme.of(context).accentColor,
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

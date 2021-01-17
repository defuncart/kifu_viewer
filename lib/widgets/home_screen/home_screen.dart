import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kifu_viewer/localizations.dart';
import 'package:kifu_viewer/widgets/home_screen/kifu_viewer.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:menubar/menubar.dart';
import 'package:shogi/shogi.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Game _game;

  bool get _hasGame => _game != null && _game.gameBoards.isNotEmpty;

  @override
  void initState() {
    super.initState();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.appTitle),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.fileOutline),
            onPressed: () async => await _selectFile(),
          ),
          IconButton(
            icon: Icon(MdiIcons.clipboardFileOutline),
            onPressed: () async => await _fromClipboard(),
          ),
        ],
      ),
      body: Center(
        child: _hasGame ? KifuViewer(game: _game) : Text(AppLocalizations.homeScreenNoKifu),
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
      final contents = await file.readAsString();
      _convertFile(contents);
    }
  }

  Future<void> _fromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data != null) {
      _convertFile(data.text);
    }
  }

  void _convertFile(String file) {
    final game = Game.fromKif(file);
    if (game != null) {
      setState(() => _game = game);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.invalidContentPopupTitle),
          content: Text(AppLocalizations.invalidContentPopupDescription),
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
    }
  }
}

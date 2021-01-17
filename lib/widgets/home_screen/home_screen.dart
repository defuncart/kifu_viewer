import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:kifu_viewer/localizations.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.appTitle),
      ),
      body: Center(
        child: TextButton(
          child: Text('Open Kifu'),
          onPressed: () async => await _selectFile(),
        ),
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
      confirmButtonText: 'Ok',
    );
    if (file != null) {
      print(file.name);
      print(file.path);
      // final contents = await file.readAsString();
      // print(contents);
    }
  }
}

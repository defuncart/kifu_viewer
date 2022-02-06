import 'package:flutter/foundation.dart' show LicenseEntry, LicenseParagraph, LicenseRegistry;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kifu_viewer/widgets/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final contents = await rootBundle.loadString('assets/fonts/OFL.txt');
  LicenseRegistry.addLicense(() async* {
    yield _CustomLicenseEntry([
      'NotoSansJP'
    ], [
      LicenseParagraph(contents, 0),
    ]);
  });

  runApp(const MyApp());
}

class _CustomLicenseEntry extends LicenseEntry {
  _CustomLicenseEntry(
    this.packages,
    this.paragraphs,
  );

  @override
  final Iterable<String> packages;

  @override
  final Iterable<LicenseParagraph> paragraphs;
}

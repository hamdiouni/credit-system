This folder should contain font files used by the PDF generator.

Required (recommended):
- `NotoSans-Regular.ttf` (Latin font, used for English/French)
- `NotoNaskhArabic-Regular.ttf` (Arabic font, required to render Arabic glyphs correctly)

Where to get them:
- Noto Sans: https://fonts.google.com/specimen/Noto+Sans
- Noto Naskh Arabic: https://fonts.google.com/specimen/Noto+Naskh+Arabic

After placing the files into this folder, uncomment the `assets` and `fonts` block in `pubspec.yaml` (see the commented section under `flutter:`), then run:

  flutter pub get

Then rebuild the app and export the PDF again.

Arabic shaping (glyph joining) is handled by the `arabic_reshaper` package in `PdfExportService`; with the fonts in place and the app locale set to Arabic, exported PDFs should show correctly connected Arabic text.

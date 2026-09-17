# Arabic PDF Export – Root Cause and Fix

## Why Arabic Was Broken Even After Adding Fonts

1. **Arabic shaping (glyph joining)**  
   Arabic letters have four contextual forms: isolated, initial, medial, and final. Unicode stores text in **logical order** (one codepoint per letter). Correct display requires **shaping**: choosing the right glyph per character based on its neighbours. The Dart `pdf` package does **not** implement OpenType shaping (no GSUB/GPOS). It draws one glyph per character, so you get disconnected or wrong forms.

2. **Font vs engine**  
   Noto Naskh Arabic in assets was loaded correctly. The problem was not missing fonts but that the **PDF library does not shape Arabic**. So even with the right font, text was passed as raw logical-order Arabic and rendered without joining.

3. **RTL**  
   `Directionality(textDirection: rtl)` was already used for Arabic, so layout direction was correct. The remaining issue was purely **glyph shaping**.

4. **No reshaping in the pipeline**  
   All strings (labels, customer name, notes, etc.) were sent to `pw.Text` as-is. For Arabic, that meant unshaped logical-order text, so letters appeared disconnected.

---

## Implemented Fix

- **Arabic shaping**  
  Integrated `arabic_reshaper` (^0.0.1). For `language == 'ar'`, every string passed to the PDF is reshaped with `ArabicReshaper.instance.reshape(text)` before being given to `pw.Text`. Reshaping produces the correct presentation forms so the pdf package renders connected Arabic.

- **Scope**  
  Shaping is applied only in `PdfExportService` and only when building PDF text (via `_shapeForPdf(text, language)`). It is used for:
  - Headers and section titles  
  - Customer info (name, phone)  
  - Dates (locale-formatted, then shaped so any Arabic digits/symbols render correctly)  
  - Financial labels and amounts  
  - Table headers and cells (including notes and item labels)  
  - Footer text  

- **RTL**  
  Existing `pw.Directionality(textDirection: pw.TextDirection.rtl)` for Arabic is unchanged.

- **French and English**  
  `_shapeForPdf` returns the string unchanged when `language != 'ar'`, so French and English PDFs are unchanged.

- **Numbers and dates**  
  Still formatted with `DateFormat`/`intl` (locale-aware). Shaping is applied to the resulting string; non-Arabic segments are left unchanged by the reshaper.

- **Offline**  
  No network; `arabic_reshaper` runs fully offline.

- **No pre-shaped storage**  
  Reshaping is done only at PDF generation time in the service. No reshaped text is stored in the database or elsewhere.

---

## New Dependency

| Package           | Version | Justification |
|------------------|---------|----------------|
| `arabic_reshaper` | ^0.0.1 | Lightweight Dart implementation that converts logical-order Arabic to presentation forms (initial/medial/final/isolated and ligatures). Required because the `pdf` package does not perform OpenType shaping. Used only when generating PDFs in Arabic locale. |

---

## Validation Checklist

- **Arabic PDFs**  
  Export a customer report with app locale set to Arabic. Headings, labels, customer name, notes, and table content should show **joined letters** and correct order. Noto Naskh Arabic is used when the font is present in `assets/fonts/`.

- **French and English PDFs**  
  Export with French and English locales. Output should be unchanged from before (no shaping applied).

- **Mixed content**  
  Customer name or notes in Arabic with amounts/dates in locale format should render correctly: Arabic shaped and connected, numbers/dates unchanged.

- **Layout**  
  PDF layout (margins, tables, RTL for Arabic) remains correct and printable.

---

## Files Touched

- `pubspec.yaml` – Added `arabic_reshaper: ^0.0.1` and `flutter.assets`/`flutter.fonts` for `assets/fonts/`.
- `lib/services/pdf_export_service.dart` – Import `arabic_reshaper`, added `_shapeForPdf(text, language)`, and pass all PDF text through it; `_buildInfoRow`, `_buildSummaryRow`, and `_buildTableCell` take `language` and use `_shapeForPdf`. RTL and font loading logic unchanged.

No UI or database changes. Shaping is confined to the PDF export layer.

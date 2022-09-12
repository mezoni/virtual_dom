import '../virtual_dom/vhtml.dart';

/// Creates a virtual node [VHtml] with inner html [html].
VHtml vHtml(String tag, String html) {
  final vHtml = VHtml(tag, html);
  return vHtml;
}

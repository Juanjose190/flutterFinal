import 'dart:html' as html;

Future<void> enterFullscreen() async {
  final el = html.document.documentElement;
  if (el != null) {
    await el.requestFullscreen();
  }
}

Future<void> exitFullscreen() async {
  // exitFullscreen returns void in dart:html; just invoke it.
  html.document.exitFullscreen();
}

bool get isFullScreen => html.document.fullscreenElement != null;

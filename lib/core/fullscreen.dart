// Conditional facade for fullscreen across platforms.
import 'fullscreen_web.dart' if (dart.library.io) 'fullscreen_io.dart' as impl;

Future<void> enterFullscreen() => impl.enterFullscreen();
Future<void> exitFullscreen() => impl.exitFullscreen();
bool get isFullScreen => impl.isFullScreen;


// Android平台window_size占位符
class Screen {
  final double width;
  final double height;
  final double scaleFactor;
  
  Screen({required this.width, required this.height, this.scaleFactor = 1.0});
}

class WindowInfo {
  final double width;
  final double height;
  
  WindowInfo({required this.width, required this.height});
}

Future<List<Screen>> getScreenList() async {
  return [Screen(width: 1080, height: 1920)];
}

Future<WindowInfo> getWindowInfo() async {
  return WindowInfo(width: 1080, height: 1920);
}
// Android版本的窗口管理器占位符实现
// 用于替代window_manager包在Android平台的功能

import 'dart:ui';

// Android平台窗口管理器占位符
import 'package:flutter/material.dart';

// 窗口选项类
class WindowOptions {
  Size? size;
  Offset? center;
  Size? minimumSize;
  Size? maximumSize;
  bool? alwaysOnTop;
  bool? fullScreen;
  bool? backgroundColor;
  bool? skipTaskbar;
  String? title;
  bool? titleBarStyle;
  
  WindowOptions({
    this.size,
    this.center,
    this.minimumSize,
    this.maximumSize,
    this.alwaysOnTop,
    this.fullScreen,
    this.backgroundColor,
    this.skipTaskbar,
    this.title,
    this.titleBarStyle,
  });
}

// 调整边缘枚举
enum ResizeEdge {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

// 子窗口调整边缘枚举
enum SubWindowResizeEdge {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

// 窗口管理器占位符
class WindowManager {
  static final WindowManager instance = WindowManager._internal();
  factory WindowManager() => instance;
  WindowManager._internal();

  Future<void> setSize(Size size, {bool animate = false}) async {}
  Future<void> show() async {}
  Future<void> setPreventClose(bool prevent) async {}
  Future<void> close() async {}
  void setResizable(bool resizable) {}
  void setMovable(bool movable) {}
  void addListener(dynamic listener) {}
  void removeListener(dynamic listener) {}
}

final windowManager = WindowManager.instance;

// 窗口控制器占位符
class WindowController {
  final int windowId;
  WindowController._(this.windowId);
  
  static WindowController fromWindowId(int id) => WindowController._(id);
  
  Future<void> setMethodHandler(String method, dynamic handler) async {}
  Future<void> close() async {}
}

// 桌面多窗口占位符
class DesktopMultiWindow {
  static Future<List<int>> getAllSubWindowIds() async => [];
  static void invokeMethod(dynamic windowId, String method, [dynamic args]) {}
}

// 窗口事件监听器占位符
abstract class WindowListener {
  void onWindowEvent(String eventName) {}
  void onWindowClose() {}
}

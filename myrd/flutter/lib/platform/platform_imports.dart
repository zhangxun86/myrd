// 平台特定的导入管理器
// 根据平台自动选择正确的包实现

import 'dart:io' show Platform;

// 桌面多窗口管理
export 'android_desktop_multi_window.dart' 
    if (dart.library.io) 'package:desktop_multi_window/desktop_multi_window.dart'
    if (dart.library.html) 'android_desktop_multi_window.dart';

// 窗口管理器
export 'android_window_manager.dart'
    if (dart.library.io) 'package:window_manager/window_manager.dart'
    if (dart.library.html) 'android_window_manager.dart';

// 窗口大小管理
export 'android_window_size.dart'
    if (dart.library.io) 'package:window_size/window_size.dart'
    if (dart.library.html) 'android_window_size.dart';

// 统一链接管理
export 'android_uni_links.dart'
    if (dart.library.io) 'package:uni_links/uni_links.dart'
    if (dart.library.html) 'android_uni_links.dart';

// 聊天组件
export 'android_dash_chat.dart'
    if (dart.library.io) 'package:dash_chat_2/dash_chat_2.dart'
    if (dart.library.html) 'android_dash_chat.dart';

// 动态布局
export 'android_dynamic_layouts.dart'
    if (dart.library.io) 'package:dynamic_layouts/dynamic_layouts.dart'
    if (dart.library.html) 'android_dynamic_layouts.dart';

// GPU纹理渲染器
export 'android_gpu_texture_renderer.dart'
    if (dart.library.io) 'package:flutter_gpu_texture_renderer/flutter_gpu_texture_renderer.dart'
    if (dart.library.html) 'android_gpu_texture_renderer.dart';

// RGBA纹理渲染器
export 'android_texture_rgba_renderer.dart'
    if (dart.library.io) 'package:texture_rgba_renderer/texture_rgba_renderer.dart'
    if (dart.library.html) 'android_texture_rgba_renderer.dart';

// 平台检测辅助函数
bool get isAndroid {
  try {
    return Platform.isAndroid;
  } catch (e) {
    return false;
  }
}

bool get isDesktop {
  try {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  } catch (e) {
    return false;
  }
}

bool get isWeb => !isAndroid && !isDesktop;
// Android版本的统一链接管理器占位符实现
// 用于替代uni_links包在Android平台的功能

import 'dart:async';

// Android平台uni_links占位符
import 'dart:async';

Future<String?> getInitialLink() async => null;

Stream<Uri?> get uriLinkStream => const Stream.empty();

// 链接流控制器
final StreamController<String?> _linkStreamController = StreamController<String?>.broadcast();

// 初始链接流
Stream<String?> get linkStream => _linkStreamController.stream;

// 获取初始链接
Future<String?> getInitialLink() async => null;

// 获取初始URI
Future<Uri?> getInitialUri() async => null;

// URI流
Stream<Uri?> get uriLinkStream => linkStream.map((link) => link != null ? Uri.tryParse(link) : null);

// 关闭流
void dispose() {
  _linkStreamController.close();
}
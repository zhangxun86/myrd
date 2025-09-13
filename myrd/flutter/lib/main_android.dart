// Android专用的入口文件
// 这个文件排除所有桌面特有的代码，专门用于Android构建

import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common/widgets/overlay.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'common.dart';
import 'consts.dart';
import 'mobile/pages/home_page.dart';
import 'mobile/pages/server_page.dart';
import 'models/platform_model.dart';

/// Android特有的窗口和启动属性
late List<String> kBootArgs;

Future<void> main(List<String> args) async {
  earlyAssert();
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("Android launch args: $args");
  kBootArgs = List.from(args);

  // Android直接运行移动版本
  runMobileApp();
}

Future<void> initEnv(String appType) async {
  // 全局共享首选项
  await platformFFI.init(appType);
  // 全局FFI，仅用于全局配置
  // 为了方便，在移动平台上使用全局FFI
  await initGlobalFFI();
  _registerEventHandler();
  // 更新系统主题
  updateSystemWindowTheme();
}

void runMobileApp() async {
  await initEnv(kAppTypeMain);
  checkUpdate();
  if (isAndroid) androidChannelInit();
  if (isAndroid) platformFFI.syncAndroidServiceAppDirConfigPath();
  draggablePositions.load();
  await Future.wait([gFFI.abModel.loadCache(), gFFI.groupModel.loadCache()]);
  gFFI.userModel.refreshCurrentUser();
  runApp(App());
  // 初始化统一链接 - 使用占位符实现
  // await initUniLinks();
}

// 错误处理
void earlyAssert() {
  // Android版本的早期断言检查
}

void checkUpdate() {
  // Android版本的更新检查
}

void androidChannelInit() {
  // Android通道初始化
}

void _registerEventHandler() {
  // 注册事件处理器
}

void updateSystemWindowTheme() {
  // 更新系统窗口主题
}

// App类保持不变，从原始文件导入
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RustDesk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('zh', 'CN'),
        // 添加其他支持的语言
      ],
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
    );
  }
}
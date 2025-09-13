// 临时生成的Flutter-Rust桥接文件
// 这是为了绕过网络问题而创建的简化版本

import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

// EventToUI 类型定义
abstract class EventToUI {
  const EventToUI();
}

class EventToUI_Event extends EventToUI {
  final String field0;
  const EventToUI_Event(this.field0);
}

class EventToUI_Rgba extends EventToUI {
  final int field0;
  const EventToUI_Rgba(this.field0);
}

class EventToUI_Texture extends EventToUI {
  final int field0;
  final bool field1;
  const EventToUI_Texture(this.field0, this.field1);
}

// RustdeskImpl 类定义
class RustdeskImpl {
  final DynamicLibrary _dylib;
  
  RustdeskImpl(this._dylib);

  // 基本方法定义
  void initialize({required String appDir, required String customClientConfig}) {}
  Future<void> startGlobalEventStream({required StreamSink<String> s, required String appType}) => Future.value();
  void stopGlobalEventStream({required String appType}) {}
  void hostStopSystemKeyPropagate({required bool stopped}) {}
  int peerGetSessionsCount({required String id, required int connType}) => 0;

  String sessionAddExistedSync({
    required String id,
    required String sessionId,
    required Int32List displays,
    required bool isViewCamera,
  }) => '';

  String sessionAddSync({
    required String sessionId,
    required String id,
    required bool isFileTransfer,
    required bool isViewCamera,
    required bool isPortForward,
    required bool isRdp,
    required bool isTerminal,
    required String switchUuid,
    required bool forceRelay,
    required String password,
    required bool isSharedPassword,
    String? connToken,
  }) => '';

  Future<ResultType<()>> sessionStart({
    required StreamSink<EventToUI> events2ui,
    required String sessionId,
    required String id,
  }) => Future.value(Result.ok(()));

  Future<ResultType<()>> sessionStartWithDisplays({
    required StreamSink<EventToUI> events2ui,
    required String sessionId,
    required String id,
    required Int32List displays,
  }) => Future.value(Result.ok(()));

  bool? sessionGetRemember({required String sessionId}) => null;
  bool sessionGetToggleOptionSync({required String sessionId, required String arg}) => false;
  Future<bool?> sessionGetToggleOption({required String sessionId, required String arg}) => Future.value(false);

  // 主要方法定义
  String mainGetOptionSync({required String key}) => '';
  Future<void> mainSetOption({required String key, required String value}) => Future.value();
  String mainGetAppNameSync() => 'RustDesk';
  Future<String> mainGetVersion() => Future.value('1.4.2');
  String mainGetLocalOption({required String key}) => '';
  Future<void> mainSetLocalOption({required String key, required String value}) => Future.value();
  Future<String> mainGetMyId() => Future.value('');
  Future<String> mainGetUuid() => Future.value('');
  String mainGetPeerOptionSync({required String id, required String key}) => '';
  bool mainSetPeerOptionSync({required String id, required String key, required String value}) => true;
  Future<void> mainUpdateTemporaryPassword() => Future.value();

  // 服务器相关方法
  bool serverGetByName({required String name}) => false;
  void serverSetByName({required String name, required String value}) {}
  String serverGetConnectStatus() => '';
  void serverToggleService() {}
  void serverStopService() {}

  // Android 特定方法
  void androidRequestPermissions() {}
  void dispose() {}

  Future<void> sessionInputKey({
    required String sessionId,
    required String name,
    required bool down,
    required bool press,
    required bool alt,
    required bool ctrl,
    required bool shift,
    required bool command,
  }) => Future.value();

  // 主函数方法
  Future<String> mainGetApiServer() => Future.value('');
  int getNextTextureKey() => 0;

  // Terminal 方法 - 修复参数名称
  Future<void> sessionSendTerminalInput({required String sessionId, required String terminalId, required String input}) => Future.value();
  Future<void> sessionResizeTerminal({required String sessionId, required String terminalId, required int width, required int height}) => Future.value();
  Future<void> sessionOpenTerminal({required String sessionId, required String terminalId, required int width, required int height}) => Future.value();
  Future<void> sessionCloseTerminal({required String sessionId, required String terminalId}) => Future.value();

  // Plugin 方法 - 修复参数名称
  Future<void> pluginEvent({required String id, required String peer, required String event}) => Future.value();
  String pluginGetSharedOption({required String id, required String key}) => '';
  String pluginGetSessionOption({required String id, required String peer, required String key}) => '';

  // Connection 方法
  bool isIncomingOnly() => false;
  bool isOutgoingOnly() => false;
  Future<String> mainGetConnectStatus() => Future.value('{}');
  Future<bool> mainIsUsingPublicServer() => Future.value(false);
  Future<String> mainGetLastRemoteId() => Future.value('');
  void mainOnMainWindowClose() {}

  // Update 方法
  String mainGetCommonSync({required String key}) => '';
  Future<void> mainSetCommon({required String key, required String value}) => Future.value();
  Future<String> mainGetCommon({required String key}) => Future.value('');

  // Platform 方法
  void platformGetByName({required String name}) {}
  void platformSetByName({required String name, required String value}) {}
  Future<void> installPlugin({required String filepath}) => Future.value();
  Future<void> uninstallPlugin({required String id}) => Future.value();
  String pluginListSync() => '[]';
  bool pluginIsEnabledSync({required String id}) => false;
  void pluginEnableSync({required String id, required bool enabled}) {}
  Future<String> pluginGetDefaultConfig({required String id}) => Future.value('{}');
  Future<void> pluginSetConfig({required String id, required String value}) => Future.value();
  void platformStopService() {}
  bool platformIsServiceRunning() => false;
  void platformStartService() {}

  // 缺失方法 - 全部合并
  void sessionSendSelectedSessionId({required String sessionId}) {}
  String mainSetUnlockPin({required String pin}) => "";
  Future<void> mainClearTrustedDevices() async {}
  Future<void> mainRemoveTrustedDevices({required String json}) async {}
  Future<String> mainGetTrustedDevices() async => "";
  String translate({required String name, required String locale}) => name;
  String sessionGetRgbaSize({required String sessionId, required int display}) => "0,0";
  void sessionNextRgba({required String sessionId, required int display}) {}
  void sessionRegisterPixelbufferTexture({required String sessionId, required int display, required int ptr}) {}
  void sessionRegisterGpuTexture({required String sessionId, required int display, required int ptr}) {}
  void mainStartDbusServer() {}
  String getLocalKbLayoutType() => "en-US";
  Future<void> setLocalKbLayoutType({required String kbLayoutType}) async {}
  String mainUriPrefixSync() => "rustdesk://";
  String getLocalFlutterOption({required String k}) => "";
  Future<void> setLocalFlutterOption({required String k, required String v}) async {}
  Future<void> mainRemovePeer({required String id}) async {}
  Future<void> mainRemoveDiscovered({required String id}) async {}
  String mainGetBuildinOption({required String key}) => "";
  void mainWol({required String id}) {}
  void mainCreateShortcut({required String id}) {}
  Future<void> mainForgetPassword({required String id}) async {}
  void sessionToggleVirtualDisplay({required String sessionId, required int index, required bool on}) {}
  Future<void> sessionSendPointer({required String sessionId, required String msg}) async {}
  void mainStartIpcUrlServer() {}
  Future<void> cmInit() async {}
  void mainDeviceId({required String id}) {}
  String mainGetDataDirIos({required String appDir}) => "";
  void mainLoadRecentPeers() {}
  void sessionSendMouse({required String sessionId, required String msg}) {}
  void sessionSendKey({required String sessionId, required String msg}) {}
  String sessionGetToken({required String sessionId}) => "";
  void sessionLogin({required String sessionId, required String username, required String password}) {}
  void sessionSend2Fa({required String sessionId, required String code}) {}
  String sessionGetConnectStatus({required String sessionId}) => "";
  void sessionReconnect({required String sessionId}) {}
  String sessionGetPeerInfo({required String sessionId}) => "";
  String sessionGetOption({required String sessionId, required String name}) => "";
  void sessionSetOption({required String sessionId, required String name, required String value}) {}
  void sessionInputOsPassword({required String sessionId, required String value, required bool activate}) {}
  String sessionGetFlutterConfig({required String sessionId, required String k}) => "";
  void sessionSetFlutterConfig({required String sessionId, required String k, required String v}) {}
  String sessionAlternativeCodecs({required String sessionId}) => "";
  void sessionChangeResolution({required String sessionId, required int display, required int width, required int height}) {}
  void sessionSetDisplaysInJson({required String sessionId, required String displays}) {}
  
  // 修复mainGetFav返回类型，使其可以调用.toList()
  Future<List<String>> mainGetFav() async => [];
  
  void sessionRequestVoiceCall({required String sessionId}) {}
  void sessionCloseVoiceCall({required String sessionId}) {}
  void sessionPeerOption({required String sessionId, required String name, required String value}) {}
  bool isDisableSettings() => false;
  Future<String> mainGetFingerprint() async => "";
  Future<String> mainGetBuildDate() async => "";
  bool isCustomClient() => false;
  bool mainHasValid2FaSync() => false;
  bool mainHasValidBotSync() => false;
  void sessionToggleOption({required String sessionId, required String value}) {}
  String mainGetUserDefaultOption({required String key}) => "";
  String sessionGetDisplaysAsIndividualWindows({required String sessionId}) => "";
  void sessionSetDisplaysAsIndividualWindows({required String sessionId, required String value}) {}
  String sessionGetUseAllMyDisplaysForTheRemoteSession({required String sessionId}) => "";
  void sessionSetUseAllMyDisplaysForTheRemoteSession({required String sessionId, required String value}) {}
  void sessionChangePreferCodec({required String sessionId}) {}
  void sessionTogglePrivacyMode({required String sessionId, required String implName, required String on}) {}
  String sessionGetReverseMouseWheelSync({required String sessionId}) => "";
  void sessionSetReverseMouseWheel({required String sessionId, required String value}) {}
  void mainLoadFavPeers() {}
  void mainLoadLanPeers() {}
  
  Future<String> mainGetOptions() async => "{}";
  void mainChangeId({required String newId}) {}
  Future<String> mainGetAsyncStatus() async => "";
  Future<String> mainGetOption({required String key}) async => "";
  void sessionElevateWithLogon({required String sessionId, required String username, required String password}) {}
  void sessionElevateDirect({required String sessionId}) {}
  Future<void> mainSetPeerAlias({required String id, required String alias}) async {}
  Future<String> mainGetPeerOption({required String id, required String key}) async => "";
  Future<bool> mainPeerHasPassword({required String id}) async => false;
  int mainMaxEncryptLen() => 1024;
  Future<void> mainSetPeerOption({required String id, required String key, required String value}) async {}
  String mainGetLoginDeviceInfo() => "{}";
  Future<bool> mainGetProxyStatus() async => false;
  Future<void> mainHttpRequest({required String method, required String url, required String body, required String header}) async {}
  Future<String> mainGetHttpStatus({required String url}) async => "{}";
  Future<void> mainStoreFav({required List<String> favs}) async {}
  void sessionRestartRemoteDevice({required String sessionId}) {}
  
  // 最后一批缺失方法 - 修复返回类型
  Future<void> sessionToggleOption({required String sessionId, required String value}) async {}
  Future<void> sessionSetDisplaysAsIndividualWindows({required String sessionId, required String value}) async {}
  Future<void> sessionSetUseAllMyDisplaysForTheRemoteSession({required String sessionId, required String value}) async {}
  Future<void> sessionSetReverseMouseWheel({required String sessionId, required String value}) async {}
  Future<void> mainLoadFavPeers() async {}
  
  // View和Scroll样式方法
  Future<String> sessionGetViewStyle({required String sessionId}) async => "original";
  Future<String> sessionGetScrollStyle({required String sessionId}) async => "scrollauto";
  Future<void> sessionSetScrollStyle({required String sessionId, required String value}) async {}
  
  // 其他缺失方法
  void sessionLockScreen({required String sessionId}) {}
  void sessionCtrlAltDel({required String sessionId}) {}
  bool mainCurrentIsWayland() => false;
  String mainGetMainDisplay() => "";
  bool mainHasFileClipboard() => false;
  void sessionTogglePrivacyMode({required String sessionId, required String implName, required String implKey, required String on}) {}
  void mainSetUserDefaultOption({required String key, required String value}) {}
  bool pluginIsEnabled({required String id}) => false;
  void pluginInstall({required String id, required String path, required bool register}) {}
  void pluginEnable({required String id, required bool v}) {}
  
  // 账户相关方法
  Future<String> mainAccountAuthResult() async => "";
  Future<void> mainAccountAuth({required String op, required bool rememberMe}) async {}
  void mainAccountAuthCancel() {}
  
  // 文件相关方法
  void sessionSendFiles({required String sessionId, required String actId, required String path, required String to, required int fileNum, required String includeHidden, required bool isRemote}) {}
  void sessionRemoveFile({required String sessionId, required String actId, required String path, required int id, required bool isRemote}) {}
  void sessionRemoveAllEmptyDirs({required String sessionId, required String actId, required String path, required int id, required bool isRemote}) {}
  void sessionCreateDir({required String sessionId, required String actId, required String path, required bool isRemote}) {}
  Future<void> sessionRenameFile({required String sessionId, required String actId, required String path, required String newName, required int id, required bool isRemote}) async {}
  Future<void> sessionCancelJob({required String sessionId, required int actId}) async {}
  void sessionAddJob({required String sessionId, required String actId, required String path, required String to, required int fileNum, required String includeHidden, required bool isRemote}) {}
  void sessionResumeJob({required String sessionId, required int actId, required bool isRemote}) {}
  Future<String> sessionReadLocalEmptyDirsRecursiveSync({required String sessionId, required String path, required String includeHidden}) async => "";
  Future<String> sessionReadRemoteEmptyDirsRecursiveSync({required String sessionId, required String path, required String includeHidden}) async => "";
  
  // 地址簿和群组相关
  void mainSaveAb({required String json}) {}
  Future<String> mainLoadAb() async => "";
  bool isDisableGroupPanel() => false;
  void mainSaveGroup({required String json}) {}
  Future<String> mainLoadGroup() async => "";
  Future<void> mainClearGroup() async {}
  bool isDisableAb() => false;
  bool isDisableAccount() => false;
  
  // 端口转发
  Future<void> sessionAddPortForward({required String sessionId, required int localPort, required String remoteHost, required int remotePort}) async {}
  Future<void> sessionRemovePortForward({required String sessionId, required int localPort}) async {}
  String mainGetPeerSync({required String id}) => "";
  String sessionNewRdp({required String sessionId}) => "";

}

// 辅助类型
typedef ResultType<T> = Result<T, String>;

// 简单的Result类型实现
class Result<T, E> {
  final T? _value;
  final E? _error;
  final bool _isOk;

  const Result._(this._value, this._error, this._isOk);
  
  factory Result.ok(T value) => Result._(value, null, true);
  factory Result.err(E error) => Result._(null, error, false);
  
  bool get isOk => _isOk;
  bool get isErr => !_isOk;
  
  T get ok => _value!;
  E get err => _error!;
}

// Bind 全局实例
final RustdeskImpl bind = RustdeskImpl(DynamicLibrary.process());

// 常量定义
const String kKeyMapMode = 'map';
const String kKeyTranslateMode = 'translate';  
const String kKeyLegacyMode = 'legacy';
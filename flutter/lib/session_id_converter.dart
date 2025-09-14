// SessionID类型转换适配器  
// 解决UuidValue到String的类型转换问题

import 'package:flutter_hbb/generated_bridge.dart';

// 通用SessionID转换函数
String _toSessionId(dynamic sessionId) {
  if (sessionId == null) return "";
  if (sessionId is String) return sessionId;
  return sessionId.toString();
}

// 扩展RustdeskImpl类，添加自动类型转换的包装方法
extension SessionIdConverter on RustdeskImpl {
  // 自动转换SessionID的包装方法
  
  // 选项相关方法
  void sessionPeerOptionAuto({required dynamic sessionId, required String name, required String value}) {
    sessionPeerOption(sessionId: _toSessionId(sessionId), name: name, value: value);
  }
  
  Future<String> sessionGetOptionAuto({required dynamic sessionId, required String name, String? arg}) async {
    return await sessionGetOption(sessionId: _toSessionId(sessionId), name: name, arg: arg);
  }
  
  void sessionSetOptionAuto({required dynamic sessionId, required String name, required String value}) {
    sessionSetOption(sessionId: _toSessionId(sessionId), name: name, value: value);
  }
  
  // 切换选项相关方法
  String sessionGetToggleOptionSyncAuto({required dynamic sessionId, required String arg}) {
    return sessionGetToggleOptionSync(sessionId: _toSessionId(sessionId), arg: arg);
  }
  
  void sessionToggleOptionAuto({required dynamic sessionId, required String value}) {
    sessionToggleOption(sessionId: _toSessionId(sessionId), value: value);
  }
  
  // 隐私模式方法
  void sessionTogglePrivacyModeAuto({required dynamic sessionId, required String implName, bool? on, String? implKey}) {
    sessionTogglePrivacyMode(sessionId: _toSessionId(sessionId), implName: implName, on: on, implKey: implKey);
  }
  
  // 虚拟显示器方法
  void sessionToggleVirtualDisplayAuto({required dynamic sessionId, required int display, required bool on, int? index}) {
    sessionToggleVirtualDisplay(sessionId: _toSessionId(sessionId), display: display, on: on, index: index);
  }
  
  // 输入相关方法
  void sessionInputOsPasswordAuto({required dynamic sessionId, required String value}) {
    sessionInputOsPassword(sessionId: _toSessionId(sessionId), value: value);
  }
  
  void sessionInputStringAuto({required dynamic sessionId, required String value}) {
    sessionInputString(sessionId: _toSessionId(sessionId), value: value);
  }
  
  // 鼠标滚轮相关方法
  String sessionGetReverseMouseWheelSyncAuto({required dynamic sessionId}) {
    return sessionGetReverseMouseWheelSync(sessionId: _toSessionId(sessionId));
  }
  
  Future<void> sessionSetReverseMouseWheelAuto({required dynamic sessionId, required String value}) async {
    return await sessionSetReverseMouseWheel(sessionId: _toSessionId(sessionId), value: value);
  }
  
  // 编解码器方法
  void sessionChangePreferCodecAuto({required dynamic sessionId, String? codec}) {
    sessionChangePreferCodec(sessionId: _toSessionId(sessionId), codec: codec);
  }
  
  // 显示器方法
  bool sessionGetDisplaysAsIndividualWindowsAuto({required dynamic sessionId}) {
    return sessionGetDisplaysAsIndividualWindows(sessionId: _toSessionId(sessionId));
  }
  
  void sessionSetDisplaysAsIndividualWindowsAuto({required dynamic sessionId, required bool value}) {
    sessionSetDisplaysAsIndividualWindows(sessionId: _toSessionId(sessionId), value: value);
  }
  
  // 记住功能方法
  Future<bool> sessionGetRememberAuto({required dynamic sessionId}) async {
    return await sessionGetRemember(sessionId: _toSessionId(sessionId));
  }
  
  // 权限提升方法
  void sessionElevateWithLogonAuto({required dynamic sessionId, required String username, required String password}) {
    sessionElevateWithLogon(sessionId: _toSessionId(sessionId), username: username, password: password);
  }
  
  void sessionElevateDirectAuto({required dynamic sessionId}) {
    sessionElevateDirect(sessionId: _toSessionId(sessionId));
  }
  
  // 重启远程设备方法
  void sessionRestartRemoteDeviceAuto({required dynamic sessionId}) {
    sessionRestartRemoteDevice(sessionId: _toSessionId(sessionId));
  }
}
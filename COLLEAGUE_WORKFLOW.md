# 🚀 RustDesk Android 项目完整接手流程

**接手人员专用指南** | **从零到APK构建完整流程**

---

## 📋 第一步：环境准备

### 🖥️ 服务器要求
- **系统**: Ubuntu 20.04+ 
- **内存**: 4GB+ 
- **存储**: 20GB+ 
- **网络**: 美国服务器环境 (无需代理)
- **权限**: 具有sudo权限的用户账户

### 🔧 前置软件检查
```bash
# 检查系统版本
cat /etc/os-release

# 检查可用空间
df -h

# 检查内存
free -h
```

---

## 📥 第二步：下载项目代码

### 1. 克隆主项目仓库
```bash
# 克隆项目代码
git clone https://github.com/zhangxun86/myrd.git
cd myrd

# 验证文件完整性
ls -la
echo "✅ 项目代码下载完成"
```

### 2. 下载预编译依赖包 (推荐) 
```bash
# 方案A: 从本服务器下载 (最快)
wget http://[当前服务器IP]:8000/rustdesk-deps-20250913.tar.gz

# 解压到用户目录
tar -xzf rustdesk-deps-20250913.tar.gz -C ~/

# 验证解压结果
ls -la ~/.pub-cache ~/.cargo ~/.rustup ~/android-sdk

echo "✅ 依赖包安装完成 (跳过环境配置)"
```

**🔄 备选方案: 从零配置环境**
```bash
# 如果依赖包下载失败，执行完整环境配置
chmod +x setup_env.sh
./setup_env.sh
source ~/.bashrc
```

---

## 🛠️ 第三步：环境验证

### 验证所有组件
```bash
# 验证Java环境
java -version
# 预期输出: openjdk version "11.0.x"

# 验证Rust环境  
rustc --version
# 预期输出: rustc 1.75.x

# 验证Flutter环境
flutter --version
# 预期输出: Flutter 3.24.5

# 验证Android环境
echo $ANDROID_HOME
echo $ANDROID_NDK_HOME
# 应该显示正确路径

# 验证所有工具
flutter doctor -v
```

**⚠️ 如果验证失败:**
```bash
# 重新配置环境变量
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

# 写入配置文件
echo 'export ANDROID_HOME="$HOME/android-sdk"' >> ~/.bashrc
echo 'export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973"' >> ~/.bashrc
echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"' >> ~/.bashrc

source ~/.bashrc
```

---

## 🏗️ 第四步：项目构建

### 1. 构建Rust原生库
```bash
# 进入项目目录
cd /root/myrd/myrd

# 添加Android目标平台
rustup target add aarch64-linux-android

# 编译原生库
cargo ndk -t arm64-v8a build --release

# 验证编译结果
ls -la target/aarch64-linux-android/release/librustdesk.so
echo "✅ Rust库编译完成 (约470KB)"
```

### 2. 构建Flutter应用
```bash
# 进入Flutter目录
cd flutter

# 清理缓存
flutter clean

# 获取依赖
flutter pub get

# 构建APK (Debug版本 - 用于测试)
flutter build apk --debug

# 构建APK (Release版本 - 生产使用)
flutter build apk --release
```

### 3. 验证构建结果
```bash
# 检查APK文件
ls -la build/app/outputs/flutter-apk/

# 预期看到:
# app-debug.apk (约15-20MB) 
# app-release.apk (约8-12MB)

echo "🎉 APK构建完成!"
```

---

## 🚨 常见问题排查

### ❌ 问题1: "Android SDK not found"
```bash
# 解决方案
export ANDROID_HOME="$HOME/android-sdk"
flutter config --android-sdk $ANDROID_HOME
flutter doctor
```

### ❌ 问题2: "NDK not configured"  
```bash
# 解决方案
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973"
echo $ANDROID_NDK_HOME
```

### ❌ 问题3: "cargo-ndk not found"
```bash
# 解决方案
cargo install cargo-ndk
rustup target add aarch64-linux-android
```

### ❌ 问题4: "Flutter dependencies failed"
```bash
# 解决方案
cd flutter
flutter clean
rm -rf ~/.pub-cache/hosted
flutter pub get
```

### ❌ 问题5: "Rust编译错误"
```bash
# 解决方案
cd /root/myrd/myrd
cargo clean
cargo ndk -t arm64-v8a build --release --verbose
```

### ❌ 问题6: "权限问题"
```bash
# 解决方案
sudo chown -R $USER:$USER ~/android-sdk
sudo chown -R $USER:$USER ~/.cargo
sudo chown -R $USER:$USER ~/.pub-cache
chmod +x setup_env.sh
```

---

## 📊 预期构建时间

| 阶段 | 时间估计 | 说明 |
|------|----------|------|
| 代码下载 | 2-5分钟 | 取决于网络速度 |
| 依赖包下载 | 5-15分钟 | 150MB压缩包 |
| 环境验证 | 1-2分钟 | 快速检查 |
| Rust编译 | 5-10分钟 | 首次编译较慢 |
| Flutter构建 | 10-20分钟 | 包含依赖下载 |
| **总计** | **23-52分钟** | **首次完整构建** |

---

## 🎯 成功标志

### ✅ 环境配置成功
- `java -version` 显示Java 11
- `rustc --version` 显示Rust 1.75+  
- `flutter doctor` 无错误提示
- 环境变量正确设置

### ✅ Rust编译成功
- 生成 `librustdesk.so` 文件 (约470KB)
- 无编译错误输出
- 文件位于 `target/aarch64-linux-android/release/`

### ✅ Flutter构建成功
- 生成APK文件
- Debug版本: 15-20MB
- Release版本: 8-12MB
- 位于 `build/app/outputs/flutter-apk/`

---

## 🚀 快速构建脚本

创建一键构建脚本:
```bash
# 创建快速构建脚本
cat > ~/quick_build.sh << 'EOF'
#!/bin/bash
set -e
echo "🚀 开始快速构建 RustDesk Android..."

# 检查环境
source ~/.bashrc
flutter doctor --version

# 构建Rust库
cd /root/myrd/myrd
cargo ndk -t arm64-v8a build --release

# 构建Flutter APK  
cd flutter
flutter clean
flutter pub get
flutter build apk --release

echo "✅ 构建完成!"
echo "📦 APK位置: build/app/outputs/flutter-apk/"
ls -la build/app/outputs/flutter-apk/
EOF

chmod +x ~/quick_build.sh
echo "✅ 快速构建脚本已创建: ~/quick_build.sh"
```

使用快速构建:
```bash
~/quick_build.sh
```

---

## 📞 技术支持

### 🔍 日志检查
```bash
# Flutter构建日志
flutter build apk --verbose

# Rust编译日志  
cargo ndk -t arm64-v8a build --release --verbose

# 系统环境日志
flutter doctor -v
```

### 📋 环境信息收集
```bash
# 创建环境报告
echo "=== 环境信息报告 ===" > env_report.txt
echo "系统: $(cat /etc/os-release | grep PRETTY_NAME)" >> env_report.txt
echo "Java: $(java -version 2>&1 | head -1)" >> env_report.txt  
echo "Rust: $(rustc --version)" >> env_report.txt
echo "Flutter: $(flutter --version | head -1)" >> env_report.txt
echo "Android SDK: $ANDROID_HOME" >> env_report.txt
echo "Android NDK: $ANDROID_NDK_HOME" >> env_report.txt
echo "磁盘空间: $(df -h / | tail -1)" >> env_report.txt
echo "内存状态: $(free -h | head -2 | tail -1)" >> env_report.txt

cat env_report.txt
```

---

## 📝 接手检查清单

### 准备阶段 ☐
- [ ] 服务器权限确认
- [ ] 网络连通性测试  
- [ ] 磁盘空间检查
- [ ] 系统版本确认

### 代码阶段 ☐  
- [ ] 项目代码克隆完成
- [ ] 依赖包下载解压
- [ ] 文件权限设置正确
- [ ] 目录结构验证

### 环境阶段 ☐
- [ ] Java 11 配置验证
- [ ] Rust 1.75 安装确认
- [ ] Flutter 3.24.5 安装确认
- [ ] Android SDK/NDK 配置
- [ ] 环境变量设置正确

### 构建阶段 ☐
- [ ] Rust库编译成功
- [ ] Flutter依赖获取成功
- [ ] APK构建完成
- [ ] 文件大小验证

### 完成阶段 ☐
- [ ] APK安装测试
- [ ] 功能基础验证
- [ ] 构建脚本保存
- [ ] 文档更新记录

---

**🎯 最后提醒:**

1. **严格按顺序执行** - 每个步骤都很重要
2. **遇到错误立即停止** - 查看错误信息并解决
3. **验证每个阶段** - 确保前一步成功再继续
4. **保存构建日志** - 方便后续调试
5. **备份重要文件** - 包括环境配置和APK

**预期完成时间: 1-2小时** (包含学习和调试时间)

---

*文档版本: v1.0*  
*创建时间: 2025-09-13*  
*适用环境: Ubuntu 20.04+ / 美国服务器*
# ⚡ 同事快速上手指南

**服务器IP：** `198.11.178.210`  
**依赖包下载地址：** `http://198.11.178.210:8000/rustdesk-deps-20250913.tar.gz`

---

## 🚀 30分钟快速构建流程

### 第一步：下载项目和依赖 (5分钟)
```bash
# 下载项目代码
git clone https://github.com/zhangxun86/myrd.git
cd myrd

# 下载依赖包 (150MB)
wget http://198.11.178.210:8000/rustdesk-deps-20250913.tar.gz

# 解压依赖到用户目录
tar -xzf rustdesk-deps-20250913.tar.gz -C ~/
```

### 第二步：配置环境 (2分钟)
```bash
# 配置环境变量
cat >> ~/.bashrc << 'EOF'
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$HOME/.cargo/bin"
EOF

# 重新加载环境
source ~/.bashrc

# 验证环境
flutter doctor --version
rustc --version
java -version
```

### 第三步：构建项目 (20分钟)
```bash
# 编译Rust库
cd myrd
rustup target add aarch64-linux-android
cargo ndk -t arm64-v8a build --release

# 构建Flutter APK
cd flutter
flutter clean
flutter pub get
flutter build apk --release

# 查看结果
ls -la build/app/outputs/flutter-apk/
```

### 第四步：验证成功 (3分钟)
```bash
# 检查APK文件
ls -lh build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# 文件大小应该在8-15MB
# 如果文件存在且大小合理，说明构建成功！
```

---

## 🚨 如果遇到问题

### 问题1：依赖包下载失败
```bash
# 备用方案：完整环境配置
cd myrd
chmod +x setup_env.sh
./setup_env.sh
source ~/.bashrc
```

### 问题2：环境验证失败
```bash
# 重新设置环境变量
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.0.12077973" 
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
```

### 问题3：构建失败
```bash
# 查看详细错误
flutter build apk --verbose

# 清理重试
flutter clean
flutter pub get
flutter build apk --debug  # 先试debug版本
```

---

## 📞 快速联系

- **完整文档：** 查看 `README_COMPLETE_GUIDE.md`
- **详细流程：** 查看 `COLLEAGUE_WORKFLOW.md`  
- **项目状态：** 查看 `PROJECT_STATUS.md`
- **交接总结：** 查看 `PROJECT_HANDOVER.md`

---

**🎯 预期结果：** 30分钟内构建出可用的Android APK文件  
**📦 APK位置：** `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

*快速指南版本: v1.0*
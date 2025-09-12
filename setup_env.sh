#!/bin/bash
# RustDesk Android 开发环境设置脚本
# 使用方法: source ./setup_env.sh

echo "=== RustDesk Android 开发环境设置 ==="

# 基础环境变量
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export ANDROID_HOME=/opt/android
export ANDROID_NDK_HOME=/opt/android/android-ndk-r27c

# 关键的bindgen配置 (解决编译错误的核心)
export LIBCLANG_PATH=/usr/lib64
export BINDGEN_EXTRA_CLANG_ARGS_aarch64_linux_android="--target=aarch64-linux-android21 --sysroot=/opt/android/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/sysroot -I/opt/android/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include -I/opt/android/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/aarch64-linux-android"

# 路径配置
export PATH=/opt/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:~/.cargo/bin:$PATH

# 代理配置 (如果需要)
# export http_proxy=http://your-proxy:port
# export https_proxy=https://your-proxy:port

echo "✅ 环境变量设置完成"
echo "📝 Java Home: $JAVA_HOME"
echo "📱 Android Home: $ANDROID_HOME" 
echo "🔧 NDK Home: $ANDROID_NDK_HOME"
echo "🦀 Rust: $(rustc --version 2>/dev/null || echo '需要安装')"
echo "📱 Flutter: $(flutter --version --machine 2>/dev/null | head -1 || echo '需要安装')"

echo ""
echo "🚀 快速开始:"
echo "   ./auto_build.sh              # 完整自动化构建"
echo "   ./build_android_minimal.sh   # 最小化构建" 
echo "   ./quick_build_apk.sh         # 直接构建APK"
echo ""
echo "📖 详细文档:"
echo "   DEVELOPMENT_LOG.md   # 完整开发日志"
echo "   PROJECT_SUMMARY.md   # 项目完成总结"
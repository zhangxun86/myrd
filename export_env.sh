#!/bin/bash
# RustDesk Android 开发环境变量配置脚本

# Java 环境
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk

# Android SDK 环境
export ANDROID_HOME=$HOME/android-sdk
export ANDROID_SDK_ROOT=$ANDROID_HOME

# Flutter 环境
export FLUTTER_HOME=$HOME/flutter

# PATH 配置
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$FLUTTER_HOME/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH

echo "✅ RustDesk Android 开发环境变量已加载"
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Android SDK: $(which sdkmanager)"
echo "Flutter: $(flutter --version | head -n 1)"
echo "Rust: $(rustc --version)"
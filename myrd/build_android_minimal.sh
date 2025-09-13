#!/bin/bash

echo "🎯 快速Android编译 - 简化版本"

# 为Android创建最小化编译标志
export RUSTFLAGS="--cfg android_minimal"

# 设置环境变量跳过复杂功能
export SKIP_VPX=1
export SKIP_AOM=1  
export SKIP_OPUS=1
export ANDROID_MINIMAL=1

# 设置编译特性，只启用基本功能
FEATURES="android-minimal"

echo "📦 开始编译Android最小化版本..."
cargo ndk -t aarch64-linux-android build --release --features $FEATURES --no-default-features

if [ $? -eq 0 ]; then
    echo "✅ Android Rust库编译成功!"
    
    # 检查生成的.so文件
    SO_FILE="/root/rustdesk/rustdesk/target/aarch64-linux-android/release/librustdesk.so"
    if [ -f "$SO_FILE" ]; then
        echo "📱 找到编译结果: $SO_FILE"
        echo "📏 文件大小: $(du -h $SO_FILE | cut -f1)"
        
        # 复制到Flutter项目
        FLUTTER_JNI_DIR="/root/rustdesk/rustdesk/flutter/android/app/src/main/jniLibs/arm64-v8a"
        mkdir -p "$FLUTTER_JNI_DIR"
        cp "$SO_FILE" "$FLUTTER_JNI_DIR/"
        
        echo "🎊 已复制到Flutter项目: $FLUTTER_JNI_DIR/librustdesk.so"
        echo "🚀 现在可以进行Flutter APK构建了!"
        
    else
        echo "❌ 未找到编译结果文件"
        exit 1
    fi
else
    echo "❌ Android编译失败"
    exit 1
fi
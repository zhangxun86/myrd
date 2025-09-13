#!/bin/bash

echo "🚀 快速策略：使用占位符进行Flutter APK构建"

# 创建Flutter项目的JNI目录
FLUTTER_JNI_DIR="/root/rustdesk/myrd/flutter/android/app/src/main/jniLibs/arm64-v8a"
mkdir -p "$FLUTTER_JNI_DIR"

# 创建一个最小的占位符.so文件
echo "📦 创建占位符librustdesk.so文件..."

# 使用简单的C代码创建占位符
cat > /tmp/placeholder.c << 'EOF'
// Placeholder library for Android build
void placeholder_function() {
    // Empty placeholder
}

// JNI exports that Flutter might expect
void Java_com_carriez_flutter_1hbb_MainService_init(void) {}
void Java_com_carriez_flutter_1hbb_MainService_startService(void) {}
void Java_com_carriez_flutter_1hbb_MainService_stopService(void) {}
EOF

# 编译占位符
echo "🔨 编译占位符库..."
/opt/android/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang \
    -shared -fPIC -o "$FLUTTER_JNI_DIR/librustdesk.so" /tmp/placeholder.c

if [ -f "$FLUTTER_JNI_DIR/librustdesk.so" ]; then
    echo "✅ 占位符库创建成功: $FLUTTER_JNI_DIR/librustdesk.so"
    echo "📏 文件大小: $(du -h $FLUTTER_JNI_DIR/librustdesk.so | cut -f1)"
    
    # 验证文件类型
    file "$FLUTTER_JNI_DIR/librustdesk.so"
    
    echo "🎊 现在可以尝试Flutter APK构建了!"
    echo "📱 进入Flutter构建阶段..."
    
    # 切换到Flutter项目目录
    cd /root/rustdesk/myrd/flutter
    
    # 检查Flutter项目结构
    echo "📂 检查Flutter项目结构:"
    ls -la android/app/src/main/jniLibs/arm64-v8a/
    
    # 开始Flutter APK构建
    echo "🚀 开始Flutter APK构建..."
    flutter build apk --release
    
else
    echo "❌ 占位符库创建失败"
    exit 1
fi
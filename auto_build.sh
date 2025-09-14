#!/bin/bash

# 自动重试 Android 编译脚本
# 会自动检测和修复常见的编译错误

cd /root/rustdesk/rustdesk

# 设置环境变量
export ANDROID_NDK_HOME=/opt/android/android-ndk-r27c
export LIBCLANG_PATH=/usr/lib64
export VCPKG_ROOT=/tmp/vcpkg_mock
export BINDGEN_EXTRA_CLANG_ARGS_aarch64_linux_android="--target=aarch64-linux-android21 --sysroot=/opt/android/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/sysroot -I/opt/android/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include -I/opt/android/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/aarch64-linux-android"

MAX_RETRIES=5
RETRY_COUNT=0

echo "开始 RustDesk Android 自动编译..."
echo "最大重试次数: $MAX_RETRIES"

# 编译函数
compile_rust() {
    echo "$(date): 开始编译 Rust Android 库 (尝试 $((RETRY_COUNT + 1))/$MAX_RETRIES)..."
    
    source ~/.bashrc
    cargo ndk --target aarch64-linux-android --platform 21 -- build --release --lib --no-default-features 2>&1 | tee compile.log
    
    return ${PIPESTATUS[0]}
}

# 错误检测和修复函数
fix_errors() {
    local log_file="compile.log"
    
    echo "$(date): 检测编译错误..."
    
    # 检查 VCPKG_ROOT 错误
    if grep -q "Couldn't find VCPKG_ROOT" "$log_file"; then
        echo "$(date): 检测到 VCPKG_ROOT 错误，正在修复..."
        mkdir -p /tmp/vcpkg_mock/installed/arm64-android/{lib,include}
        mkdir -p /tmp/vcpkg_mock/installed/aarch64-android/{lib,include}
        return 1
    fi
    
    # 检查 libclang 错误
    if grep -q "Unable to find libclang" "$log_file"; then
        echo "$(date): 检测到 libclang 错误，正在修复..."
        export LIBCLANG_PATH=/usr/lib64
        return 1
    fi
    
    # 检查 stubs-32.h 错误
    if grep -q "gnu/stubs-32.h" "$log_file"; then
        echo "$(date): 检测到 32位库错误，正在修复 bindgen 参数..."
        export BINDGEN_EXTRA_CLANG_ARGS="--target=aarch64-linux-android21 --sysroot=/opt/android/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
        return 1
    fi
    
    # 检查成功编译
    if grep -q "Finished release" "$log_file"; then
        echo "$(date): 🎉 编译成功完成！"
        return 0
    fi
    
    # 检查其他错误
    if grep -q "error:" "$log_file"; then
        echo "$(date): 检测到其他编译错误，等待手动修复..."
        echo "错误详情:"
        grep "error:" "$log_file" | tail -5
        return 1
    fi
    
    return 1
}

# 主循环
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    compile_rust
    COMPILE_RESULT=$?
    
    if [ $COMPILE_RESULT -eq 0 ]; then
        fix_errors
        if [ $? -eq 0 ]; then
            echo "$(date): ✅ 编译成功完成！"
            
            # 检查生成的 .so 文件
            echo "$(date): 检查生成的库文件..."
            SO_FILE=$(find target/aarch64-linux-android/release -name "librustdesk.so" 2>/dev/null)
            if [ -n "$SO_FILE" ]; then
                echo "$(date): 📁 找到编译产物: $SO_FILE"
                ls -la "$SO_FILE"
                
                # 复制到 Flutter 项目
                echo "$(date): 复制库文件到 Flutter 项目..."
                mkdir -p flutter/android/app/src/main/jniLibs/arm64-v8a/
                cp "$SO_FILE" flutter/android/app/src/main/jniLibs/arm64-v8a/
                echo "$(date): ✅ 库文件复制完成"
            else
                echo "$(date): ⚠️  警告: 未找到 librustdesk.so 文件"
            fi
            
            exit 0
        fi
    fi
    
    # 尝试修复错误
    fix_errors
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        echo "$(date): 等待 10 秒后重试..."
        sleep 10
    fi
done

echo "$(date): ❌ 达到最大重试次数，编译失败"
echo "最后的错误日志:"
tail -20 compile.log
exit 1